using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using UnityEngine;

public class BufferPool
{
    /// <summary>
    /// ���16k
    /// </summary>
    public const int BUFF_SIZE = 1024 * 16;
    private static ConcurrentQueue<byte[]> pool = new ConcurrentQueue<byte[]>();

    private BufferPool() { }

    /// <summary>
    /// ��ȡ
    /// </summary>
    /// <returns></returns>
    public static byte[] Pop()
    {
        byte[] bytes;
        if (pool.Count > 0)
        {
            pool.TryDequeue(out bytes);
        }
        else
        {
            bytes = new byte[BUFF_SIZE];
        }
        return bytes;
    }

    /// <summary>
    /// ����
    /// </summary>
    /// <param name="each"></param>
    public static void Push(byte[] each)
    {
        Array.Clear(each, 0, each.Length);
        pool.Enqueue(each);
    }
}
