using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using XLua;

public class GameStart : MonoBehaviour
{
    LuaEnv luaEnv;

    void Awake()
    {
        luaEnv = new LuaEnv();
        luaEnv.AddLoader((ref string name) => {
            name = name.Replace(".","/");
            var path = string.Format("{0}/Scripts/Lua/{1}.lua",Application.dataPath,name);
            // Debug.Log("require路径:"+path);
            if(File.Exists(path))
            {
                return File.ReadAllBytes(path);
            }
            return null;
        });
        luaEnv.DoString("require('Core.Main')");
    }

    void Update()
    {
        if (luaEnv != null)
        {
            luaEnv.Tick();
        }
    }

    void Destroy()
    {
        luaEnv.Dispose();
    }
}
