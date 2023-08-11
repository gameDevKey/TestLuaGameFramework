using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using UnityEditor;
using UnityEngine;

namespace PsdUIExporter {
    public class SliceAction {

        private SliceWindow window = null;
        private string path = null;

        private Texture2D texture = null;
        private Texture2D tmpTexture = null;
        private PSlice pslice = new PSlice();

        public SliceAction(SliceWindow window, string path) {
            this.window = window;
            this.path = path;
        }

        int statue = 3;
        public int Next() {
            statue--;
            switch (statue) {
                case 2:
                    SelectTexture();
                    break;
                case 1:
                    AutoSlice();
                    break;
                case 0:
                    SaveTexture();
                    break;
            }
            return statue;
        }

        // 2
        private void SelectTexture() {
            if (File.Exists(path)) {
                texture = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
                window.texture = texture;
                window.path = path;
                window.tmpTexture = null;
                window.pslice = new PSlice();
                window.Repaint();
            }
        }

        // 1
        private void AutoSlice() {
            if (texture != null) {
                bool only = window.onlySliceModule;
                if (!only || (only && ExportUtility.IsSliceSprite(path))) {
                    SliceWinUtility.ImportReadableTexture(path, true);
                    tmpTexture = SliceWinUtility.Slice(texture, pslice);
                    window.tmpTexture = tmpTexture;
                    window.pslice = pslice;
                    SliceWinUtility.ImportReadableTexture(path, false);
                    window.Repaint();
                    if (tmpTexture == null) {
                        Debug.LogError("图片不可切割：" + path);
                        if (window.warnMsg == null) {
                            window.warnMsg = "图片不可切割：" + (new FileInfo(path)).Name;
                        } else {
                            window.warnMsg = window.warnMsg + ", " + (new FileInfo(path)).Name;
                        }
                    }
                } else {
                    if (only) {
                        if (window.warnMsg == null) {
                            window.warnMsg = "图片不可切割：" + (new FileInfo(path)).Name;
                        } else {
                            window.warnMsg = window.warnMsg + ", " + (new FileInfo(path)).Name;
                        }
                        window.Repaint();
                    }
                }
            }
        }

        // 0
        private void SaveTexture() {
            if (tmpTexture != null) {
                SliceWinUtility.SaveTexture(path, tmpTexture, pslice);
                window.Repaint();
            }
        }

    }
}
