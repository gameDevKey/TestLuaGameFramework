using UnityEngine;
using System.Collections;
using UnityEditor;
using System.Collections.Generic;
using System;
using System.IO;
using EditorTools.AssetBundle;

namespace EditorTools.UI {
    /// <summary>
    /// 图集预览工具
    /// </summary>
    public class AtlasPreviewer : EditorWindow {
        private static AtlasPreviewer _window;
        private static Texture2D _atlas;
        private static string currentAtalsPath;

        [MenuItem("Assets/Preview Atlas")]
        public static void PreviewAtlas() {
            const string basePath = "Assets/Things/ui/texture";
            string[] aryAssetGuids = Selection.assetGUIDs;
            if (aryAssetGuids != null && aryAssetGuids.Length > 0) {
                string folderPath = AssetDatabase.GUIDToAssetPath(aryAssetGuids[0]);
                if (folderPath == basePath) {
                    Debug.Log("请选择[{0}]的子目录:" + basePath);
                    _atlas = null;
                } else if (folderPath.StartsWith(basePath)) {
                    if (HasSubDirectory(folderPath)) {
                        _atlas = null;
                        Debug.Log("此目录下还有子目录，请选择只包含图片的子目录");
                    } else {
                        string[] assetPaths = GetAssetPaths(folderPath);
                        string tag = GetFolderTexturePackingTag(assetPaths);
                        string atlasPath = GetAtlasPath(folderPath, tag);
                        currentAtalsPath = atlasPath;
                        TextureData[] textureDatas = ReadTextures(assetPaths);
                        if (MaxRectsBinPack.IsUseMaxRectsAlgo) {
                            _atlas = CreateAtlasMaxRect(textureDatas);
                        } else {
                            _atlas = CreateAtlas(textureDatas);
                        }
                    }
                } else {
                    Debug.Log("请选择[{0}]的子目录:" + basePath);
                    _atlas = null;
                }
            }
            _window = EditorWindow.GetWindow<AtlasPreviewer>("图集预览");
            _window.Show();
            _window.position = new Rect(1920 / 2 - 250, 1080 / 2 - 350, 500, 600);
        }

        public static string GetAtlasPath(string folderPath, string tag) {
            string atlasPath = UIPrefabProcessor.GetShadowTextureFolderPath(folderPath) + "/UI_" + tag + ".png";
            UIPrefabProcessor.CreateInexistentFolder(atlasPath);
            return atlasPath;
        }

        private static string[] GetAssetPaths(string folderPath) {
            string systemPath = UIPrefabProcessor.ToFileSystemPath(folderPath);
            string[] filePaths = Directory.GetFiles(systemPath, "*.png");
            string[] result = new string[filePaths.Length];
            for (int i = 0; i < filePaths.Length; i++) {
                result[i] = UIPrefabProcessor.ToAssetPath(filePaths[i]);
            }
            return result;
        }

        private static bool HasSubDirectory(string folderPath) {
            string systemPath = UIPrefabProcessor.ToFileSystemPath(folderPath);
            string[] dirPaths = Directory.GetDirectories(systemPath);
            return dirPaths != null && dirPaths.Length > 0;
        }

        private static TextureData[] ReadTextures(string[] assetPaths) {
            TextureData[] textureDatas = new TextureData[assetPaths.Length];
            for (int i = 0; i < assetPaths.Length; i++) {
                Sprite sprite = AssetDatabase.LoadAssetAtPath(assetPaths[i], typeof(Sprite)) as Sprite;
                TextureData data = new TextureData();
                if (sprite == null) {
                    Debug.LogErrorFormat("ReadTextures sprite is null at assetPaths[{0}]", assetPaths[i]);
                }
                data.name = sprite.name;
                Vector4 border = sprite.border;
                data.top = (int)border.w;
                data.right = (int)border.z;
                data.bottom = (int)border.y;
                data.left = (int)border.x;
                Texture2D texture = AssetDatabase.LoadAssetAtPath(assetPaths[i], typeof(Texture2D)) as Texture2D;
                /*
                if (data.IsScale9Grid) {
                    texture = Scale9GridTextureProcessor.Process(texture, data.top, data.right, data.bottom, data.left);
                }
                 * */
                if (textureDatas.Length > 1) {
                    texture = TextureClamper.Clamp(texture);
                } else {
                    texture = TextureClamper.ClampSingle(texture);
                }
                data.texture = texture;
                data.width = texture.width;
                data.height = texture.height;
                textureDatas[i] = data;
            }
            return textureDatas;
        }

        private static Texture2D CreateAtlas(TextureData[] textureDatas) {
            Texture2D atlas = new Texture2D(AtlasGenerator.ATLAS_MAX_SIZE, AtlasGenerator.ATLAS_MAX_SIZE);
            Rect[] uvs = atlas.PackTextures(GetPackTextures(textureDatas), 0, AtlasGenerator.ATLAS_MAX_SIZE, false);
            return atlas;
        }

        private static Texture2D CreateAtlasMaxRect(TextureData[] textureDatas) {
            Array.Sort<TextureData>(textureDatas, new Texture2DComparison());
            Texture2D atlas = new Texture2D(AtlasGenerator.ATLAS_MAX_SIZE, AtlasGenerator.ATLAS_MAX_SIZE);
            Rect[] uvs = MaxRectsBinPack.PackTextures(atlas, GetPackTextures(textureDatas));
            return atlas;
        }

        private static Texture2D[] GetPackTextures(TextureData[] textureDatas) {
            Texture2D[] result = new Texture2D[textureDatas.Length];
            for (int i = 0; i < textureDatas.Length; i++) {
                result[i] = textureDatas[i].texture;
            }
            return result;
        }

        private void OnGUI() {
            try {
                ShowAtlasTexture();
            } catch (Exception e) {
                Debug.Log(e);
            }
        }

        private void OnDestroy() {
        }

        private static void ShowAtlasTexture() {
            if (_atlas == null) {
                return;
            }
            GUILayout.BeginHorizontal();
            Color back = GUI.color;
            GUI.color = Color.white;
            GUILayout.Label("生成图集尺寸： " + _atlas.width.ToString() + "x" + _atlas.height.ToString(), EditorStyles.whiteLabel);
            GUI.color = back;
            GUILayout.EndHorizontal();
            ShowTexture(_atlas);
        }

        private static void ShowTexture(Texture2D texture) {
            int width = texture.width;
            int height = texture.height;
            float ratio = 1.0f;
            float previewSize = 512.0f;
            if (width > previewSize || height > previewSize) {
                if (width > height) {
                    ratio = previewSize / (float)width;
                } else {
                    ratio = previewSize / (float)height;
                }
            }
            GUILayout.Box(texture, GUILayout.Width(width * ratio), GUILayout.Height(height * ratio));
        }

        /// <summary>
        /// 获取目录下Texture的Packingtag
        /// 同时验证同一目录下Texture的PackingTag是否相同，不同则报错，提示修改
        /// </summary>
        /// <param name="assetPaths"></param>
        private static string GetFolderTexturePackingTag(string[] assetPaths) {
            string tag = null;
            foreach (string s in assetPaths) {
                string nextTag = GetTexturePackingTag(s);
                if (tag != null && tag != nextTag) {
                    UIPrefabProcessor.ThrowException("同一目录下存在不同的SpritePackingTag，路径： " + s + " tag: " + nextTag);
                } else {
                    tag = nextTag;
                }
            }
            return tag;
        }

        private static string GetTexturePackingTag(string path) {
            TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter;
            return importer.spritePackingTag;
        }
    }
}