using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using XLua;

[LuaCallCSharp]
[ReflectionUse]
public static class UnityEngineExtention
{
    public static bool IsNull(this UnityEngine.Object o)
    {
        return o == null;
    }
}
