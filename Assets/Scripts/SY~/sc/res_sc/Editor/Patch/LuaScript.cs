using System;
using System.IO;
using System.Text;
using System.Security.Cryptography;
using System.Collections.Generic;
using UnityEngine;
using LZ4ps;
using EditorTools.AssetBundle;


public class LuaScript
{
    private static bool IsEncrypt = true;
    private static string LUA_KEY = "sygame888888";
    private Dictionary<string, LuaFileInfo> fileDict = new Dictionary<string, LuaFileInfo>();

    public long scriptVersion
    {
        get;
        private set;
    }

    public class LuaFileInfo
    {
        public string name;
        public string hash;
        public int uncompressLength;
        public byte[] compressData;
    }


    public byte[] Load(string name)
    {
        if (fileDict != null && fileDict.ContainsKey(name))
        {
            LuaFileInfo script = fileDict[name];
            byte[] output = new byte[script.uncompressLength];
            LZ4Codec.Decode32(script.compressData, 0, script.compressData.Length, output, 0, output.Length, true);
            return output;
        }
        return null;
    }


    public void LoadFrom(string path)
    {
        if (!File.Exists(path))
        {
            Debug.Log("确认是否首次打包，脚本文件不存在 " + path);
            return;
        }

        byte[] bytes = File.ReadAllBytes(path);
        if (bytes == null)
        {
            Debug.LogError("加载脚本错误");
            return;
        }
        LoadFrom(bytes);
    }

    public void LoadFrom(byte[] bytes)
    {
        if (IsEncrypt)
        {
            bytes = XXTea.Decrypt(bytes, LUA_KEY);
        }

        fileDict.Clear();
        MemoryStream memoryStream = new MemoryStream(bytes);
        BinaryReader binaryReader = new BinaryReader(memoryStream, Encoding.UTF8);

        this.scriptVersion = binaryReader.ReadInt64();
        int fileCount = binaryReader.ReadInt32();
        for (int i = 0; i < fileCount; i++)
        {
            string name = binaryReader.ReadString();
            string hash = binaryReader.ReadString();
            int uncompressLength = binaryReader.ReadInt32();
            int compressLength = binaryReader.ReadInt32();
            byte[] scriptData = binaryReader.ReadBytes(compressLength);

            LuaFileInfo script = new LuaFileInfo()
            {
                name = name,
                compressData = scriptData,
                uncompressLength = uncompressLength,
                hash = hash,
            };
            fileDict.Add(name, script);
        }
    }


    public void LoadFromDir(string luaDir)
    {
        fileDict.Clear();
        string[] files = Directory.GetFiles(luaDir, "*.*", SearchOption.AllDirectories);
        List<string> luaFiles = new List<string>();
        MD5 md5 = MD5.Create();
        for (int i = 0; i < files.Length; i++)
        {
            string name = files[i];
            if (name.EndsWith(".lua"))
            {
                name = name.Replace("\\", "/");
                byte[] bytes = File.ReadAllBytes(name);
                byte[] compressBytes = LZ4Codec.Encode32(bytes, 0, bytes.Length);
                string useName = name.Substring(luaDir.Length + 1);
                LuaFileInfo script = new LuaFileInfo()
                {
                    name = useName,
                    compressData = compressBytes,
                    uncompressLength = bytes.Length,
                    hash = Convert.ToBase64String((md5.ComputeHash(compressBytes))),
                };
                fileDict.Add(useName, script);
            }
        }
    }

    public void SaveFile(string path)
    {
        SaveFile(path, scriptVersion);
    }

    public void SaveFile(string path, long version)
    {
        scriptVersion = version;
        byte[] bytes = GetBytes(version);
        if(IsEncrypt)
        {
            bytes = XXTea.Encrypt(bytes, LUA_KEY); 
        }
        File.WriteAllBytes(path, bytes);
    }

    private byte[] GetBytes()
    {
        return GetBytes(scriptVersion);
    }

    private byte[] GetBytes(long version)
    {
        //GameDebug.Log("ScriptLuaPatch  " + path);
        List<string> luaFiles = new List<string>(fileDict.Keys);
        luaFiles.Sort();

        MemoryStream memoryStream = new MemoryStream(2 * 1024 * 1024);
        BinaryWriter binaryWriter = new BinaryWriter(memoryStream, Encoding.UTF8);
        binaryWriter.Write(version);
        binaryWriter.Write(luaFiles.Count);

        for (int i = 0; i < luaFiles.Count; i++)
        {
            LuaFileInfo script = fileDict[luaFiles[i]];
            binaryWriter.Write(script.name);
            binaryWriter.Write(script.hash);
            binaryWriter.Write(script.uncompressLength);
            binaryWriter.Write(script.compressData.Length);
            binaryWriter.Write(script.compressData);
        }
        return memoryStream.ToArray();
    }


    public void MergePatch(LuaScript patch)
    {
        if (this.scriptVersion >= patch.scriptVersion)
        {
            Debug.LogError(string.Format("Script Merge Error! ScriptVersion={0} PatchVersion={1}", this.scriptVersion, patch.scriptVersion));
            return;
        }

        this.scriptVersion = patch.scriptVersion;

        StringBuilder builder = new StringBuilder();
        builder.AppendFormat("合并补丁 version={0}\n", patch.scriptVersion);

        foreach (var one in patch.fileDict)
        {
            LuaFileInfo script = one.Value;
            if (script.uncompressLength != 0)
            {
                this.fileDict[script.name] = script;
                builder.AppendFormat("+{0} size={1}\n", script.name, script.uncompressLength);
            }
            else
            {
                if (this.fileDict.ContainsKey(script.name))
                {
                    this.fileDict.Remove(script.name);
                    builder.AppendFormat("-{0}\n", script.name);
                }
            }
        }
    }

    public static LuaScript MakePatch(LuaScript oldZip, LuaScript newZip)
    {
        StringBuilder builder = new StringBuilder();
        builder.AppendFormat("MakePatch version={0}\n", newZip.scriptVersion);

        LuaScript patch = new LuaScript();
        patch.scriptVersion = newZip.scriptVersion;
        foreach (var one in newZip.fileDict)
        {
            string name = one.Key;
            LuaFileInfo newScript = one.Value;
            if (oldZip.fileDict.ContainsKey(name))
            {
                if (oldZip.fileDict[name].hash != newScript.hash)
                {
                    patch.fileDict[name] = newScript;
                    builder.AppendFormat("+{0} size={1}\n", name, newScript.uncompressLength);
                }
            }
            else
            {
                patch.fileDict[name] = newScript;
                builder.AppendFormat("+{0} size={1}\n", name, newScript.uncompressLength);
            }
        }

        foreach (var one in oldZip.fileDict)
        {
            string name = one.Key;
            if (!newZip.fileDict.ContainsKey(name))
            {
                LuaFileInfo script = new LuaFileInfo()
                {
                    name = name,
                    compressData = new byte[0],
                    uncompressLength = 0,
                    hash = new string('0', 32),
                };
                patch.fileDict[name] = script;
                builder.AppendFormat("-{0}\n", name);
            }
        }

        return patch;
    }

    public void Dump()
    {
        foreach (var one in fileDict)
        {
            Debug.LogFormat("name={0} len={1}", one.Value.name, one.Value.uncompressLength);
        }
    }
}
