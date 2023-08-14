using System;
using System.IO;
using System.Linq;
using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using Object = UnityEngine.Object;
using UnityEngine.UI;

namespace EditorTools.UI {

    public class BigTextureProcessor {

        public const string SLICE_TEXTURE_ROOT = "Assets/Things/Textures/BigBgAtlas/";
        public const string SLICE_PREFAB_ROOT = "Assets/Things/Textures/BigBgPref/";
        public const string TEXTURE_ROOT = "Assets/Things/Textures/BigBgOrigin/";

        [MenuItem("Assets/CreateBigTexturePrefab")]
        public static void Main(){
            Object[] objs = Selection.GetFiltered(typeof(Object), SelectionMode.Assets);
            foreach (Object obj in objs) {
                string path = AssetDatabase.GetAssetPath(obj);
                string selectedPath = GetSelectedPath(path);
                if (string.IsNullOrEmpty(selectedPath) == true) {
                    continue;
                }

                if (obj.GetType() == typeof(Texture2D))
                {
                    Debug.Log("Selected Path: " + selectedPath);
                    CutBigTexture(selectedPath);
                }
            }
        }

        private static string GetSelectedPath(string path)
        {
            if (path.Contains(TEXTURE_ROOT) == false)
            {
                Debug.LogError("选择的路径是： " + path + " 错误，请选择Assets / Things / Textures / BigBgOrigin /");
                return string.Empty;
            }

            return path;
        }

        public static void CutBigTexture(string path)
        {
            if (string.IsNullOrEmpty(path) == false)
            {
                ImportReadableTexture(path);
                Texture2D texture = AssetDatabase.LoadAssetAtPath(path, typeof(Texture2D)) as Texture2D;
                int sourceWidth = texture.width;
                int sourceHeight = texture.height;
                // int w = (sourceWidth + 3) / 4 * 4;
                // int h = (sourceHeight + 3) / 4 * 4;
                // Texture2D resizeTexture = GetResizedTexture(texture, sourceWidth, sourceHeight, w, h);
                // string saveTexturePath = GetAtlasPath(texture.name);
                // CreateTexture(resizeTexture, saveTexturePath, sourceWidth, sourceHeight);
                // ImportUnreadableTexture(path);
                CreatePrefab(path, sourceWidth, sourceHeight);
            }
            Debug.Log("DONE");
        }

        public static string GetAtlasPath(string textureName)
        {
            return SLICE_TEXTURE_ROOT + textureName + ".png";
        }

        public static string GetPrefabPath(string textureName)
        {
            return SLICE_PREFAB_ROOT + textureName + ".prefab";
        }

        private static void ImportReadableTexture(string path)
        {
            TextureImporterUtil.CreateReadableTextureImporter(path);
            AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
        }

        private static void ImportUnreadableTexture(string path)
        {
            TextureImporterUtil.CreateUnreadableTextureImporter(path);
            AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
        }

        private static Texture2D GetResizedTexture(Texture2D source, int sourceWidth, int sourceHeight, int width, int height)
        {
            Texture2D result = new Texture2D(width, height, TextureFormat.ARGB32, false);
            for (int x = 0; x < width; x++)
            {
                for (int y = 0; y < height; y++)
                {
                    result.SetPixel(x, y, new Color(1, 1, 1, 0f));
                }
            }
            result.SetPixels(0, 0, sourceWidth, sourceHeight, source.GetPixels());
            result.Apply();
            result.name = source.name;
            return result;
        }

        private static void CreateTexture(Texture2D texture, string atlasPath, int sourceWidth, int sourceHeight)
        {
            AssetDatabase.DeleteAsset(atlasPath);

            byte[] pngData = texture.EncodeToPNG();
            string pngPath = Application.dataPath + atlasPath.Replace("Assets", "");
            File.WriteAllBytes(pngPath, pngData);
            AssetDatabase.Refresh();
            
            TextureImporter importer = AssetImporter.GetAtPath(atlasPath) as TextureImporter;
            if (importer == null) { Debug.LogError("发现不是图片的资源, 资源路径 = " + atlasPath); return; }
            SpriteMetaData metaData = new SpriteMetaData();
            metaData.name = texture.name;
            metaData.rect = new Rect(0, 0, sourceWidth, sourceHeight);
            metaData.pivot = new Vector2(0.5f, 0.5f);
            importer.spritesheet = new SpriteMetaData[]{metaData};
            importer.textureType = TextureImporterType.Sprite;
            importer.spriteImportMode = SpriteImportMode.Multiple;
            importer.spritePixelsPerUnit = 100;

            importer.alphaIsTransparency = true;
            importer.SetPlatformTextureSettings(TextureImporterUtil.CreateImporterSetting("iPhone", 2048, TextureImporterFormat.ASTC_4x4));
            importer.SetPlatformTextureSettings(TextureImporterUtil.CreateImporterSetting("Standalone", 2048, TextureImporterFormat.DXT5));
            importer.SetPlatformTextureSettings(TextureImporterUtil.CreateImporterSetting("Android", 2048, TextureImporterFormat.ETC2_RGBA8));
            importer.mipmapEnabled = false;
            importer.npotScale = TextureImporterNPOTScale.None;
            importer.wrapMode = TextureWrapMode.Clamp;
            importer.SaveAndReimport();
            AssetDatabase.ImportAsset(pngPath, ImportAssetOptions.ForceUpdate);
        }

        private static void CreatePrefab(string texturePath, int w, int h)
        {
            //Sprite sprite = AssetDatabase.LoadAssetAtPath(texturePath, typeof(Sprite)) as Sprite;
            Texture texture = AssetDatabase.LoadAssetAtPath(texturePath, typeof(Texture)) as Texture;            
            string textureName = texture.name;
            GameObject go = new GameObject(textureName);
            RectTransform rectTrans = go.AddComponent<RectTransform>();
            rectTrans.pivot = new Vector2(0.5f, 0.5f);
            rectTrans.anchorMin = new Vector2(0.5f, 0.5f);
            rectTrans.anchorMax = new Vector2(0.5f, 0.5f);
            rectTrans.sizeDelta = new Vector2(w, h);
            GameObject container = CreateContainerGo(w, h);
            container.transform.SetParent(go.transform);
            container.transform.localPosition = Vector3.zero;
            //Image image = container.AddComponent<Image>();
            //image.sprite = sprite;
            RawImage rawImage = container.AddComponent<RawImage>();
            rawImage.raycastTarget = false;
            rawImage.texture = texture;

            GameObject canvasGo = FindCanvasGo();
            rectTrans.SetParent(canvasGo.transform);
            rectTrans.localPosition = Vector3.zero;
            string prefabPath = GetPrefabPath(textureName);
            CreateInexistsFolder(SLICE_PREFAB_ROOT);
            go.transform.localScale = Vector3.one;
            rectTrans.anchoredPosition = Vector3.zero;
            //PrefabUtility.CreatePrefab(prefabPath, go, ReplacePrefabOptions.ReplaceNameBased);
            PrefabUtility.SaveAsPrefabAsset(go, prefabPath);
        }

        private static GameObject CreateContainerGo(int w, int h)
        {
            GameObject go = new GameObject("container");
            RectTransform rectTrans = go.AddComponent<RectTransform>();
            rectTrans.pivot = new Vector2(0.5f, 0.5f);
            rectTrans.anchorMin = new Vector2(0.5f, 0.5f);
            rectTrans.anchorMax = new Vector2(0.5f, 0.5f);
            rectTrans.sizeDelta = new Vector2(w, h);
            return go;
        }

        private static GameObject FindCanvasGo()
        {
            GameObject go = GameObject.Find("Canvas");
            if (go == null)
            {
                go = new GameObject();
                go.name = "Canvas";
                go.AddComponent<Canvas>();
            }
            return go;
        }

        private static void CreateInexistsFolder(string path)
        {
            if (Directory.Exists(path) == false)
            {
                Directory.CreateDirectory(path);
            }
        }

    }
}

