using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using UnityEngine;
using UnityEditor;
using Object = UnityEngine.Object;

namespace EditorTools.AssetBundle {
    public class AssetBundleBuilder {
        public const string FONT_TTF = ".ttf";
        public const string SHADER_BUNDLE_NAME = "shader.folder";
        public const string SHARED_BUNDLE_NAME = "shared.folder";
        public const string SHADER_FOLDER_NAME = "Things/shader";
        public const string SHARED_PREFAB_NAME = "Container_Shared.prefab";

        //Key为生成AssetBundle文件名，Value为与之对应的AssetBundleBuild定义
        private static Dictionary<string, AssetBundleBuildWrapper> _assetBundleBuildDict;

        public static void Initialize() {
            _assetBundleBuildDict = new Dictionary<string, AssetBundleBuildWrapper>();
        }

        /// <summary>
        /// 返回Key为打包的资源路径，Value为bundlePath的Dictionary
        /// </summary>
        /// <param name="entryPath"></param>
        /// <param name="assetPathList"></param>
        /// <param name="node"></param>
        /// <returns></returns>
        public static Dictionary<string, string> Add(string entryPath, List<string> assetPathList, StrategyNode node) {
            Dictionary<string, string> result = new Dictionary<string, string>();
            if (assetPathList.Count == 0) {
                return result;
            }
            switch (node.mode) {
                case PackageMode.SINGLE:
                    result = BuildSingleMode(entryPath, assetPathList, node);
                    break;
                case PackageMode.SELECTION:
                    result = BuildSelectionMode(entryPath, assetPathList, node);
                    break;
                case PackageMode.FOLDER:
                    result = BuildFolderMode(entryPath, assetPathList, node);
                    break;
            }
            return result;
        }

        private static Dictionary<string, string> BuildSingleMode(string entryPath, List<string> assetPathList, StrategyNode node) {

            Dictionary<string, string> result = new Dictionary<string, string>();
            for (int i = 0; i < assetPathList.Count; i++) {
                string assetPath = assetPathList[i];
                string bundlePath = AssetPathHelper.GetSingleModeBundlePath(assetPath);
                result.Add(assetPath, bundlePath);
                if (CanBuild(entryPath, bundlePath) == false) {
                    continue;
                }
                AddAssetBundleBuildWrapper(assetPath, bundlePath, new string[] { assetPath }, node);
            }
            return result;
        }

        private static Dictionary<string, string> BuildSelectionMode(string entryPath, List<string> assetPathList, StrategyNode node) {
            Dictionary<string, string> result = new Dictionary<string, string>();
            string bundlePath = AssetPathHelper.GetSelectionModeBundlePath(entryPath, assetPathList, node.pattern);
            foreach (string s in assetPathList) {
                result.Add(s, bundlePath);
            }

            if (CanBuild(entryPath, bundlePath) == false) {
                return result;
            }
            //TODO:验证Selection中存在不同路径下，同类型同名但是内容不同时可能引起的问题
            VerifySelectionAssets(assetPathList);
            AddAssetBundleBuildWrapper(entryPath, bundlePath, assetPathList.ToArray(), node);
            return result;
        }

        private static void VerifySelectionAssets(List<string> assetPathList) {
            List<Object> assetList = new List<Object>();
            for (int i = 0; i < assetPathList.Count; i++) {
                Object asset = AssetDatabase.LoadAssetAtPath(assetPathList[i], typeof(Object));
                assetList.Add(asset);
                assetList.AddRange(GetDependAssets(assetPathList[i]));
            }
            HashSet<string> set = new HashSet<string>();
            for (int i = 0; i < assetList.Count; i++) {
                Object asset = assetList[i];
                string key = asset.GetType().Name + asset.name;
                if (set.Contains(key) == true) {
                    string msg = "Selection资源集合中存在同类型同名资源~~~ " + asset.name;
                    AssetBundleExporter.ThrowException(msg);
                }
            }
        }

        private static Object[] GetDependAssets(string assetPath) {
            string[] paths = AssetDatabase.GetDependencies(new string[] { assetPath });
            Object[] objs = new Object[paths.Length - 1];
            int index = 0;
            foreach (string s in paths) {
                if (s != assetPath) {
                    objs[index] = AssetDatabase.LoadAssetAtPath(s, typeof(Object));
                    index++;
                }
            }
            return objs;
        }

        private static Dictionary<string, string> BuildFolderMode(string entryPath, List<string> assetPathList, StrategyNode node) {
            Dictionary<string, string> result = new Dictionary<string, string>();
            Dictionary<string, List<string>> splitPathListDict = SplitAssetPathList(assetPathList, node);
            foreach (string k in splitPathListDict.Keys) {
                string bundlePath = AssetPathHelper.GetFolderModeBundlePath(splitPathListDict[k], node.pattern);
                string[] folderAssetPaths = GetFolderModeAssetPaths(splitPathListDict[k], node);
                foreach (string s in folderAssetPaths) {
                    result.Add(s, bundlePath);
                }
                if (CanBuild(entryPath, bundlePath) == false) {
                    continue;
                }

                AddAssetBundleBuildWrapper(entryPath, bundlePath, folderAssetPaths, node);
            }
            
            return result;
        }

        //Folder模式下，匹配结果根据正则表达式中子模式path值的不同，可以分成多组
        private static Dictionary<string, List<string>> SplitAssetPathList(List<string> assetPathList, StrategyNode node) {
            Dictionary<string, List<string>> result = new Dictionary<string, List<string>>();
            foreach (string s in assetPathList) {
                GroupCollection gc = node.pattern.Match(s).Groups;
                string path = gc["path"].Value;
                if (result.Keys.Contains(path) == false) {
                    result.Add(path, new List<string>() { s });
                } else {
                    result[path].Add(s);
                }
            }
            return result;
        }

        private static string[] GetFolderModeAssetPaths(List<string> assetPathList, StrategyNode node) {
            string folderPath = AssetPathHelper.GetFolderModeStartPath(assetPathList[0], node.pattern);
            string systemFolderPath = AssetPathHelper.ToFileSystemPath(folderPath);
            string[] filePaths = Directory.GetFiles(systemFolderPath, "*.*", SearchOption.AllDirectories);
            List<string> filteredPathList = new List<string>();
            for (int i = 0; i < filePaths.Length; i++) {
                filePaths[i] = filePaths[i].Replace(@"\", @"/");
                if (filePaths[i].Contains(".meta") == false && node.pattern.IsMatch(filePaths[i]) == true) {
                    filteredPathList.Add(AssetPathHelper.ToAssetPath(filePaths[i]));
                }
            }
            return filteredPathList.ToArray();
        }

        private static void AddAssetBundleBuildWrapper(string entryPath, string bundlePath, string[] assetNames, StrategyNode node) {
            AssetBundleBuild build = new AssetBundleBuild();
            build.assetBundleName = bundlePath;
            build.assetNames = assetNames;
            AssetBundleBuildWrapper wrapper = new AssetBundleBuildWrapper();
            wrapper.build = build;
            wrapper.bundlePath = bundlePath;
            wrapper.entryPath = entryPath;
            wrapper.node = node;
            _assetBundleBuildDict.Add(bundlePath, wrapper);
        }

        public static void Build() {
            if (AssetBuildStrategyManager.isBuild == true) {
                AssetBundleBuild[] builds = GetBuilds();
                if (builds.Length == 0) {
                    Logger.GetLogger(AssetBundleExporter.LOGGER_NAME).Warning("需要打包的文件列表为空~~");
                } else {
                    BuildPipeline.BuildAssetBundles(AssetBuildStrategyManager.outputPath, builds, GetBuildOptions(), GetBuildTarget());
                }
            }
        }

        private static AssetBundleBuild[] GetBuilds() {
            AssetBundleBuild[] builds = new AssetBundleBuild[_assetBundleBuildDict.Count];
            int index = 0;
            foreach (AssetBundleBuildWrapper wrapper in _assetBundleBuildDict.Values) {
                builds[index++] = wrapper.build;
            }
            return builds;
        }

        public static void LogBuildResult() {
            if (AssetBuildStrategyManager.isReport == true) {
                StringBuilder sb = new StringBuilder();
                foreach (AssetBundleBuildWrapper wrapper in _assetBundleBuildDict.Values) {
                    sb.Append(Log(wrapper.entryPath, wrapper.bundlePath, wrapper.node));
                    sb.Append("\n\n");
                }
                EditorUtility.DisplayDialog("打包结果： ", sb.ToString(), "朕知道了~");
            } else {
                foreach (AssetBundleBuildWrapper wrapper in _assetBundleBuildDict.Values) {
                    // Log(wrapper.entryPath, wrapper.bundlePath, wrapper.node);
                }
            }
        }

        public static void BuildAssetRecord() {
            BuildPipeline.BuildAssetBundles(AssetBuildStrategyManager.outputPath, new AssetBundleBuild[] { CreateAssetRecordBuild() }, GetBuildOptions(), GetBuildTarget());
        }

        private static AssetBundleBuild CreateAssetRecordBuild() {
            AssetBundleBuild build = new AssetBundleBuild();
            build.assetBundleName = AssetRecordHelper.ASSET_RECORD_NAME;
            build.assetNames = new string[] { AssetRecordHelper.ASSET_RECORD_PATH };
            return build;
        }

        private static bool CanBuild(string entryPath, string bundlePath) {
            if (AssetBuildStrategyManager.isBuild == false) {
                return false;
            }
            if (_assetBundleBuildDict.ContainsKey(bundlePath) == true) {
                return false;
            }
            return true;
        }

        public static BuildAssetBundleOptions GetBuildOptions() {
            return BuildAssetBundleOptions.DeterministicAssetBundle | BuildAssetBundleOptions.ChunkBasedCompression;
        }

        public static BuildTarget GetBuildTarget() {
            return AssetPathHelper.GetBuildTarget ();
        }

        private static string Log(string entryPath, string bundlePath, StrategyNode node) {
            string outputPath = AssetPathHelper.GetOutputPath(bundlePath);
            string content = string.Format("策略名称： {0}\n模式: {1}\n入口: {2}\nProcessor: {3}\nPattern: {4}\n输出: {5}\n体积: {6}KB", node.strategy, node.mode, entryPath, node.processor, node.pattern, bundlePath, GetFileSize(outputPath).ToString());
            Logger.GetLogger(AssetBundleExporter.LOGGER_NAME).Log(content);
            return content;
        }

        private static int GetFileSize(string path) {
            FileInfo info = new FileInfo(path);
            if (info.Exists == false) {
                Logger.GetLogger(AssetBundleExporter.LOGGER_NAME).Error("未找到文件: " + path);
                return 0;
            }
            return Mathf.CeilToInt(info.Length / 1024.0f);
        }
    }

    struct AssetBundleBuildWrapper {
        public AssetBundleBuild build;
        public string entryPath;
        public string bundlePath;
        public StrategyNode node;
    }
}