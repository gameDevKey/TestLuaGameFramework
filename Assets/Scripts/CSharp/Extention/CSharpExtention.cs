using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

public static class CSharpExtention
{
    public static void ForceAdd<K, V>(this Dictionary<K, V> dict, K key, V value)
    {
        if (!dict.ContainsKey(key))
        {
            dict.Add(key, value);
        }
        else
        {
            dict[key] = value;
        }
    }
}