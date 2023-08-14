using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;

using UnityEngine;
using EditorTools.Patch;

using LitJson;

public class VersionReader {

    private string file = null;
    public Dictionary<string, VersionAsset> dict = new Dictionary<string, VersionAsset>();

    public VersionReader(string file) {
        this.file = file;
        Parse();
    }

    public void Parse() {
        byte[] bytes = AssetPatchMaker.Decompress(File.ReadAllBytes(this.file));
        string detail = System.Text.Encoding.Default.GetString(bytes);
        JsonData jsonData = JsonMapper.ToObject(detail);
        int count = jsonData.Count;
        string path = "";
        string size = "";
        string md5 = "";
        string patchVersion = "";
        for (int i = 0; i < count; i++) {
            JsonData data = jsonData[i];
            IDictionary jdict = data as IDictionary;
            path = data["path"].ToString();
            size = data["size"].ToString();
            md5 = data["md5"].ToString();
            if (jdict.Contains("patchVersion")) {
                patchVersion = data["patchVersion"].ToString();
            } else {
                patchVersion = "";
            }
            dict.Add(path, new VersionAsset(path, size, md5, patchVersion));
        }
    }

    // 返回增量文件列表
    public Dictionary<string, VersionAsset> CompareTo(VersionReader reader, string resVersion) {
        Dictionary<string, VersionAsset> targetDict = reader.dict;
        Dictionary<string, VersionAsset> addDict = new Dictionary<string, VersionAsset>();
        foreach (VersionAsset asset in dict.Values) {
            if (targetDict.ContainsKey(asset.Path)) {
                VersionAsset tAsset = targetDict[asset.Path];
                if (!asset.Md5.Equals(tAsset.Md5)) {
                    if (asset.patchVersion.Equals(resVersion)) {
                        addDict.Add(asset.Path, asset);
                    } else {
                        throw new Exception("资源PathVersion信息有误:" + asset.Path);
                    }
                }
            } else {
                addDict.Add(asset.Path, asset);
            }
        }
        return addDict;
    }
}

public class VersionAsset {

    private string path = null;
    private string size = null;
    private string md5 = null;
    public int sort = 50; // subpackage用到
    public string patchVersion = null;

    public string Path { get { return path; } }
    public string Size { get { return size; } }
    public string Md5 { get { return md5; } }
    public string PatchVersion { get { return patchVersion; } }

    public VersionAsset(string path, string size, string md5, string patchVersion) {
        this.path = path;
        this.size = size;
        this.md5 = md5;
        this.patchVersion = patchVersion;
    }

    public string ToVersionString() {
        if (md5 == null) {
            throw new System.Exception("md5为空: " + path);
        }
        StringBuilder filesb = new StringBuilder();
        filesb.Append("{");
        filesb.Append("\"path\":\"" + path + "\", ");
        filesb.Append("\"size\":\"" + size + "\", ");
        filesb.Append("\"md5\":\"" + md5 + "\", ");
        filesb.Append("\"patchVersion\":\"" + patchVersion + "\"");
        filesb.Append("}");
        return filesb.ToString();
    }

    public string ToVersionSortString() {
        if (md5 == null) {
            throw new System.Exception("md5为空: " + path);
        }
        StringBuilder filesb = new StringBuilder();
        filesb.Append("{");
        filesb.Append("\"path\":\"" + path + "\", ");
        filesb.Append("\"size\":\"" + size + "\", ");
        filesb.Append("\"sort\":\"" + sort + "\", ");
        filesb.Append("\"md5\":\"" + md5 + "\"");
        filesb.Append("}");
        return filesb.ToString();
    }
}
