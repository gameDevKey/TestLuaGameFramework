using System;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

using EditorTools.AssetBundle;

namespace EditorTools.UI {
    public class SplitAlphaChannel {
        public SplitAlphaChannel() {
        }

        public static void Handle(string pngPath, string alphaPath) {
            SetReadable(pngPath);
            Texture2D sourcetex = AssetDatabase.LoadAssetAtPath(pngPath, typeof(Texture2D)) as Texture2D;
            int size = Mathf.Max(sourcetex.width, sourcetex.height);
            Color[] color = sourcetex.GetPixels();
            Color[] alpha = new Color[size * size];
            Color[] rgb = new Color[size * size];
            for (int i = 0; i < color.Length; i++) {
                int index = i;
                if (sourcetex.width < size) {
                    index = (int)(i % sourcetex.width) + (int)Mathf.Ceil(i / sourcetex.width) * size;
                }
                rgb[index].r = color[i].r;
                rgb[index].g = color[i].g;
                rgb[index].b = color[i].b;
                alpha[index].r = color[i].a;
                alpha[index].g = 0;
                alpha[index].b = 0;
            }
            Texture2D rgbTexture = new Texture2D(size, size, TextureFormat.RGB24, false);
            rgbTexture.SetPixels(rgb);
            rgbTexture.Apply();
            byte[] rgbbytes = rgbTexture.EncodeToPNG();
            if (File.Exists(pngPath)) {
                File.Delete(pngPath);
            }
            if (File.Exists(pngPath + ".meta")) {
                File.Delete(pngPath + ".meta");
            }
            File.WriteAllBytes(pngPath, rgbbytes);

            Texture2D alphaTexture = new Texture2D(size, size, TextureFormat.RGB24, false);
            alphaTexture.SetPixels(alpha);
            alphaTexture.Apply();

            byte[] alphabytes = alphaTexture.EncodeToPNG();
            if (File.Exists(alphaPath)) {
                File.Delete(alphaPath);
            }
            if (File.Exists(alphaPath + ".meta")) {
                File.Delete(alphaPath + ".meta");
            }
            File.WriteAllBytes(alphaPath, alphabytes);
            AssetDatabase.ImportAsset(alphaPath, ImportAssetOptions.ForceUpdate);

            rgb = null;
            color = null;
            alpha = null;
        }

        /// <summary>
        /// 设置图片可读写
        /// </summary>
        /// <param name="path">Path.</param>
        static void SetReadable(string path) {
            TextureImporter ti = (TextureImporter)TextureImporter.GetAtPath(path);
            if (ti == null) {
                Debug.LogError(path + " not existen!");
                return;
            }
            bool reimport = false;
            if (!ti.isReadable) {
                ti.isReadable = true;
                reimport = true;
            }
            if (ti.textureCompression != TextureImporterCompression.Uncompressed) {
                ti.textureCompression = TextureImporterCompression.Uncompressed;
                reimport = true;
            }
            if (ti.alphaSource != TextureImporterAlphaSource.FromInput) {
                ti.alphaSource = TextureImporterAlphaSource.FromInput;
                reimport = true;
            }
            if (ti.alphaIsTransparency == false) {
                ti.alphaIsTransparency = true;
                reimport = true;
            }
            if (reimport) {
                AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
            }
        }
    }
}
