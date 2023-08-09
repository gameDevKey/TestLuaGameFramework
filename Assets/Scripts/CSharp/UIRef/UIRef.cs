using System;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UI;

public class UIRef : MonoBehaviour
{
    public UnitySerializedDictionary<string, UnityEngine.Object> Objects = new UnitySerializedDictionary<string, UnityEngine.Object>();

    private static Dictionary<Type, string> m_Type2Prefix = new()
    {
        {typeof(Button),"btn" },
        {typeof(Image),"img" },
        {typeof(RectTransform),"rect" },
        {typeof(GameObject),"obj" },
        {typeof(Transform),"trans" },
    };

    private int duplicateIndex = 0;

    public string ModifyKey(string key, string newKey)
    {
        if (!Objects.ContainsKey(key) || key == newKey)
        {
            return null;
        }
        var realKey = GetUniqueKey(newKey);
        var obj = Objects[key];
        Objects.Remove(key);
        Objects.Add(realKey, obj);
        return realKey;
    }

    public string ModifyObject(string key, UnityEngine.Object obj)
    {
        if (!string.IsNullOrEmpty(key) && !Objects.ContainsKey(key))
        {
            Objects.Add(key, obj);
            return key;
        }
        var newKey = GetUniqueKey(obj);
        if (newKey != key)
        {
            Objects.Remove(key);
            Objects[newKey] = obj;
        }
        return newKey;
    }

    public bool RemoveObject(string key)
    {
        if (!Objects.ContainsKey(key))
        {
            return false;
        }
        Objects.Remove(key);
        return true;
    }

    public string GetUniqueKey(string newKey)
    {
        var realKey = newKey;
        if (Objects.ContainsKey(realKey))
        {
            realKey += ++duplicateIndex;//±‹√‚º¸÷ÿ∏¥
        }
        return realKey;
    }

    public string GetUniqueKey(UnityEngine.Object obj)
    {
        return GetUniqueKey(GetObjKey(obj));
    }

    public static string GetObjKey(UnityEngine.Object obj)
    {
        var prefix = GetObjKeyPrefix(obj);
        return prefix + obj.name;
    }

    private static string GetObjKeyPrefix(UnityEngine.Object obj)
    {
        var tpe = obj.GetType();
        string prefix;
        if (m_Type2Prefix.ContainsKey(tpe))
        {
            prefix = m_Type2Prefix[tpe];
        }
        else
        {
            var name = tpe.ToString().Split(".");
            prefix = name[name.Length - 1];
        }
        var firstChar = prefix[0].ToString().ToLower();
        return firstChar + prefix.Substring(1);
    }
}