using Ntreev.Library.Psd;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;


namespace PsdUIExporter {

    public static class ExportUtility {

        // 通道分离-alpha
        public const int SPLIT_ALPHA = 1;
        // 通道分离-rgb
        public const int SPLIT_TEXTURE = 2;
        // 透明的图片，使用压缩格式
        public const int COMPRESS_ALPHA = 3;
        // 真彩
        public const int TRUE_COLOR = 4;

        [MenuItem("PsdTools/PSDWindow")]
        static void OpenPSDConfigWindow() {
            var window = EditorWindow.GetWindow<PsdUIWindow>();
            window.position = new Rect(100, 100, 1200, 600);
            window.titleContent = new GUIContent("PSDExporter");
            window.Repaint();
        }

        [MenuItem("PsdTools/SliceWindow")]
        static void OpenSliceWindow() {
            var window = EditorWindow.GetWindow<SliceWindow>();
            window.position = new Rect(100, 100, 1000, 600);
            window.titleContent = new GUIContent("SliceWindow");
            window.Show();
        }


        /// <summary>
        /// 解析Layer中的尺寸信息
        /// 以中间锚点为计算方式
        /// </summary>
        /// <param name="psdLayer"></param>
        /// <returns></returns>
        public static Rect GetRectFromLayer(IPsdLayer psdLayer, INode parentNode) {
            //rootSize = new Vector2(rootSize.x > maxSize.x ? maxSize.x : rootSize.x, rootSize.y > maxSize.y ? maxSize.y : rootSize.y);
            var left = psdLayer.Left;// psdLayer.Left <= 0 ? 0 : psdLayer.Left;
            var bottom = psdLayer.Bottom;// psdLayer.Bottom <= 0 ? 0 : psdLayer.Bottom;
            var top = psdLayer.Top;// psdLayer.Top >= rootSize.y ? rootSize.y : psdLayer.Top;
            var rigtht = psdLayer.Right;// psdLayer.Right >= rootSize.x ? rootSize.x : psdLayer.Right;
            var width = psdLayer.Width;// psdLayer.Width > rootSize.x ? rootSize.x : psdLayer.Width;
            var height = psdLayer.Height;// psdLayer.Height > rootSize.y ? rootSize.y : psdLayer.Height;

            // var xMin = (rigtht + left - parentRect.width) * 0.5f;
            // var yMin = -(top + bottom - parentRect.height) * 0.5f;
            Vector2 pa = GetParenRectAddition(parentNode);
            var xMin = (left + width / 2f) - pa.x;
            var yMin = pa.y - (top + height / 2f);
            return new Rect(xMin, yMin, width, height);
        }

        public static Vector2 GetParenRectAddition(INode node) {
            if (node.GetParentNode() == null) {
                return new Vector2(node.GetRect().width / 2f, node.GetRect().height / 2f);
            } else {
                Vector2 parent = GetParenRectAddition(node.GetParentNode());
                return new Vector2(parent.x + node.GetRect().x, parent.y - node.GetRect().y);
            }
        }

        /// <summary>
        /// 计算平均颜色
        /// </summary>
        /// <param name="layer"></param>
        /// <returns></returns>
        public static Color GetLayerColor(PsdLayer layer) {
            Channel red = Array.Find(layer.Channels, i => i.Type == ChannelType.Red);
            Channel green = Array.Find(layer.Channels, i => i.Type == ChannelType.Green);
            Channel blue = Array.Find(layer.Channels, i => i.Type == ChannelType.Blue);
            Channel alpha = Array.Find(layer.Channels, i => i.Type == ChannelType.Alpha);
            //Channel mask = Array.Find(layer.Channels, i => i.Type == ChannelType.Mask);

            Color[] pixels = new Color[layer.Width * layer.Height];

            for (int i = 0; i < pixels.Length; i++) {
                byte r = red.Data[i];
                byte g = green.Data[i];
                byte b = blue.Data[i];
                byte a = 255;

                if (alpha != null && alpha.Data[i] != 0)
                    a = (byte)alpha.Data[i];
                //if (mask != null && mask.Data[i] != 0)
                //    a *= mask.Data[i];

                int mod = i % layer.Width;
                int n = ((layer.Width - mod - 1) + i) - mod;
                pixels[pixels.Length - n - 1] = new Color(r / 255f, g / 255f, b / 255f, a / 255f);
            }
            Color color = Color.white;
            foreach (var item in pixels) {
                color += item;
                color *= 0.5f;
            }
            return color;
        }

        /// <summary>
        /// 从layer解析图片
        /// </summary>
        /// <param name="layer"></param>
        /// <returns></returns>
        public static Texture2D CreateTexture(PsdLayer layer) {
            Debug.Assert(layer.Width != 0 && layer.Height != 0, layer.Name + ": width = height = 0");
            if (layer.Width == 0 || layer.Height == 0) return new Texture2D(layer.Width, layer.Height);

            Texture2D texture = new Texture2D(layer.Width, layer.Height);
            Color32[] pixels = new Color32[layer.Width * layer.Height];

            Channel red = Array.Find(layer.Channels, i => i.Type == ChannelType.Red);
            Channel green = Array.Find(layer.Channels, i => i.Type == ChannelType.Green);
            Channel blue = Array.Find(layer.Channels, i => i.Type == ChannelType.Blue);
            Channel alpha = Array.Find(layer.Channels, i => i.Type == ChannelType.Alpha);

            //Channel mask = Array.Find(layer.Channels, i => i.Type == ChannelType.Mask);

            //if (layer.HasMask && alpha != null && alpha.Data != null)
            //{
            //    Debug.Log(mask.Data.Length + ":" + alpha.Data.Length);
            //}
            for (int i = 0; i < pixels.Length; i++) {
                var redErr = red == null || red.Data == null || red.Data.Length <= i;
                var greenErr = green == null || green.Data == null || green.Data.Length <= i;
                var blueErr = blue == null || blue.Data == null || blue.Data.Length <= i;
                var alphaErr = alpha == null || alpha.Data == null || alpha.Data.Length <= i;

                byte r = redErr ? (byte)0 : red.Data[i];
                byte g = greenErr ? (byte)0 : green.Data[i];
                byte b = blueErr ? (byte)0 : blue.Data[i];
                byte a = alphaErr ? (byte)255 : alpha.Data[i];

                int mod = i % texture.width;
                int n = ((texture.width - mod - 1) + i) - mod;
                pixels[pixels.Length - n - 1] = new Color32(r, g, b, a);
            }

            texture.SetPixels32(pixels);
            texture.Apply();
            return texture;
        }

        /// <summary>
        /// 兼容unity2017和unity5.6
        /// </summary>
        /// <param name="texture"></param>
        /// <returns></returns>
        public static byte[] EncordToPng(this Texture2D texture) {
            try {
                var assemble = System.Reflection.Assembly.Load("UnityEngine.ImageConversionModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null");
                if (assemble != null) {
                    var imageConvention = assemble.GetType("UnityEngine.ImageConversion");
                    if (imageConvention != null) {
                        return imageConvention.GetMethod("EncodeToPNG", System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.InvokeMethod).Invoke(null, new object[] { texture }) as byte[];
                    }
                }
            } catch (Exception) {
                return texture.GetType().GetMethod("EncodeToPNG").Invoke(texture, null) as byte[];
            }
            return new byte[0];
        }

        public static void SetPlatformTextureSettings(string path, int maxSize = 2048, int type = COMPRESS_ALPHA) {
            if (path == null || path.Trim().Length == 0) {
                return;
            }
            TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter;
            SetPlatformTextureSettings(importer, maxSize, type);
        }

        public static void SetPlatformTextureSettings(TextureImporter importer, int maxSize = 2048, int type = COMPRESS_ALPHA) {
            if (importer == null) {
                return;
            }
            switch (type) {
                case SPLIT_ALPHA:
                    importer.textureType = TextureImporterType.Default;
                    importer.isReadable = false;
                    importer.mipmapEnabled = false;
                    importer.alphaSource = TextureImporterAlphaSource.None;
                    importer.wrapMode = TextureWrapMode.Clamp;
                    importer.filterMode = FilterMode.Bilinear;
                    importer.anisoLevel = 0;
                    // importer.sRGBTexture = true;
                    break;
                case SPLIT_TEXTURE:
                    importer.textureType = TextureImporterType.Sprite;
                    importer.spriteImportMode = SpriteImportMode.Single;
                    importer.spritePixelsPerUnit = 1f;
                    importer.anisoLevel = 0;
                    importer.alphaSource = TextureImporterAlphaSource.None;
                    importer.alphaIsTransparency = false;
                    importer.isReadable = false;
                    // importer.npotScale = TextureImporterNPOTScale.None;
                    importer.mipmapEnabled = false;
                    importer.wrapMode = TextureWrapMode.Clamp;
                    importer.filterMode = FilterMode.Bilinear;
                    importer.textureCompression = TextureImporterCompression.CompressedHQ;
                    break;
                case COMPRESS_ALPHA:
                    importer.textureType = TextureImporterType.Sprite;
                    importer.spriteImportMode = SpriteImportMode.Single;
                    importer.spritePixelsPerUnit = 1f;
                    importer.anisoLevel = 0;
                    importer.alphaSource = TextureImporterAlphaSource.FromInput;
                    importer.alphaIsTransparency = true;
                    importer.isReadable = false;
                    // importer.npotScale = TextureImporterNPOTScale.None;
                    importer.mipmapEnabled = false;
                    importer.wrapMode = TextureWrapMode.Clamp;
                    importer.filterMode = FilterMode.Bilinear;
                    importer.textureCompression = TextureImporterCompression.CompressedHQ;
                    break;
                case TRUE_COLOR:
                    importer.textureType = TextureImporterType.Sprite;
                    importer.spriteImportMode = SpriteImportMode.Single;
                    importer.spritePixelsPerUnit = 1f;
                    importer.anisoLevel = 0;
                    importer.alphaSource = TextureImporterAlphaSource.FromInput;
                    importer.alphaIsTransparency = true;
                    importer.isReadable = false;
                    // importer.npotScale = TextureImporterNPOTScale.None;
                    importer.mipmapEnabled = false;
                    importer.wrapMode = TextureWrapMode.Clamp;
                    importer.filterMode = FilterMode.Bilinear;
                    importer.textureCompression = TextureImporterCompression.Uncompressed;
                    break;
            }
            SetPlatformTextureSettingsSub(importer, type, maxSize);
        }

        // 设置分离通道图片资源格式
        public static void SetPlatformTextureSettingsSub(TextureImporter importer, int type, int maxSize = 2048) {
            TextureImporterPlatformSettings setting = new TextureImporterPlatformSettings();
            setting.name = BuildTarget.Android.ToString();
            setting.maxTextureSize = maxSize;
            setting.compressionQuality = 100;
            SetPlatformTextureSettingsFormat(setting, type, BuildTarget.Android);
            setting.overridden = true;
            importer.SetPlatformTextureSettings(setting);

            setting = new TextureImporterPlatformSettings();
            setting.name = "iPhone";
            setting.maxTextureSize = maxSize;
            setting.compressionQuality = 100;
            SetPlatformTextureSettingsFormat(setting, type, BuildTarget.iOS);
            setting.overridden = true;
            importer.SetPlatformTextureSettings(setting);


            setting = new TextureImporterPlatformSettings();
            setting.name = BuildTarget.StandaloneWindows64.ToString();
            setting.maxTextureSize = maxSize;
            setting.compressionQuality = 100;
            SetPlatformTextureSettingsFormat(setting, type, BuildTarget.StandaloneWindows64);
            setting.overridden = true;

            setting = new TextureImporterPlatformSettings();
            setting.name = "Standalone";
            setting.maxTextureSize = maxSize;
            setting.compressionQuality = 100;
            SetPlatformTextureSettingsFormat(setting, type, BuildTarget.StandaloneWindows);
            setting.overridden = true;
            importer.SetPlatformTextureSettings(setting);

            setting = new TextureImporterPlatformSettings();
            setting.name = "Default";
            setting.maxTextureSize = maxSize;
            setting.compressionQuality = 100;
            SetPlatformTextureSettingsFormat(setting, type, BuildTarget.StandaloneWindows);
            importer.SetPlatformTextureSettings(setting);
        }

        public static void SetPlatformTextureSettingsFormat(TextureImporterPlatformSettings setting, int type, BuildTarget target) {
            if (target == BuildTarget.Android) {
                switch (type) {
                    case SPLIT_ALPHA:
                        setting.format = TextureImporterFormat.ETC_RGB4;
                        break;
                    case SPLIT_TEXTURE:
                        setting.format = TextureImporterFormat.ETC_RGB4;
                        break;
                    case TRUE_COLOR:
                        setting.format = TextureImporterFormat.RGBA32;
                        break;
                    default:
                        setting.format = TextureImporterFormat.ETC2_RGBA8;
                        break;
                }
            } else if (target == BuildTarget.iOS) {
                switch (type) {
                    case SPLIT_ALPHA:
                        setting.format = TextureImporterFormat.PVRTC_RGB4;
                        break;
                    case SPLIT_TEXTURE:
                        setting.format = TextureImporterFormat.PVRTC_RGB4;
                        break;
                    case TRUE_COLOR:
                        setting.format = TextureImporterFormat.RGBA32;
                        break;
                    default:
                        setting.format = TextureImporterFormat.PVRTC_RGBA4;
                        break;
                }
            } else {
                switch (type) {
                    case SPLIT_ALPHA:
                        setting.format = TextureImporterFormat.DXT1;
                        break;
                    case SPLIT_TEXTURE:
                        setting.format = TextureImporterFormat.DXT1;
                        break;
                    case TRUE_COLOR:
                        setting.format = TextureImporterFormat.RGBA32;
                        break;
                    default:
                        setting.format = TextureImporterFormat.DXT5;
                        break;
                }
            }
        }

        public static bool IsSliceSprite(string path) {
            if (path != null && path.ToLower().EndsWith("png")) {
                TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter;
                Vector4 border = importer.spriteBorder;
                if ((border.x + border.y + border.w + border.z) > 3) {
                    return true;
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }

        public static GameObject CreateGameObject(string name, Rect rect, Vector2 pivot, Vector2 anchorMax, Vector2 anchorMin) {
            GameObject go = new GameObject();
            go.layer = UnityEngine.LayerMask.NameToLayer("UI");
            go.name = name;
            RectTransform rect2 = go.AddComponent<RectTransform>();
            rect2.pivot = pivot;
            rect2.anchorMax = anchorMax;
            rect2.anchorMin = anchorMin;
            if (rect.width == 0 && rect.height == 0) {
                // 全屏布局，待定
                // rect2.sizeDelta = new Vector2(rect.width, rect.height);
                rect2.offsetMin = Vector2.zero;
                rect2.offsetMax = Vector2.zero;
            } else {
                rect2.sizeDelta = new Vector2(rect.width, rect.height);
            }
            rect2.anchoredPosition3D = new Vector3(rect.x, rect.y, 0);
            rect2.localScale = Vector3.one;
            return go;
        }

        public static bool IsNoexportLayer(PsdLayer layer) {
            string name = layer.Name;
            if (!layer.IsVisible || (name != null && (name.ToLower().StartsWith("noexport_") || name.ToLower().StartsWith("ignore_"))) ) {
                return true;
            } else {
                return false;
            }
        }
    }
}
