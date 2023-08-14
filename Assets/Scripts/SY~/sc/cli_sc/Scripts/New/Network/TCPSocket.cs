using System;
using System.Collections;
using System.Collections.Generic;
using System.Net.Sockets;
using System.Threading;
using UniRx;
using UnityEngine;
using XLua;

public class TCPSocket: BaseSocket
{
    private IAsyncResult connectResult;

    public TCPSocket() : base()
    {
        connType = ConnType.tcp;
    }

    public void Connect(string host, int port)
    {
        socket = new Socket(GetAddressFamily(), SocketType.Stream, ProtocolType.Tcp);
        socket.ReceiveBufferSize = 1024 * 32;
        socket.SendBufferSize = 1024 * 32;
        socket.NoDelay = true;

        try
        {
            connectResult = socket.BeginConnect(host, port, null, null);
        }
        catch (Exception ex)
        {
            Debug.LogFormat("连接TcpSocket时发生异常：" + ex.Message);
        }
    }

    //1,30000,10000
    public void SetKeepAliveValues(int onOff, int keepAliveTime, int keepAliveInterval)
    {
        if(socket != null)
        {
            socket.IOControl(IOControlCode.KeepAliveValues, KeepAlive(onOff, keepAliveTime, keepAliveInterval), null);
        }
    }

    public bool CheckConnectResult()
    {
        if (connectResult == null || !connectResult.IsCompleted)
        {
            return false;
        }

        try
        {
            socket.EndConnect(connectResult);

            //Debug.Log(string.Format("Socket接收缓冲区大小: {0:F1}k", socket.ReceiveBufferSize / 1024f));
            //Debug.Log(string.Format("Socket发送缓冲区大小: {0:F1}k", socket.SendBufferSize / 1024f));
            //Debug.Log(string.Format("Socket接收超时时间: {0}ms", socket.ReceiveTimeout));
            //Debug.Log(string.Format("Socket发送超时时间: {0}ms", socket.SendTimeout));
            //Debug.Log(string.Format("Socket数据包生存时间(TTL): {0}", socket.Ttl));
            //Debug.Log(string.Format("Socket是否工作在阻塞模式: {0}", socket.Blocking));
            //Debug.Log(string.Format("SocketNoDelay: {0}", socket.NoDelay));

            return true;
        }
        catch (SocketException e)
        {
            return false;
        }
    }

    private byte[] KeepAlive(int onOff, int keepAliveTime, int keepAliveInterval)
    {
        byte[] buffer = new byte[12];
        BitConverter.GetBytes(onOff).CopyTo(buffer, 0);
        BitConverter.GetBytes(keepAliveTime).CopyTo(buffer, 4);
        BitConverter.GetBytes(keepAliveInterval).CopyTo(buffer, 8);
        return buffer;
    }

    // 通过socket发送数据
    public override int OnSend(byte[] data, int offset, int length)
    {
        int sendBytes = 0;
        do
        {
            int n = socket.Send(data, offset, length, SocketFlags.None);
            if (n < 0)
            {
                return -1;
            }
            sendBytes += n;
        } while (sendBytes < length && isWorking);
        
        return length;
    }

    public override int OnRecv()
    {
        // 读取包头长度信息，包头信息等待时间设置为100秒
        byte[] buffer = BufferPool.Pop();
        int headRecvNum = Receive(buffer, 0, HeadLength, 100000);
        if (headRecvNum <= 0)
        {
            BufferPool.Push(buffer);
            return headRecvNum;
        }

        uint length = BitConverter.ToUInt32(buffer, 0);

        bool isNewBuffer = false;
        if (length + HeadLength > BufferPool.BUFF_SIZE)
        {
            isNewBuffer = true;
            byte[] newBuffer = new byte[HeadLength + length];
            Buffer.BlockCopy(buffer, 0, newBuffer, 0, HeadLength);
            BufferPool.Push(buffer);
            buffer = newBuffer;
        }

        int dataRecvNum = Receive(buffer, HeadLength, (int)length);
        if ( (dataRecvNum == 0 && length > 0) || dataRecvNum < 0)
        {
            if(!isNewBuffer)
            {
                BufferPool.Push(buffer);
            }
        }
        else
        {
            recvBytes.Enqueue(buffer);
        }

        return headRecvNum + dataRecvNum;
    }

    // 接收指定长度的数据
    public int Receive(byte[] data, int index, int length, int receiveTimeout = 20000)
    {
        int startTickCount = Environment.TickCount;
        int maxIndex = index + length;
        if (length == 0)
        {
            return 0;
        }
        do
        {
            if (Environment.TickCount > startTickCount + receiveTimeout)
            {
                throw new Exception("接收数据超时");
            }
            try
            {
                int n = socket.Receive(data, index, maxIndex - index, SocketFlags.None);
                if(n < 0)
                {
                    return -1;
                }
                index += n;
            }
            catch (SocketException e)
            {
                if (e.SocketErrorCode == SocketError.WouldBlock || e.SocketErrorCode == SocketError.IOPending || e.SocketErrorCode == SocketError.NoBufferSpaceAvailable)
                {
                    // 对于以上几种情况，有可能是接收缓冲区还没有数据到达，等待30毫秒后重试
                    Thread.Sleep(10);
                }
                else
                {
                    throw new Exception(e.Message);
                }
            }
        } while (index < maxIndex && isWorking);

        return length;
    }
}
