using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class BuildUtils
{
    public static void HandleLua()
    {
        FileUtil.DeleteFileOrDirectory(BuildConfig.LUA_OUTPUT_PATH);
        ParseLuaToTxt(BuildConfig.LUA_SOURCE_PATH,BuildConfig.LUA_OUTPUT_PATH);
        AssetDatabase.Refresh();
    }

    public static void ParseLuaToTxt(string luaDir, string outputDir)
    {
        var count = 0;
        FileUtils.CopyFloder(luaDir,outputDir,
            (file)=>{
                return !file.FullName.EndsWith(".lua");
            },
            (file)=>{
                count++;
                return file.Name.Replace(".lua",".lua.txt");
            });
        Debug.Log($"已处理Lua文件{count}个.请查看:{outputDir}");
    }

    
    public static string GetLastName(string path, string split = "/")
    {
        var arr = path.Split(split);
        return arr[arr.Length-1];
    }
}