using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DOTweenAnimFactory
{
    static Dictionary<System.Type, Queue<DOTweenAnimBase>> pool = 
        new Dictionary<System.Type, Queue<DOTweenAnimBase>>();

    public static T CreateAnim<T>() where T: DOTweenAnimBase
    {
        var type = typeof(T);
        if (pool.ContainsKey(type) && pool[type].Count > 0)
        {
            return pool[type].Dequeue() as T;
        }
        return Activator.CreateInstance(type) as T;
    }

    public static void PushAnim(DOTweenAnimBase anim)
    {
        var type = anim.GetType();
        if (!pool.ContainsKey(type))
        {
            pool.Add(type, new Queue<DOTweenAnimBase>());
        }
        if (pool[type].Contains(anim))
        {
            return;
        }
        pool[type].Enqueue(anim);
    }
}
