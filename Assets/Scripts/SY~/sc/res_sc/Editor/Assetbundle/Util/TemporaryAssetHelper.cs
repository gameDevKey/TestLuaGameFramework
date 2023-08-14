using System.IO;
using System.Collections.Generic;
using UnityEditor;
using Object = UnityEngine.Object;

namespace EditorTools.AssetBundle {
    public class TemporaryAssetHelper {
        public const string RESOURCES = "Assets/Things";
        public const string RESOURCES_TEMP = "Assets/Things_temp";

        /// <summary>
        /// 临时资源表，Key为临时资源路径
        /// </summary>
        private static Dictionary<string, Object> _tempAssetDict;
        private static HashSet<string> _assetPathSet;
        private static HashSet<string> _tempAssetPathSet;

        public static void Initialize() {
            _tempAssetDict = new Dictionary<string, Object>();
            _assetPathSet = new HashSet<string>();
            _tempAssetPathSet = new HashSet<string>();
        }

        public static string GetTempAssetPath(string path) {
            string tempAssetPath = path.Replace(RESOURCES, RESOURCES_TEMP);
            string folderPath = Path.GetDirectoryName(AssetPathHelper.ToFileSystemPath(tempAssetPath));
            if (Directory.Exists(folderPath) == false) {
                Directory.CreateDirectory(folderPath);
            }
            return tempAssetPath;
        }

        public static Object CreateTempAsset(string path) {
            string tempAssetPath = GetTempAssetPath(path);
            if (_tempAssetDict.ContainsKey(tempAssetPath) == true) {
                return _tempAssetDict[tempAssetPath];
            }

            AssetDatabase.DeleteAsset(tempAssetPath);
            AssetDatabase.CopyAsset(path, tempAssetPath);
            AssetDatabase.ImportAsset(tempAssetPath, ImportAssetOptions.ForceUpdate);
            Object asset = AssetDatabase.LoadAssetAtPath(tempAssetPath, typeof(Object));
            _tempAssetDict.Add(tempAssetPath, asset);
            _tempAssetPathSet.Add(tempAssetPath);
            _assetPathSet.Add(path);
            return asset;
        }

        public static void RecordTempAssetPath(string tempAssetPath) {
            _tempAssetPathSet.Add(tempAssetPath);
        }

        public static bool HasTempAsset(string tempAssetPath) {
            return _tempAssetPathSet.Contains(tempAssetPath);
        }

        public static bool HasCreatedTempAsset(string assetPath) {
            return _assetPathSet.Contains(assetPath);
        }

        public static void DeleteAllTempAsset() {
            if (AssetBuildStrategyManager.isSaveTemp == false) {
                foreach (string path in _tempAssetPathSet) {
                    AssetDatabase.DeleteAsset(path);
                }
            }
        }
    }
}
