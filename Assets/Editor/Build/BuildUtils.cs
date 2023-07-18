using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class BuildUtils
{
    public const string LUA_SOURCE_PATH = "Assets/Scripts/Lua";
    public const string LUA_OUTPUT_PATH = "Assets/BuildAssets/Scripts/Lua";

    public static void HandleLua()
    {
        FileUtil.DeleteFileOrDirectory(LUA_OUTPUT_PATH);
        ParseLuaToTxt(LUA_SOURCE_PATH,LUA_OUTPUT_PATH);
        AssetDatabase.Refresh();
    }

    public static void ParseLuaToTxt(string luaDir, string outputDir)
    {
        var count = 0;
        FileUtils.CopyDir(luaDir,outputDir,
            (file)=>{
                return !file.FullName.EndsWith(".lua");
            },
            (file)=>{
                count++;
                return file.Name.Replace(".lua",".lua.txt");
            });
        Debug.Log($"已处理Lua文件{count}个.请查看:{outputDir}");
    }
}