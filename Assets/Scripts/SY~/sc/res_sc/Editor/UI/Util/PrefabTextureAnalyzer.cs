using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace EditorTools.UI {
    /// <summary>
    /// 分析prefab里的纹理
    /// </summary>
    public class PrefabTextureAnalyzer {
        private const string baseUITexturePath = "Assets/Things/ui/texture/";
        private const string baseUIPrefabPath = "Assets/Things/ui/prefab";
        private const string baseReportPath = "Assets/Resources/Report/UI";

        [MenuItem("Assets/Analyze All Prefab Textures", false, 1004)]
        public static void CheckAll() {
            string[] aryAssetGuids = Selection.assetGUIDs;
            string folderPath = null;
            if (aryAssetGuids != null && aryAssetGuids.Length == 1) {
                folderPath = AssetDatabase.GUIDToAssetPath(aryAssetGuids[0]);
            }

            if (string.IsNullOrEmpty(folderPath)) {
                Debug.LogFormat("<color=#ff0000>请选择[%s]下的文件夹</color>", baseUIPrefabPath);
                return;
            }

            if (!Directory.Exists(folderPath)) {
                Debug.LogFormat("<color=#ff0000>[{0}]可能是一个文件，请选择目录</color>", folderPath);
                return;
            }

            if (!folderPath.StartsWith(baseUIPrefabPath)) {
                Debug.LogFormat("<color=#ff0000>只能操作[{0}]下的目录</color>", baseUIPrefabPath);
                return;
            }

            //先收集所有ui prefab
            string[] paths = GetFiles(folderPath);
            List<string> aryPrefabPath = new List<string>();
            for (int j = 0; j < paths.Length; j++) {
                string filePath = paths[j];
                EditorUtility.DisplayProgressBar("收集Prefab文件中", "正在处理:" + filePath, (float)j / (float)paths.Length);
                if (filePath.EndsWith(".prefab", System.StringComparison.OrdinalIgnoreCase)) {
                    aryPrefabPath.Add(filePath);
                }
            }
            EditorUtility.ClearProgressBar();

            CreateBaseReportDirectory();
            //分析每一个prefab,分生成报告
            List<string> aryGather = new List<string>();
            for (int i = 0; i < aryPrefabPath.Count; i++) {
                string eachPrefabPath = aryPrefabPath[i];
                EditorUtility.DisplayProgressBar("分析Prefab文件中", "正在处理:" + eachPrefabPath, (float)i / (float)aryPrefabPath.Count);
                int packingTagCount = AnalyzerSingle(eachPrefabPath);
                aryGather.Add(string.Format("PackingTagCount:[{0}],Path:{1}", packingTagCount, eachPrefabPath));
            }
            aryGather.Sort();
            aryGather.Reverse();
            EditorUtility.ClearProgressBar();

            //生成汇总文件
            string gatherFile = baseReportPath + Path.DirectorySeparatorChar + "汇总.txt";
            File.WriteAllLines(gatherFile, aryGather.ToArray());
            AssetDatabase.ImportAsset(gatherFile, ImportAssetOptions.ForceUpdate);
            Debug.LogFormat("<color=#00ff00>全部分析报告生成完毕，请查看{0}</color>", gatherFile);
        }

        [MenuItem("Assets/Analyze Single Prefab Textures", false, 1003)]
        public static void CheckSingle() {
            string[] aryAssetGuids = Selection.assetGUIDs;
            string prefabPath = null;
//            string toFoundFileGUID = null;

            if (aryAssetGuids != null && aryAssetGuids.Length == 1) {
                prefabPath = AssetDatabase.GUIDToAssetPath(aryAssetGuids[0]);
//                toFoundFileGUID = aryAssetGuids[0];
            }

            if (string.IsNullOrEmpty(prefabPath)) {
                Debug.LogFormat("<color=#ff0000>请选择[%s]下的prefab文件</color>", baseUIPrefabPath);
                return;
            }

            if (!prefabPath.StartsWith(baseUIPrefabPath)) {
                Debug.LogFormat("<color=#ff0000>只能操作[{0}]下的文件</color>", baseUIPrefabPath);
                return;
            }

            if (!prefabPath.EndsWith(".prefab")) {
                Debug.Log("<color=#ff0000>只能操作prefab文件</color>");
                return;
            }
            CreateBaseReportDirectory();
            AnalyzerSingle(prefabPath);
        }

        private static int AnalyzerSingle(string prefabPath) {
            FileInfo prefabFile = new FileInfo(prefabPath);
            string folderPath = baseReportPath + Path.DirectorySeparatorChar + prefabFile.Directory.Name;
            if (!Directory.Exists(folderPath)) {
                Directory.CreateDirectory(folderPath);
            }

            //分析prefab，找出所有图片的guid
            HashSet<string> pngGuidResult = CheckByGUID(prefabPath);

            List<string> result = new List<string>();
            HashSet<string> totalPackingTag = new HashSet<string>();
            foreach (string guid in pngGuidResult) {
                string pngPath = AssetDatabase.GUIDToAssetPath(guid);
                if (string.IsNullOrEmpty(pngPath)){
                    continue;
                }
                string packingTag = GetTexturePackingTag(pngPath);
                if(packingTag != "Base" && packingTag != "Panel")
                {
                    //Debug.LogFormat("引用了：[{0}],tag:[{1}]", pngPath, packingTag);
                    result.Add(string.Format("packingTag:[{0}],png:[{1}]", packingTag, pngPath));
                    totalPackingTag.Add(packingTag);
                }
            }
            result.Sort();

            StringBuilder sb = new StringBuilder();
            sb.AppendFormat("共引用了{0}个PackingTag:", totalPackingTag.Count);
            foreach (string packingTag in totalPackingTag) {
                sb.AppendFormat("[{0}]", packingTag);
            }
            sb.AppendLine();

            foreach (string each in result) {
                sb.Append(each);
                sb.AppendLine();
            }

            string reportFile = folderPath + Path.DirectorySeparatorChar + prefabFile.Name + ".txt";
            File.WriteAllText(reportFile, sb.ToString());
            AssetDatabase.ImportAsset(reportFile, ImportAssetOptions.ForceUpdate);
            Debug.LogFormat("[{0}]分析报告生成完毕", prefabPath);
            return totalPackingTag.Count;
        }

        private static void CreateBaseReportDirectory() {
            if (!Directory.Exists(baseReportPath)) {
                Directory.CreateDirectory(baseReportPath);
            }
        }

        private static string CreatePrefabReportDirectory(string prefabPath) {
            FileInfo file = new FileInfo(prefabPath);
            string folderPath = baseReportPath + file.Directory.Name;
            if (!Directory.Exists(folderPath)) {
                Directory.CreateDirectory(folderPath);
            }
            return folderPath;
        }

        private static string[] GetFiles(string path, bool recursive = true) {
            var resultList = new List<string>();
            var dirArr = Directory.GetFiles(path, "*", recursive ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly);
            for (int i = 0; i < dirArr.Length; i++) {
                if (Path.GetExtension(dirArr[i]) != ".meta")
                    resultList.Add(dirArr[i].Replace('\\', '/'));
            }
            return resultList.ToArray();
        }

        private static string GetTexturePackingTag(string path) {
            try {
                TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter;
                return importer.spritePackingTag;
            } catch (Exception ex) {
                Debug.LogFormat("无法获取[{0}]的packingTag,原因：{1}", path, ex.Message);
            }
            return "";
        }

        private static HashSet<string> CheckByGUID(string prefabPath) {
            HashSet<string> result = new HashSet<string>();

            //逐行分析此prefab所包含的sprite(即碎图)
            //格式为m_Sprite: {fileID: 21300000, guid: 9ac24797df9ae3e45aa03125c2af9cc1, type: 3}
            using (StreamReader reader = new StreamReader(prefabPath)) {
                string line = null;
                while ((line = reader.ReadLine()) != null) {
                    if (line.StartsWith("  m_Sprite: {fileID:")) {
                        Match m = Regex.Match(line, @"  m_Sprite: {fileID: [-\d]*, guid: (?<guid>[0-9a-z]*)", RegexOptions.Compiled);
                        if (m.Success) {
                            string matchedGuid = m.Groups["guid"].Value;
                            result.Add(matchedGuid);
                        }
                    }
                }
            }
            return result;
        }
    }
}
