using System;
using System.IO;
using System.Linq;
using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using Object = UnityEngine.Object;

namespace EditorTools.UI {
    /// <summary>
    /// 处理Icon资源，分成两种模式，Single：每一张Icon图片做成一个独立的图集，
    /// Mutilple：将一个目录下的所有图片合成一个图集
    /// 
    /// Single和Mutilple对应Assets/Icon目录下两个文件夹
    /// 因为Icon需要使用内建的Sprite Packer分离通道的功能，所以Icon目录不能放在Resources目录下
    /// </summary>
    public class IconProcessor {
        public const int ATLAS_MAX_SIZE = 2048;
        public const int FAVOR_ATLAS_SIZE = 1024;

        public const string ICON_ROOT = "Assets/IconOrigin";
        public const string SINGLE_ROOT = "Assets/IconOrigin/Single";
        public const string MUTLIPLE_ROOT = "Assets/IconOrigin/Mutliple";

        // UI预设中不可以引用Icon图标
        public const string ICON_OUT_ROOT = "Assets/Things/ui/icon";
        public const string SINGLE_OUT_ROOT = "Assets/Things/ui/icon";
        public const string MUTLIPLE_OUT_ROOT = "Assets/Things/Textures/Icon/Mutliple";

        [MenuItem("Assets/MakeIconAtlas", false)]
        public static void Main(){
            Object[] objs = Selection.GetFiltered(typeof(Object), SelectionMode.Assets);
            foreach (Object obj in objs) {
                string path = AssetDatabase.GetAssetPath(obj);
                string selectedPath = GetSelectedPath(path);
                if (string.IsNullOrEmpty(selectedPath) == true) {
                    return;
                }
                Debug.Log("Selected Path: " + selectedPath);
                if (selectedPath.Contains(".png") == true) {
                    EnterByFile(selectedPath);
                } else {
                    EnterByFolder(selectedPath);
                }
            }
        }

        public static void EnterByFile(string path) {
            if (path.Contains(SINGLE_ROOT) == true) {
                PackSingleMode(path);
            } else if (path.Contains(MUTLIPLE_ROOT) == true) {
                string folderPath = GetFolderPath(path);
                PackFolderMode(folderPath);
            }
        }

        public static void EnterByFolder(string path) {
            if (path.Contains(SINGLE_ROOT) == true) {
                string[] paths = GetAssetPaths(path);
                foreach (string s in paths) {
                    PackSingleMode(s);
                }
            } else if (path.Contains(MUTLIPLE_ROOT) == true) {
                if (path.Length > MUTLIPLE_ROOT.Length) {
                    PackFolderMode(path);
                } else {
                    string[] paths = GetSubFolderPaths(path);
                    foreach (string s in paths) {
                        PackFolderMode(s);
                    }
                }
            }
        }

        private static string[] GetSubFolderPaths(string folderPath) {
            string[] result = Directory.GetDirectories(folderPath);
            for (int i = 0; i < result.Length; i++) {
                result[i] = result[i].Replace(@"\", @"/");
            }
            return result;
        }

        private static string[] GetAssetPaths(string folderPath) {
            string[] result = Directory.GetFiles(folderPath, "*.*", SearchOption.TopDirectoryOnly).Where<string>(s => s.Contains(".meta") == false).ToArray<string>();
            for (int i = 0; i < result.Length; i++) {
                result[i] = result[i].Replace(@"\", @"/");
            }
            return result;
        }

        private static string GetFolderPath(string path) {
            int lastSlashIndex = path.LastIndexOf(@"/");
            return path.Substring(0, lastSlashIndex);
        }

        private static void PackFolderMode(string path) {
            string[] paths = GetAssetPaths(path);
            foreach(string s in paths){
                ImportReadableTexture(s);
            }
            string atlasPath = path.Replace(MUTLIPLE_ROOT, MUTLIPLE_OUT_ROOT) + ".png";//这里的path表示目录路径且结尾不含/
            string folderPath = Path.GetDirectoryName (atlasPath);
            if (Directory.Exists (folderPath) == false) {
                Directory.CreateDirectory (folderPath);
            }
            CreateFolderModeAtlas(paths, atlasPath);
        }

        private static void PackSingleMode(string path) {
            ImportReadableTexture(path);
            string atlasPath = path.Replace(SINGLE_ROOT, SINGLE_OUT_ROOT);
            string folderPath = Path.GetDirectoryName (atlasPath);
            if (Directory.Exists (folderPath) == false) {
                Directory.CreateDirectory (folderPath);
            }
            CreateSingleModeAtlas(path, atlasPath);
        }

        private static void CreateSingleModeAtlas(string path, string atlasPath) {
            Texture2D texture = AssetDatabase.LoadAssetAtPath(path, typeof(Texture2D)) as Texture2D;
            AtlasWriter.Write(texture, atlasPath);
            AssetDatabase.ImportAsset(atlasPath, ImportAssetOptions.ForceUpdate);
            TextureImporter importer = AssetImporter.GetAtPath(atlasPath) as TextureImporter;
            if (importer == null) { Debug.LogError("发现不是图片的资源, 资源路径 = " + atlasPath); return; }
            importer.textureType = TextureImporterType.Sprite;
            importer.spriteImportMode = SpriteImportMode.Single;
            importer.spritePixelsPerUnit = 100;
            importer.maxTextureSize = ATLAS_MAX_SIZE;
            importer.isReadable = false;
            importer.mipmapEnabled = false;
            importer.crunchedCompression = true;
            importer.spritePackingTag = "";
            importer.sRGBTexture = true;
            //TextureImporterUtil.SetAtlasPackingTag(atlasPath, texture.name);
            AssetDatabase.ImportAsset(atlasPath, ImportAssetOptions.ForceUpdate);
        }

        private static void CreateFolderModeAtlas(string[] paths, string atlasPath) {
            Texture2D[] textures = new Texture2D[paths.Length];
            string[] textureNames = new string[textures.Length];
            for (int i = 0; i < textures.Length; i++) {
                textures[i] = AssetDatabase.LoadAssetAtPath(paths[i], typeof(Texture2D)) as Texture2D;
                textureNames[i] = textures[i].name;
                textures[i] = TextureClamper.Clamp(textures[i]);
            }
            Texture2D atlas = new Texture2D(ATLAS_MAX_SIZE, ATLAS_MAX_SIZE);
            Rect[] rects = atlas.PackTextures(textures, 0, ATLAS_MAX_SIZE, false);
            AtlasWriter.Write(atlas, atlasPath);
            AssetDatabase.ImportAsset(atlasPath, ImportAssetOptions.ForceUpdate);
            TextureImporterUtil.CreateMultipleSpriteImporter(atlasPath, rects, textureNames, new Vector4[textures.Length], atlas.width, atlas.height, ATLAS_MAX_SIZE, TextureImporterUtil.COMPRESS_ALPHA);
            //TextureImporterUtil.SetAtlasPackingTag(atlasPath, GetPackingTagFromPath(atlasPath));
            AssetDatabase.ImportAsset(atlasPath, ImportAssetOptions.ForceUpdate);
        }

        private static string GetPackingTagFromPath(string path) {
            int lastSlashIndex = path.LastIndexOf(@"/");
            int lastDotIndex = path.LastIndexOf(@".");
            return path.Substring(lastSlashIndex + 1, (lastDotIndex - lastSlashIndex - 1));
        }

        private static void ImportReadableTexture(string path) {
            TextureImporterUtil.CreateReadableTextureImporter(path);
            AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
        }

        /// <summary>
        /// 检测资源文件路径和文件夹路径
        /// </summary>
        /// <returns></returns>
        private static string GetSelectedPath(string path) {
            if (path.Contains(SINGLE_ROOT) == false && path.Contains(MUTLIPLE_ROOT) == false) {
                Debug.LogError("选择的路径是： " + path + " 错误，请选择Assets/IconOrigin/Single或Assets/IconOrigin/Mutliple目录下icon资源~");
                return string.Empty;
            }
            if (path.Contains(SINGLE_OUT_ROOT) == true || path.Contains(MUTLIPLE_OUT_ROOT) == true) {
                Debug.LogError("选择的路径是： " + path + " 错误，请选择Assets/IconOrigin/Single或Assets/IconOrigin/Mutliple目录下icon资源~");
                return string.Empty;
            }
            return path;
        }
    }
}

