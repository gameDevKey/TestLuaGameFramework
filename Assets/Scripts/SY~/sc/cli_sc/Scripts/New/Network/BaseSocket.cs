using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Net.Sockets;
using System.Threading;
using UniRx;
using UnityEngine;
using XLua;

public class BaseSocket
{
    protected enum ConnType
    {
        none = 0,
        tcp = 1,
        udp = 2,
        web = 3,
    }

    protected ConnType connType = ConnType.none;

    protected Socket socket = null;

    protected bool isWorking = true;

    protected ConcurrentQueue<byte[]> recvBytes = new ConcurrentQueue<byte[]>();
    protected ConcurrentQueue<byte[]> sendBytes = new ConcurrentQueue<byte[]>();

    protected LuaFunction luaRecvFunc = null;
    protected LuaFunction luaSendFailFunc = null;
    protected LuaFunction luaRecvFailFunc = null;

    protected CompositeDisposable disposables = new CompositeDisposable();

    public int SendByteNum = 1024 * 3;
    public int DispatcherNum = 10000;
    public int HeadLength = 4;

    readonly object workLock = new object();

    public BaseSocket()
    {
    }

    public void SetRecv(LuaTable luaConn,string funName)
    {
        luaRecvFunc = luaConn.Get<LuaFunction>(funName);
    }

    public void SetSendFail(LuaTable luaConn, string funName)
    {
        luaSendFailFunc = luaConn.Get<LuaFunction>(funName);
    }

    public void SetRecvFail(LuaTable luaConn, string funName)
    {
        luaRecvFailFunc = luaConn.Get<LuaFunction>(funName);
    }

    public void Started()
    {
        if(connType == ConnType.web)
        {
            Observable.EveryUpdate().Subscribe(_ => { OnRecv(); }).AddTo(disposables);
        }
        else
        {
            Observable.Start(() => SendThread()).Subscribe().AddTo(disposables);
            Observable.Start(() => RecvThread()).Subscribe().AddTo(disposables);
        }

        Observable.EveryUpdate().Subscribe(_ =>{ Dispatcher(); }).AddTo(disposables);
    }

    public AddressFamily GetAddressFamily()
    {
        if(BaseApi.IsIpv6())
        {
            return AddressFamily.InterNetworkV6;
        }
        else
        {
            return AddressFamily.InterNetwork;
        }
    }

    public void SendData(byte[] data)
    {
        if (isWorking)
        {
            if (connType == ConnType.web)
            {
                OnSend(data, 0, data.Length);
            }
            else
            {
                sendBytes.Enqueue(data);
            }
        }
    }

    public void SendFail()
    {
        if (connType == ConnType.web)
        {
            if (isWorking)
            {
                isWorking = false;
                luaSendFailFunc.Call();
            }
        }
        else
        {
            lock (workLock)
            {
                if (isWorking)
                {
                    isWorking = false;
                    MainThreadDispatcher.Post((_) => { luaSendFailFunc.Call(); }, null);
                }
            }
        }
    }
    public void RecvFail()
    {
        if (connType == ConnType.web)
        {
            if (isWorking)
            {
                isWorking = false;
                luaRecvFailFunc.Call();
            }
        }
        else
        {
            lock (workLock)
            {
                if (isWorking)
                {
                    isWorking = false;
                    MainThreadDispatcher.Post((_) => { luaRecvFailFunc.Call(); }, null);
                }
            }
        }
    }

    public int ImmedSend(byte[] data, int offset, int length)
    {
        return OnSend(data, offset, length);
    }

    public void SendThread()
    {
        while (isWorking)
        {
            byte[] sendData;
            bool ok = sendBytes.TryDequeue(out sendData);

            if (!ok || sendData == null)
            {
                Thread.Sleep(10);
                continue;
            }

            try
            {
                int sendLen = sendData.Length;
                int sendTotalNum = 0;
                
                do
                {
                    int sendNum = sendLen - sendTotalNum;
                    if (SendByteNum > 0 && sendNum > SendByteNum)
                    {
                        sendNum = SendByteNum;
                    }
                    int n = OnSend(sendData, sendTotalNum, sendNum);
                    if (n == 0)
                    {
                        Thread.Sleep(10);
                        continue;
                    }
                    else if (n < 0)
                    {
                        SendFail();
                    }
                    else
                    {
                        sendTotalNum += n;
                    }

                    if (sendNum >= SendByteNum)
                    {
                        Thread.Sleep(10);
                    }
                } while (sendTotalNum < sendLen && isWorking);
            }
            catch (Exception ex)
            {
                if (isWorking)
                {
                    Debug.LogFormat("发送数据时发送异常：" + ex.Message);
                    SendFail();
                }
            }
        }
    }

    public void RecvThread()
    {
        while (isWorking)
        {
            try
            {
                int n = OnRecv();
                if(n == 0)
                {
                    Thread.Sleep(10);
                    continue;
                }
                else if(n < 0)
                {
                    RecvFail();
                }
            }
            catch (Exception e)
            {
                if (isWorking)
                {
                    Debug.LogFormat("接收数据时发生异常：" + e.Message);
                    RecvFail();
                }
            }
        }
    }

    void Dispatcher()
    {
        for (int i = 0; i < DispatcherNum; i++)
        {
            byte[] data;
            bool ok = recvBytes.TryDequeue(out data);

            if (!ok || data == null || data.Length <= 0)
            {
                break;
            }

            try
            {
                luaRecvFunc.Call(data);
            }
            catch (Exception e)
            {
                Debug.LogError(string.Format("回调给Lua时发生异常: {0}", e.Message));
            }
            finally
            {
                if(data.Length == BufferPool.BUFF_SIZE)
                {
                    BufferPool.Push(data);
                }
            }
        }
    }

    public void Disconnect()
    {
        isWorking = false;

        if (disposables != null)
        {
            disposables.Dispose();
            disposables = null;
        }

        do
        {
            byte[] data;
            bool ok = recvBytes.TryDequeue(out data);

            if(!ok || data == null)
            {
                break;
            }

            if (data.Length == BufferPool.BUFF_SIZE)
            {
                BufferPool.Push(data);
            }
        } while (true);

        if (socket != null)
        {
            try
            {
                socket.Shutdown(SocketShutdown.Both);
                socket.Close();
            }
            catch (Exception ex)
            {
                Debug.LogFormat("断开网络连接时发生错误：" + ex.Message);
            }
            socket = null;
        }

        OnDisconnect();
    }

    //
    public virtual int OnSend(byte[] data, int offset, int length)
    {
        return -1;
    }

    public virtual int OnRecv()
    {
        return -1;
    }

    public virtual void OnDisconnect()
    {
    }
}