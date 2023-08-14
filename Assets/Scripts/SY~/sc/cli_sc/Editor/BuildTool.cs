using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;


public static class BuildTool
{
    private static readonly string[] ProjectDlls =
    {
        "Assembly-CSharp",
        "Assembly-CSharp-firstpass",
    };

    
    [MenuItem("Build/EncryptAPK")]
    public static void EncryptAPK()
    {
        string path = UnityEditor.EditorUtility.OpenFilePanel("Select APK", UnityEngine.Application.dataPath, "apk");
        Debug.Log(path);
        EncryptApk(path);
    }

    private const string ApkToolPath = "BuildTools/Mono/apktool-2.3.3.jar"; //修改过的版本，处理yml文件noCompress字段太长问题
    private const string MonoPath_Armv7a = "BuildTools/Mono/2017/Android/libs/armeabi-v7a/libmono.so";

    //dll加密
    private static string DLLEncrypt = Application.dataPath +  "/../BuildTools/Mono/encrypt_dll.exe";
    private const string DLLKey = "yy379ge9geg7tek";

    //签名相关
    private const string KeystorePath = "BuildTools/Mono/frame.keystore";
    private const string KeystorePassword = "pwd123";
    private const string KeystoreName = "name123";


    public static void EncryptApk(string apkPath)
    {
        DecodeApk(apkPath);
        ReplaceMono(apkPath);
        EncryptDLl(apkPath);
        EncodeApk(apkPath);
        SignApk(apkPath);
    }


    private static void DecodeApk(string apkPath)
    { 
        string unpackFolder = GetDecodeApkFolder(apkPath);
        string unsignedApk = GetUnsignedApkPath(apkPath);
        string finaldApk = GetFinalApkPath(apkPath);
        DeleteFile(unsignedApk);
        DeleteFile(finaldApk);

        var argList = new List<string>();
        argList.Add("java -jar");
        argList.Add(ApkToolPath);
        argList.Add("d");
        argList.Add("-f");
        argList.Add(apkPath);
        argList.Add("-o");
        argList.Add(GetDecodeApkFolder(apkPath));

        string cmd = string.Join(" ", argList.ToArray());
        ProcessTask process = new ProcessTask(cmd);
        process.Run();
    }

    private static void ReplaceMono(string apkPath)
    {
        var decodePath = GetDecodeApkFolder(apkPath);
        var armv7aPath = decodePath + "/lib/armeabi-v7a/libmono.so";
        File.Copy(MonoPath_Armv7a, armv7aPath, true);
    }
    

    private static void EncryptDLl(string apkPath)
    {
        string path  = GetDecodeApkFolder(apkPath) + "/assets/bin/Data/Managed";
        foreach (var file in Directory.GetFiles(path, "*.dll"))
        {
            var name = Path.GetFileNameWithoutExtension(file);
            if (IsNeedEncryptDll(name))
            {
                Debug.Log("EncryptDll " + name);
                EncryptDll(file);
            }
        }
    }

    private static string GetDecodeApkFolder(string apkPath)
    {
        return Path.GetDirectoryName(apkPath) + "/" + Path.GetFileNameWithoutExtension(apkPath) + "_unpack";
    }

    private static string GetUnsignedApkPath(string apkPath)
    {
        return Path.GetDirectoryName(apkPath) + "/" + Path.GetFileNameWithoutExtension(apkPath) + "_unsigned.apk";
    }

    private static string GetFinalApkPath(string apkPath)
    {
        return Path.GetDirectoryName(apkPath) + "/" + Path.GetFileNameWithoutExtension(apkPath) + "_final.apk";
    }

    private static void EncodeApk(string apkPath)
    {
        var unsignedApk = GetUnsignedApkPath(apkPath);
        var argList = new List<string>();
        argList.Add("java -jar");
        argList.Add(ApkToolPath);
        argList.Add("b");
        argList.Add("-f");
        argList.Add(GetDecodeApkFolder(apkPath));
        argList.Add("-o");
        argList.Add(unsignedApk);

        string cmd = string.Join(" ", argList.ToArray());
        ProcessTask process = new ProcessTask(cmd);
        process.Run();
    }


    private static void SignApk(string apkPath)
    {
        var unsignedApk = GetUnsignedApkPath(apkPath);
        var signedApkPath = GetFinalApkPath(apkPath);

        var argList = new List<string>();
        argList.Add("jarsigner");
        argList.Add("-verbose");
        argList.Add("-keystore " + KeystorePath);
        argList.Add("-storepass " + KeystorePassword);
        argList.Add("-sigalg SHA1withRSA");
        argList.Add("-digestalg SHA1");
        argList.Add("-signedjar");
        argList.Add(signedApkPath);
        argList.Add(unsignedApk);
        argList.Add(KeystoreName);

        string cmd = string.Join(" ", argList.ToArray());
        ProcessTask process = new ProcessTask(cmd);
        process.Run();

        DeleteFile(unsignedApk);

        Debug.Log("加密成功，生成文件 "  + signedApkPath);
    }



    public static bool IsNeedEncryptDll(string dllName)
    {
        var result = Array.IndexOf(ProjectDlls, dllName) >= 0;
        return result;
    }


    public static void EncryptDll(string dllName)
    {
        var argList = new List<string>();
        argList.Add(DLLEncrypt);
        argList.Add(dllName);
        argList.Add(DLLKey);
        string cmd = string.Join(" ", argList.ToArray());
        Debug.Log(cmd);
        ProcessTask process = new ProcessTask(cmd);
        process.Run();

        string newdll = dllName + ".encrypt";
        File.Copy(newdll, dllName, true);
        DeleteFile(newdll);
    }


    public static void DeleteDir(string path)
    {
        if (Directory.Exists(path))
        {
            Directory.Delete(path, true);
        }
    }

    public static void DeleteFile(string file)
    {
        if (File.Exists(file))
        {
            File.Delete(file);
        }
    }

    public static byte[] ReadAllBytes(string path)
    {
        try
        {
            byte[] data = File.ReadAllBytes(path);
            return data;
        }
        catch (Exception e)
        {
            Debug.LogError(e.Message);
        }
        return null;
    }


}
