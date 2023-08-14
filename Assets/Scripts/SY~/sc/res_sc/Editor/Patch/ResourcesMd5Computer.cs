using System;
using System.Text;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using LitJson;

using EditorTools.AssetBundle;
using EditorTools.UI;

namespace EditorTools.Patch {
    /// <summary>
    /// 通过和本地文件Md5值对比找出被修改的资源
    /// </summary>
    public class ResourcesMd5Computer {
        public static string BUILD_DETAIL_FILE_NAME = "_build_detail.json";
        public static string ROOT = "Assets/Things/";

        // private string mapDataPath = "../data/map/";
        private string luaDataPath = "../data/";
        private string luaPath = "../lua/";
        // 回写_build_detail.json
        public Dictionary<string, string> newResMd5 = null;
        public Md5Record md5Record = null;

        // 用于打包
        public List<string> assetResult = new List<string>();
        public List<string> dataResult = new List<string>();
        public List<string> luaResult = new List<string>();
        public List<string> mapResult = new List<string>();


        //计算所有整个资源目录下的资源的Md5值
        [MenuItem ("Assets/ForceUpdateResourcesMd5")]
        public static void ForceUpdateMd5Record () {
            ResourcesMd5Computer resMd5 = new ResourcesMd5Computer ();
            resMd5.DoForceUpdateMd5Record ();
        }

        public void DoForceUpdateMd5Record() {
            AssetBuildStrategyManager.Initialize();
            string md5Path = AssetBuildStrategyManager.outputPath + BUILD_DETAIL_FILE_NAME;
            Md5Record record = ReadMd5Record(md5Path);
            Dictionary<string, string> newValue = ComputeMd5(ROOT);
            WriteMd5(newValue, record, false);
            Debug.Log("DONE");
        }

        //[MenuItem("Assets/Find Modified Files")]
        // 比较原文件差异, 得出需要打包文件
        public void FindDiff() {
            AssetBuildStrategyManager.Initialize();
            string md5Path = AssetBuildStrategyManager.outputPath + BUILD_DETAIL_FILE_NAME;
            md5Record = ReadMd5Record(md5Path);
            Dictionary<string, string> oldValue = ReadMd5(md5Record);

            // 扫描文件
            Dictionary<string, string> newValue = ComputeMd5(ROOT);
            ComputeDataMd5 (newValue, luaPath);
            ComputeDataMd5 (newValue, luaDataPath);
            // ComputeDataMd5 (newValue, mapDataPath);
            newResMd5 = newValue;
            Diff(newValue, oldValue);
            // if (modifiedList.Count > 0) {
            //     WriteMd5(newValue, md5Record);
            // }
            // return modifiedList;
        }

        /// <summary>
        /// 返回新增和被修改的文件列表
        /// </summary>
        /// <param name="newValue"></param>
        /// <param name="oldValue"></param>
        /// <returns></returns>
        private void Diff(Dictionary<string, string> newValue, Dictionary<string, string> oldValue) {
            assetResult = new List<string>();
            dataResult = new List<string>();
            luaResult = new List<string>();
            mapResult = new List<string>();
            foreach (string s in newValue.Keys) {
                if (oldValue.Keys.Contains(s) == false) {
                    // result.Add(s);
                    SetResultList (s, assetResult, dataResult, luaResult, mapResult);
                    continue;
                }
                if (newValue[s] != oldValue[s]) {
                    SetResultList (s, assetResult, dataResult, luaResult, mapResult);
                    // result.Add(s);
                }
            }
            // return result;
        }

        private void SetResultList (string path, List<string> assetResult, List<string> dataRsult, List<string> luaResult, List<string> mapResult) {
            if (path.StartsWith ("data/")) {
                dataRsult.Add (path);
            } else if (path.StartsWith ("lua/")) {
                luaResult.Add (path);
            } else {
                assetResult.Add (path);
            }

        }

        /// <summary>
        /// 计算资源的Md5
        /// Key为资源的路径，Value为资源文件及其对应的Meta文件Md5转Base64字符串连接后结果
        /// </summary>
        /// <param name="folderRoot"></param>
        /// <returns></returns>
        private Dictionary<string, string> ComputeMd5(string folderRoot){
            Dictionary<string, string> result = new Dictionary<string, string>();
            MD5 md5 = MD5.Create();
            foreach (string s in GetFilteredPathList(folderRoot)) {
                byte[] fileData = md5.ComputeHash(File.ReadAllBytes(s));
                string metaPath = s + ".meta";
                byte[] metaData = null;
                if (File.Exists(metaPath) == true) {
                    metaData = md5.ComputeHash(File.ReadAllBytes(metaPath));
                }
                string fileToken = Convert.ToBase64String(fileData);
                string metaToken = string.Empty;
                if (metaData != null) {
                    metaToken = Convert.ToBase64String(metaData);
                }
                result.Add(s, fileToken + metaToken);
            }
            return result;
        }

        private void ComputeDataMd5 (Dictionary<string, string> srcDict, string folderRoot) {
            Dictionary<string, string> result = new Dictionary<string, string>();
            MD5 md5 = MD5.Create();
            string path = null;
            foreach (string s in GetFilteredPathList (folderRoot)) {
                if (s.EndsWith (".map")) 
                {
                    byte[] fileData = md5.ComputeHash(File.ReadAllBytes(s));
                    string fileToken = Convert.ToBase64String(fileData);
                    path = s.Substring (s.IndexOf ("data/") + 5);
                    srcDict.Add (path, fileToken);
                }
                else if (s.EndsWith (".lua")) 
                {
                    if (s.Contains ("data/")) {
                        byte[] fileData = md5.ComputeHash(File.ReadAllBytes(s));
                    	string fileToken = Convert.ToBase64String(fileData);
                        path = "data/" + s.Substring (s.IndexOf ("data/") + 5);
                    	srcDict.Add (path, fileToken);
                    } else {
                        byte[] fileData = md5.ComputeHash(File.ReadAllBytes(s));
                    	string fileToken = Convert.ToBase64String(fileData);
                        path = "lua/" + s.Substring (s.IndexOf ("/lua/") + 5);
                    	srcDict.Add (path, fileToken);
                    }
                }
            }
        }

        //获取资源目录下所有资源文件，过滤掉不需要处理的可能存在的UIPrefab中间文件
        private List<string> GetFilteredPathList(string folderRoot) {
            string[] filePaths = Directory.GetFiles(folderRoot, "*.*", SearchOption.AllDirectories);
            List<string> filteredPathList = new List<string>();
            for (int i = 0; i < filePaths.Length; i++) {
                string path = filePaths[i];
                if (path.Contains(".meta") == true) continue;
                path = path.Replace("\\", "/");
                if (UIPrefabProcessor.UI_PREFAB_ROOT_SHADOW_PATTERN.IsMatch(path) == true
                    || UIPrefabProcessor.UI_TEXTURE_ROOT_SHADOW_PATTERN.IsMatch(path) == true) continue;

                filteredPathList.Add(path);
            }
            return filteredPathList;
        }

        private Md5Record ReadMd5Record(string path) {
            
            if (File.Exists(path) == true) {
                string content = File.ReadAllText(path);
                return JsonMapper.ToObject<Md5Record>(content);
            }
            Md5Record record = new Md5Record();
            record.value = new Dictionary<string, string>();
            return record;
        }

        private Dictionary<string, string> ReadMd5(Md5Record record) {
            return record.value;
        }

        public void WriteMd5(Dictionary<string, string> newValue, Md5Record record, bool isDataOnly) {
            string path = AssetBuildStrategyManager.outputPath + BUILD_DETAIL_FILE_NAME;
            Dictionary<string, string> oldVale = record.value;
            record.value = newValue;
            Md5Record wrideRecord = new Md5Record();
            if (!isDataOnly) {
                wrideRecord.value = newValue;
            } else {
                Dictionary<string, string> dataOnlyDict = new Dictionary<string, string>();
                foreach (string key in oldVale.Keys) {
                    if (!key.StartsWith("map/") && !key.StartsWith("lua/") && !key.StartsWith("data/")) {
                        dataOnlyDict.Add(key, oldVale[key]);
                    }
                }
                foreach (string key in newValue.Keys) {
                    if (key.StartsWith("map/") || key.StartsWith("lua/") || key.StartsWith("data/")) {
                        dataOnlyDict.Add(key, newValue[key]);
                    }
                }
                wrideRecord.value = dataOnlyDict;
            }
            string content = JsonMapper.ToJson(wrideRecord);
            if (File.Exists(path) == true) {
                File.Delete(path);
            }
            if (string.IsNullOrEmpty(content) == false) {
                content = content.Replace("\"Assets/Things/", "\n\"Assets/Things/");
                content = content.Replace("\"lua/", "\n\"lua/");
                content = content.Replace("\"map/", "\n\"map/");
                content = content.Replace("\"data/", "\n\"data/");
                File.WriteAllText(path, content);
            }
        }
    }

    public class Md5Record {
        public Dictionary<string, string> value;
    }
}
