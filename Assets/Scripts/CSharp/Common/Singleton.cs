using System;
using System.Collections.Generic;

public class Singleton<T> where T : class, new()
{
    private static readonly Dictionary<Type, T> instances = new Dictionary<Type, T>();

    public static T Instance
    {
        get
        {
            Type type = typeof(T);
            if (!instances.ContainsKey(type))
            {
                instances[type] = new T();
            }
            return instances[type];
        }
    }
}