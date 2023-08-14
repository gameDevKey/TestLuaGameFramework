using System;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using EditorTools.AssetBundle;
using Object = UnityEngine.Object;

namespace EditorTools.UI {
    public class UIPrefabProcessor {

        public static bool IS_DELETE_MEDIATE = true;
        /// <summary>
        /// UIPrefab根路径
        /// </summary>
        public static string UI_PREFAB_ROOT = "Assets/Things/ui/prefab/";
        /// <summary>
        /// UIPrefab副本根路径
        /// </summary>
        public static string UI_PREFAB_ROOT_SHADOW = "Assets/Things/ui/prefab_{0}/";

        public static Regex UI_PREFAB_ROOT_SHADOW_PATTERN = new Regex("Assets/Things/ui/prefab_.*?/", RegexOptions.IgnoreCase);

        /// <summary>
        /// UIPrefab中单张图片列表目录根路径
        /// </summary>
        public static string UI_TEXTURE_ROOT = "Assets/Things/ui/texture/";
        /// <summary>
        /// UIPrefab依赖图片资源合并图集目录根路径
        /// </summary>
        public static string UI_TEXTURE_ROOT_SHADOW = "Assets/Things/ui/texture_{0}/";
        public static Regex UI_TEXTURE_ROOT_SHADOW_PATTERN = new Regex("Assets/Things/ui/texture_.*?/", RegexOptions.IgnoreCase);


        public static string UI_SINGLE_ROOT = "Assets/Things/ui/single/";

        //[MenuItem("Assets/Process UI Prefab")]
        public static void Main() {
            string prefabPath = GetSelectedPrefabPath();
            if (string.IsNullOrEmpty(prefabPath)) {
                Debug.LogError("请正确选择 " + UI_PREFAB_ROOT + " 目录下的UI面板Prefab资源！");
                return;
            }
            Process(prefabPath);
        }

        public static string Process(string prefabPath) {
            //获得Prefab依赖的单张图片列表的目录，可能存在多个目录
            string[] textureFolderPaths = GetPrefabDependentTextureFolderPaths(prefabPath);
            //将每一个图片目录做成一个图集
            string[] atlasPaths = AtlasGenerator.Generate(textureFolderPaths);
            //将Prefab复制出来一个副本
            string copyPath = CopyPrefab(prefabPath);
            //将副本Prefab中Image组件上的资源依赖重定向到图集中的Sprite
            RepleaceImageSprite(prefabPath, copyPath);
            return copyPath;
        }

        private static string GetSelectedPrefabPath() {
            Object[] objs = Selection.GetFiltered(typeof(Object), SelectionMode.Assets);
            foreach (Object obj in objs) {
                string path = AssetDatabase.GetAssetPath(obj);
                if (obj.GetType() == typeof(GameObject) && path.Contains(UI_PREFAB_ROOT) == true) {
                    return path;
                }
            }
            return string.Empty;
        }

        private static string[] GetPrefabDependentTextureFolderPaths(string path) {
            string[] paths = AssetDatabase.GetDependencies(path);
            HashSet<string> result = new HashSet<string>();
            foreach (string s in paths) {
                if (s.Contains (IconProcessor.ICON_OUT_ROOT)) {
                    // throw new Exception ("UI预设中不可以引用ICon资源:[" + path + "]=>[" + s + "]");
                    Debug.LogError("UI预设中不可以引用ICon资源:[" + path + "]=>[" + s + "]");
                }
                else if (s.ToLower().EndsWith(".png") == true) {
                    result.Add(GetFolderPath(s));
                }
            }
            return result.ToArray<string>();
        }

        public static string GetFolderPath(string path) {
            int index = path.LastIndexOf("/");
            return path.Substring(0, index);
        }

        private static string CopyPrefab(string source) {
            string target = GetCopyPrefabPath(source);
            CreateInexistentFolder(target);
            AssetDatabase.CopyAsset(source, target);
            return target;
        }

        private static void RepleaceImageSprite(string prefabPath, string copyPath)
        {
            GameObject prefab = AssetDatabase.LoadAssetAtPath(prefabPath, typeof(GameObject)) as GameObject;
            GameObject go = PrefabUtility.InstantiatePrefab(prefab) as GameObject;
            Image[] images = go.GetComponentsInChildren<Image>(true);
            foreach (Image image in images)
            {
                Sprite sprite = image.sprite;
                if (sprite != null)
                {
                    //Debug.Log(sprite);
                    string path = AssetDatabase.GetAssetPath(sprite);
                    if(!path.StartsWith(UI_TEXTURE_ROOT))
                    {
                        continue;
                    }

                    string folderPath = GetFolderPath(path);
                    TextureImporter textureImporter = AssetImporter.GetAtPath(path) as TextureImporter;
                    if (textureImporter == null)
                    {
                        Debug.LogError("[出错了]预设依赖资源有误[" + prefabPath + "] Node:" + image.gameObject.name + ":" + image.sprite.name + "[" + folderPath + "]");
                    }

                    //string tag = (AssetImporter.GetAtPath(path) as TextureImporter).spritePackingTag;
                    string tag = AtlasGenerator.GetTexturePackingTag(path);
                    string atlasPath = AtlasGenerator.GetAtlasPath(folderPath, tag);
                    List<Sprite> spriteList = GetSpriteListDict(atlasPath);
                    foreach (Sprite s in spriteList)
                    {
                        if (s.name == sprite.name)
                        {
                            image.sprite = s;
                            image.material = GetMaterialDict(atlasPath);
                            break;
                        }
                    }
                }
            }
            PrefabUtility.UnpackPrefabInstance(go, PrefabUnpackMode.Completely, InteractionMode.AutomatedAction);
            PrefabUtility.SaveAsPrefabAssetAndConnect(go, copyPath, InteractionMode.AutomatedAction);
            Object.DestroyImmediate(go, true);
        }

        private static Dictionary<string, List<Sprite>> cacheSpriteListDict = new Dictionary<string, List<Sprite>>();
        private static Dictionary<string, Material> cacheMaterialDict = new Dictionary<string, Material>();


        public static void ClearCache()
        {
            cacheSpriteListDict.Clear();
            cacheMaterialDict.Clear();
        }

        private static List<Sprite> GetSpriteListDict(string atlasPath)
        {
            if (cacheSpriteListDict.ContainsKey(atlasPath))
            {
                return cacheSpriteListDict[atlasPath];
            }

            List<Sprite> result = new List<Sprite>();
            Object[] objs = AssetDatabase.LoadAllAssetsAtPath(atlasPath);
            foreach (Object o in objs)
            {
                if (o is Sprite)
                {
                    result.Add(o as Sprite);
                }
            }
            cacheSpriteListDict[atlasPath] = result;
            return result;
        }

        private static Material GetMaterialDict(string atlasPath)
        {
            if (cacheMaterialDict.ContainsKey(atlasPath))
            {
                return cacheMaterialDict[atlasPath];
            }

            Material result = AssetDatabase.LoadAssetAtPath(AtlasGenerator.GetMaterialPath(atlasPath), typeof(Material)) as Material;
            cacheMaterialDict[atlasPath] = result;
            return result;
        }

        public static void CreateInexistentFolder(string path) {
            string folderPath = Path.GetDirectoryName(ToFileSystemPath(path));
            if (Directory.Exists(folderPath) == false) {
                Directory.CreateDirectory(folderPath);
            }
        }

        public static string GetCopyPrefabPath(string sourcePath) {
            return sourcePath.Replace(UI_PREFAB_ROOT, GetShadowPrefabFolderRoot());
        }

        public static string GetShadowTextureFolderPath(string folderPath) {
            return folderPath.Replace(UI_TEXTURE_ROOT, GetShadowTextureFolderRoot());
        }

        public static string GetShadowPrefabFolderRoot() {
            return string.Format (UI_PREFAB_ROOT_SHADOW, AssetPathHelper.GetBuildTarget (AssetPathHelper.GetBuildTarget ()));
        }

        public static string GetShadowTextureFolderRoot() {
            return string.Format (UI_TEXTURE_ROOT_SHADOW, AssetPathHelper.GetBuildTarget (AssetPathHelper.GetBuildTarget ()));
        }

        public static void DeleteMediate() {
            if (IS_DELETE_MEDIATE == true) {
                string systemPrefabRoot = ToFileSystemPath(GetShadowPrefabFolderRoot());
                if (Directory.Exists(systemPrefabRoot) == true) {
                    Directory.Delete(systemPrefabRoot, true);
                }
                string systemTextureRoot = ToFileSystemPath(GetShadowTextureFolderRoot());
                if (Directory.Exists(systemTextureRoot) == true) {
                    Directory.Delete(systemTextureRoot, true);
                }
                AssetDatabase.Refresh();
            }
        }

        public static string ToFileSystemPath(string assetPath) {
            return Application.dataPath.Replace("Assets", "") + assetPath;
        }

        public static string ToAssetPath(string systemPath) {
            systemPath = systemPath.Replace("\\", "/");
            return "Assets" + systemPath.Substring(Application.dataPath.Length);
        }

        public static void ThrowException(string msg) {
            EditorUtility.DisplayDialog("错误", msg, "马上调整Go~");
            throw new Exception(msg);
        }
    }
}


