using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEditor.IMGUI.Controls;
using UnityEngine;

namespace PsdUIExporter {
    public class SliceWinUtility {

        public static Texture2D Slice(Texture2D tex, PSlice ps) {
            Texture2D tmpTexture = null;
            if (tex == null)
                return null;
            PSlice rect;
            if (ps.top == 0 && ps.bottom == 0 && ps.left == 0 && ps.right == 0) {
                rect = TextureSlicer.AutoSlice(tex);
                ps.top = rect.top;
                ps.right = rect.right;
                ps.bottom = rect.bottom;
                ps.left = rect.left;
            } else {
                rect = new PSlice(ps.top, ps.right, ps.bottom, ps.left);
            }
            if ((rect.top + rect.right + rect.bottom + rect.left) > 1) {
                tmpTexture = TextureSlicer.Slice(tex, rect);
            }
            return tmpTexture;
        }

        public static void ImportReadableTexture(TextureImporter importer, string path, bool readable) {
            importer.isReadable = readable;
            AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
        }

        public static void ImportReadableTexture(string path, bool readable) {
            TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter;
            importer.isReadable = readable;
            AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
        }

        public static void SaveTexture(string path, Texture2D texture, PSlice pslice) {
            byte[] buf = ExportUtility.EncordToPng(texture);
            string dir = Path.GetDirectoryName(path);
            if (!Directory.Exists(dir)) {
                Directory.CreateDirectory(dir);
            }
            File.WriteAllBytes(Path.GetFullPath(path), buf);
            AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
            ExportUtility.SetPlatformTextureSettings(path, 2048, ExportUtility.TRUE_COLOR);
            if (pslice != null) {
                TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter;
                importer.spriteBorder = new Vector4(pslice.left, pslice.bottom, pslice.right, pslice.top);
            }
            AssetDatabase.ImportAsset(path);
        }
    }
}
