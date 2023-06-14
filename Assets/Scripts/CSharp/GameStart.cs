using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using XLua;

public class GameStart : MonoBehaviour
{
    internal static LuaEnv luaEnv = new LuaEnv();
    internal static float lastGCTime = 0;
    internal const float GCInterval = 1;
    private Action luaUpdate;
    private LuaTable scriptEnv;

    void Awake()
    {
        DontDestroyOnLoad(this);

        luaEnv.AddLoader((ref string name) => {
            name = name.Replace(".","/");
            var path = string.Format("{0}/Scripts/Lua/{1}.lua",Application.dataPath,name);
            if(File.Exists(path))
            {
                return File.ReadAllBytes(path);
            }
            return null;
        });
        luaEnv.DoString("require('Core.Main')");
        
        scriptEnv = luaEnv.NewTable();

        // 为每个脚本设置一个独立的环境，可一定程度上防止脚本间全局变量、函数冲突
        LuaTable meta = luaEnv.NewTable();
        meta.Set("__index", luaEnv.Global);
        scriptEnv.SetMetaTable(meta);
        meta.Dispose();

        scriptEnv.Set("self", this);
        scriptEnv.Get("Update", out luaUpdate);
    }

    void Update()
    {
        if (luaUpdate != null)
        {
            luaUpdate();
        }
        if (Time.time - lastGCTime > GCInterval)
        {
            luaEnv.Tick();
            lastGCTime = Time.time;
        }
    }

    void Destroy()
    {
        luaUpdate = null;
        scriptEnv.Dispose();
        luaEnv.Dispose();
    }
}
