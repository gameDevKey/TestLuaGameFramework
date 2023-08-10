using System;
using System.Collections.Generic;
using UnityEngine;

[XLua.LuaCallCSharp]
public class UIRef : MonoBehaviour
{
    [XLua.BlackList]
    public UnitySerializedDictionary<string, UnityEngine.Object> Objects = new UnitySerializedDictionary<string, UnityEngine.Object>();

    private static Dictionary<Type, string> m_Type2Prefix = new()
    {
        {typeof(UnityEngine.GameObject),"obj" },
        {typeof(UnityEngine.RectTransform),"rect" },
        {typeof(UnityEngine.Transform),"trans" },
        {typeof(UnityEngine.UI.Button),"btn" },
        {typeof(UnityEngine.UI.Image),"img" },
        {typeof(UnityEngine.UI.Text),"txt" },
        {typeof(UnityEngine.UI.InputField),"input" },
        {typeof(UnityEngine.UI.ScrollRect),"scroll" },
    };

    private int duplicateIndex = 0;

    public UnityEngine.Object GetRef(string key)
    {
        UnityEngine.Object obj;
        Objects.TryGetValue(key, out obj);
        return obj;
    }

    [XLua.BlackList]
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

    [XLua.BlackList]
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

    [XLua.BlackList]
    public bool RemoveObject(string key)
    {
        if (!Objects.ContainsKey(key))
        {
            return false;
        }
        Objects.Remove(key);
        return true;
    }

    [XLua.BlackList]
    public string GetUniqueKey(string newKey)
    {
        var realKey = newKey.Trim();
        if (Objects.ContainsKey(realKey))
        {
            realKey += ++duplicateIndex;//±‹√‚º¸÷ÿ∏¥
        }
        return realKey;
    }

    [XLua.BlackList]
    public string GetUniqueKey(UnityEngine.Object obj)
    {
        return GetUniqueKey(GetObjKey(obj));
    }

    [XLua.BlackList]
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