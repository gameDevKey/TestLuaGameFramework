using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;
using EditorTools.UI;
using System.Collections;


using Object = UnityEngine.Object;

namespace EditorTools.AssetBundle {
    public class AssetBundleExporter {
        internal const string LOGGER_NAME = "AssetBundle";
        //这些目录下的资源不进行打包
        internal static string[] IGNORE_PATHS = new string[] { "Assets/Things/data", "Assets/Things_temp" };

        private static HashSet<string> _processedAssetPathSet;

        [MenuItem("Assets/Build AssetBundle From Selection")]
        public static void BuildFromSelection() {
            AssetPathHelper.buildTarget = EditorUserBuildSettings.activeBuildTarget;
            AssetPathHelper.patchVersion = DateTime.Now.ToString ("yyyyMMddHHmmss");
            Initialize();
            BuildAssets(GetSelectedAssetPathList());
        }

        private static void Initialize() {
            TemporaryAssetHelper.Initialize();
            MaterialJsonData.Initialize();
            AssetBuildStrategyManager.Initialize();
            AssetBundleBuilder.Initialize();
            AssetRecordHelper.ReadAssetRecord();
            Logger.GetLogger(LOGGER_NAME).Level = Logger.LEVEL_LOG;
            _processedAssetPathSet = new HashSet<string>();
        }

        private static List<string> GetSelectedAssetPathList() {
            Object[] objs = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);
            List<string> result = new List<string>();
            foreach (Object obj in objs) {
                string path = AssetDatabase.GetAssetPath(obj);
                if (VerifyAssetPath(path) == true) {
                    result.Add(path);
                }
            }
            return result;
        }

        public static bool VerifyAssetPath(string path) {
            if (Path.GetExtension(path) == string.Empty) {
                return false;
            }
            foreach (string s in IGNORE_PATHS) {
                if (path.Contains(s) == true) {
                    Logger.GetLogger(LOGGER_NAME).Log(string.Format("<color=#0000ff>路径 {0} 资源设置为不需要打包！</color>", path));
                    return false;
                }
            }
            return true;
        }

        /// <summary>
        /// 输入：依赖了修改资源的资源列表字典
        /// 返回：Key为修改资源路径，Value修改资源所在bundlePath列表
        /// 注意存在两种情况：
        /// 1.修改的资源被分离独立打包，如贴图资源，这种情况返回一个bundlePath
        /// 2.修改的资源被合并打包，如材质资源合并在Prefab中进行打包，这种情况返回所有依赖该材质的Prefab打包后的BundlePath列表
        /// </summary>
        /// <param name="relierPathListDict"></param>
        public static Dictionary<string, List<string>> BuildPatchAssets(Dictionary<string, List<string>> relierPathListDict) {
            Initialize();
            AssetBuildStrategyManager.isReport = false;
            Dictionary<string, List<List<string>>> mergedSplitPathListListDict = GetMergedSplitPathListListDict(relierPathListDict);
            AssetDatabase.SaveAssets();
            Dictionary<string, string> bundlePathDict = BuildAssets(mergedSplitPathListListDict);
            AssetRecordHelper.WriteAssetRecord();
            AssetBundleBuilder.BuildAssetRecord();
            TemporaryAssetHelper.DeleteAllTempAsset();
            if (AssetBuildStrategyManager.isSaveUIMediate == false) {
                UIPrefabProcessor.DeleteMediate();
            }
            if(AssetBuildStrategyManager.isDelunusedAssetBundle)
            {
                DelUnusedAssetBundle();
            }
            AssetBundleBuilder.LogBuildResult();
            return GetBundlePathListDict(relierPathListDict, bundlePathDict);
        }

        public static void DelUnusedAssetBundle()
        {
            Debug.Log("检查没有用的AssetBundle");

            if(!Directory.Exists(AssetBuildStrategyManager.unusedOutputPath))
            {
                Directory.CreateDirectory(AssetBuildStrategyManager.unusedOutputPath);
            }
            
            string[] names = Directory.GetFiles(AssetBuildStrategyManager.outputPath);
            for(int i = 0; i < names.Length; i++)
            {
                string name = names[i];

                if(name.Contains("textures$business.folder") || name.Contains("textures$business_data.folder"))
                {
                    continue;
                }

                if (name.EndsWith(".manifest"))
                {
                    CheckAssetUnused(name);
                }
            }
        }

        public static void CheckAssetUnused(string path)
        {
            string[] lines = File.ReadAllLines(path);
            int start = 0;
            int end = 0;
            for(int i = 0; i < lines.Length; i++)
            {
                if(lines[i].StartsWith("Assets:"))
                {
                    start = i;
                }
                if(lines[i].StartsWith("Dependencies:"))
                {
                    end = i;
                }
            }

            bool isDel = start >0 && end > 0;
            List<string> list = new List<string>();
            for(int i = start + 1; i < end; i++)
            {
                string line = lines[i].Replace("- ", "");
                string filePath = Application.dataPath + line.Replace("Assets", "");
                filePath = filePath.Replace("Things_temp", "Things");
                if(filePath.Contains("Things/ui/texture"))
                {
                    //图集不处理
                }
                else
                {
                    filePath = filePath.Replace("UI_pc", "UI");
                    filePath = filePath.Replace("UI_android", "UI");
                    filePath = filePath.Replace("UI_ios", "UI");
                }

                if (File.Exists(filePath))
                {
                    isDel = false;
                    break;
                }
            }

            if(isDel)
            {

                string name = Path.GetFileName(path);
                string tempPath = AssetBuildStrategyManager.unusedOutputPath + name;
                if(File.Exists(tempPath))
                {
                    File.Delete(tempPath);
                }
                File.Move(path, tempPath);

                string bundlePath = path.Replace(".manifest", "");
                string bundleName = Path.GetFileName(bundlePath);
                string tempBundlePath = AssetBuildStrategyManager.unusedOutputPath + bundleName;
                if (File.Exists(tempBundlePath))
                {
                    File.Delete(tempBundlePath);
                }
                File.Move(bundlePath, tempBundlePath);
                Debug.Log("删除 " + bundlePath);

                //if (File.Exists(bundlePath))
                //{
                //    File.Delete(bundlePath);
                //}
                //File.Delete(path);
            }

        }

        /// <summary>
        /// Key为修改的资源路径
        /// Value为修改的资源导致的生成的AssetBundle文件列表
        /// </summary>
        /// <param name="relierPathListDict"></param>
        /// <param name="bundlePathDict"></param>
        /// <returns></returns>
        private static Dictionary<string, List<string>> GetBundlePathListDict(Dictionary<string, List<string>> relierPathListDict, Dictionary<string, string> bundlePathDict) {
            Dictionary<string, List<string>> result = new Dictionary<string, List<string>>();
            foreach (string k in relierPathListDict.Keys) {
                if (bundlePathDict.ContainsKey(k) == true) {
                    result.Add(k, new List<string>() { bundlePathDict[k] });
                } else {
                    List<string> relierPathList = relierPathListDict[k];
                    List<string> bundlePathList = new List<string>();
                    foreach (string s in relierPathList) {
                        //relierPathList中有些路径没有定义打包策略，没有对应的bundlePath
                        if (bundlePathDict.ContainsKey(s) == true) {
                            bundlePathList.Add(bundlePathDict[s]);
                        }
                    }
                    result.Add(k, bundlePathList);
                }
            }
            return result;
        }

        private static Dictionary<string, List<List<string>>> GetMergedSplitPathListListDict(Dictionary<string, List<string>> relierPathListDict) {
            Dictionary<string, List<List<string>>> result = new Dictionary<string, List<List<string>>>();
            foreach (string s in relierPathListDict.Keys) {
                Dictionary<string, List<List<string>>> splitPathListListDict = GetSplitPathListListDict(relierPathListDict[s]);
                foreach (string relierPath in splitPathListListDict.Keys) {
                    //key为relierPath，Value为其各策略节点分离的资源列表
                    result.Add(relierPath, splitPathListListDict[relierPath]);
                }
            }
            return result;
        }

        private static void BuildAssets(List<string> selectedPathList) {
            Dictionary<string, List<List<string>>> splitPathListListDict = GetSplitPathListListDict(selectedPathList);
            AssetDatabase.SaveAssets();
            BuildAssets(splitPathListListDict);
            AssetRecordHelper.WriteAssetRecord();
            AssetBundleBuilder.BuildAssetRecord();
            TemporaryAssetHelper.DeleteAllTempAsset();
            if (AssetBuildStrategyManager.isSaveUIMediate == false) {
                UIPrefabProcessor.DeleteMediate();
            }
            AssetBundleBuilder.LogBuildResult();
        }

        /// <summary>
        /// 返回资源按策略节点分离后结果表
        /// Key为入口资源
        /// Value为资源按策略节点分离后的列表的列表
        /// </summary>
        /// <param name="assetPathList"></param>
        /// <returns></returns>
        private static Dictionary<string, List<List<string>>> GetSplitPathListListDict(List<string> assetPathList) {
            UIPrefabProcessor.ClearCache();
            Dictionary<string, List<List<string>>> result = new Dictionary<string, List<List<string>>>();
            string assetPath = null;
            foreach (string path in assetPathList) {
                if (IsBuildStrategyExists(path) == true
                    && result.ContainsKey(path) == false
                    && _processedAssetPathSet.Contains(path) == false) {
                        _processedAssetPathSet.Add(path);
                    assetPath = path;
                    if (path.StartsWith(UIPrefabProcessor.UI_PREFAB_ROOT) == true) {
                        assetPath = UIPrefabProcessor.Process(path);
                    }
                    List<List<string>> pathListList = ProcessAsset(assetPath);
                    result.Add(path, pathListList);
                }
            }
            return result;
        }

        private static bool IsBuildStrategyExists(string entryPath) {
            AssetBuildStrategy strategy = AssetBuildStrategyManager.GetAssetBuildStrategy(entryPath, false);
            if (strategy == null) {
                // Logger.GetLogger(LOGGER_NAME).Log(string.Format("<color=#0000ff>未找到路径 {0} 对应的打包策略配置！</color>", entryPath));
                return false;
            }
            return true;
        }

        private static List<List<string>> ProcessAsset(string path) {
            AssetBuildStrategy strategy = AssetBuildStrategyManager.GetAssetBuildStrategy(path);
            if (strategy != null) {
                return AssetProcessor.ProcessAsset(path, strategy);
            }
            return new List<List<string>>();
        }

        /// <summary>
        /// 返回Key为资源path，Value为该资源所在的BundlePath字典
        /// </summary>
        /// <param name="splitPathListListDict"></param>
        /// <returns></returns>
        private static Dictionary<string, string> BuildAssets(Dictionary<string, List<List<string>>> splitPathListListDict) {
            Dictionary<string, string> result = new Dictionary<string, string>();
            foreach (string entryPath in splitPathListListDict.Keys) {
                List<List<string>> assetPathListList = splitPathListListDict[entryPath];
                List<StrategyNode> nodeList = AssetBuildStrategyManager.GetAssetBuildStrategy(entryPath).nodeList;
                HashSet<string> bundlePathSet = new HashSet<string>();
                for (int i = 0; i < assetPathListList.Count; i++) {
                    Dictionary<string, string> bundlePathDict = AssetBundleBuilder.Add(entryPath, assetPathListList[i], nodeList[i]);
                    foreach (string k in bundlePathDict.Keys) {
                        string path = ReplaceTemparyPath(k);
                        if (result.ContainsKey(path) == false) {
                            result.Add(path, bundlePathDict[k]);
                        }
                        bundlePathSet.Add(bundlePathDict[k]);
                    }
                }
                AssetRecordHelper.RecordAssetDependency(entryPath, bundlePathSet.ToList<string>());
            }
            AssetBundleBuilder.Build();
            return result;
        }

        /// <summary>
        /// 将记录中临时资源的路径替换为原始资源路径
        /// 包括:
        /// 1.打包过程中在Resources_temp下生成的临时文件
        /// 2.UI预处理过程中产生的临时文件
        /// </summary>
        /// <param name="tempPath"></param>
        /// <returns></returns>
        private static string ReplaceTemparyPath(string tempPath) {
            //处理含有Resource_temp的路径
            string result = tempPath.Replace(TemporaryAssetHelper.RESOURCES_TEMP, TemporaryAssetHelper.RESOURCES);
            //处理含有UI_{BuildTarget}的路径
            result = result.Replace(UIPrefabProcessor.GetShadowPrefabFolderRoot(), UIPrefabProcessor.UI_PREFAB_ROOT);
            return result;
        }

        public static Logger Logger {
            get {
                return Logger.GetLogger(AssetBundleExporter.LOGGER_NAME);
            }
        }

        public static void ThrowException(string msg) {
            EditorUtility.DisplayDialog("错误", msg, "马上调整Go~");
            throw new Exception(msg);
        }
    }
}
