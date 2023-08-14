using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using UnityEditor;
using UnityEngine;
using System.Text.RegularExpressions;

namespace EditorTools.UI
{
    public class AtlasWriter
    {
        public const int ATLAS_MAX_SIZE = 2048;
        public const int FAVOR_ATLAS_SIZE = 1024;
        static Regex regex = new Regex("Assets");

        public static void Write(Texture2D atlas, string path)
        {
            byte[] pngData = atlas.EncodeToPNG();
            string pngPath = Application.dataPath + regex.Replace(path, "", 1);
            File.WriteAllBytes(pngPath, pngData);

            LogAtlasSize(atlas, path);
        }

        private static void LogAtlasSize(Texture2D atlas, string path) {
            if (atlas.width > FAVOR_ATLAS_SIZE || atlas.height > FAVOR_ATLAS_SIZE) {
                Debug.Log(string.Format("<color=#ff0000>【警告】图集宽度或高度超过1024像素： {0} </color>", path));
            } else {
                Debug.Log(string.Format("<color=#0000ff>图集 {0} 尺寸为： {1}x{2}</color>", path, atlas.width, atlas.height));
            }
        }
    }
}
