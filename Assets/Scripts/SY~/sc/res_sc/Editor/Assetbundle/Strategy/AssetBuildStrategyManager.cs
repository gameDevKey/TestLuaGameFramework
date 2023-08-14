using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Xml;
using UnityEditor;
using UnityEngine;

namespace EditorTools.AssetBundle {
    public class AssetBuildStrategyManager {
        public const string SETTING_PATH = "Assets/build.xml";

        //缓存查询结果
        private static Dictionary<string, AssetBuildStrategy> _assetStrategyDict;
        //解析build.xml中定义的策略
        private static Dictionary<string, AssetBuildStrategy> _definedStrategyDict;
        public static string outputPath;
        public static string unusedOutputPath;
        public static bool isSaveTemp;
        public static bool isBuild;
        public static bool isReport;
        public static bool isSaveUIMediate;
        public static bool isDelunusedAssetBundle;

        public static void Initialize() {
            Dictionary<BuildTarget, string> buildTargetIdentifierDict = GetBuildTargetIdentifierDict();
            _assetStrategyDict = new Dictionary<string, AssetBuildStrategy>();
            _definedStrategyDict = new Dictionary<string, AssetBuildStrategy>();
            XmlDocument xmlDoc = new XmlDocument();
            xmlDoc.PreserveWhitespace = false;
            xmlDoc.Load(AssetPathHelper.ToFileSystemPath(SETTING_PATH));
            XmlNode root = xmlDoc.SelectSingleNode("root");
            outputPath = root.Attributes["output"].Value + buildTargetIdentifierDict[AssetPathHelper.GetBuildTarget()] + "/";
            unusedOutputPath = root.Attributes["output"].Value + buildTargetIdentifierDict[AssetPathHelper.GetBuildTarget()] + "_del/";
            CreateOutputFolder(outputPath);
            isSaveTemp = root.Attributes["saveTempFile"].Value.ToLower() == "true";
            isBuild = root.Attributes["build"].Value.ToLower() == "true";
            isReport = root.Attributes["report"].Value.ToLower() == "true";
            isSaveUIMediate = root.Attributes["saveUIMediate"].Value.ToLower() == "true";
            isDelunusedAssetBundle = root.Attributes["delUnusedAssetBundle"].Value.ToLower() == "true";
            foreach (XmlNode node in root.ChildNodes) {
                if (!(node is XmlElement)) {
                    continue;
                }
                AssetBuildStrategy strategy = new AssetBuildStrategy(node);
                if (string.IsNullOrEmpty(strategy.name) == true) {
                    throw new Exception("Build strategy name not set " + node.InnerText);
                }
                if (_definedStrategyDict.Keys.Contains(strategy.name) == true) {
                    throw new Exception("Duplicated strategy name: " + strategy.name);
                }
                _definedStrategyDict.Add(strategy.name, strategy);
            }
        }

        public static AssetBuildStrategy GetAssetBuildStrategy(string entryPath, bool showLog = true) {
            if (_assetStrategyDict.ContainsKey(entryPath) == true) {
                return _assetStrategyDict[entryPath];
            }
            foreach (AssetBuildStrategy strategy in _definedStrategyDict.Values) {
                if (strategy.entryPattern.IsMatch(entryPath) == true) {
                    if (showLog) Logger.GetLogger(AssetBundleExporter.LOGGER_NAME).Log(string.Format("<color=#0000ff>Path: {0} Matches Strategy: {1}</color>", entryPath, strategy.name));
                    _assetStrategyDict.Add(entryPath, strategy);
                    return strategy;
                }
            }
            if (showLog) Logger.GetLogger(AssetBundleExporter.LOGGER_NAME).Log(string.Format("<color=#0000ff>Path: {0} 未找到匹配的打包策略！</color>", entryPath));
            return null;
        }

        private static Dictionary<BuildTarget, string> GetBuildTargetIdentifierDict() {
            return AssetPathHelper.GetBuildTargetIdentifierDict ();
        }

        private static void CreateOutputFolder(string path) {
            if (Directory.Exists(path) == false) {
                Directory.CreateDirectory(path);
            }
        }
    }
}
