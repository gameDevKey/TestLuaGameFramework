using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using UnityEditor;
using UnityEditor.IMGUI.Controls;
using UnityEngine;

namespace PsdUIExporter {
    public class SliceWindow : EditorWindow {

        public Texture2D texture = null;
        public string path = null;
        public Texture2D tmpTexture = null;
        public PSlice pslice = new PSlice();
        private string module = null;
        public SliceAuto sliceAuto = null;
        public string warnMsg = null;

        public bool onlySliceSingle = false;
        public bool onlySliceModule = true;

        private void OnGUI() {
            GUILayout.BeginHorizontal();
            GUILayout.Space(5);
            BuildLeftArea();
            GUILayout.Space(5);
            BuildRightArea();
            GUILayout.EndHorizontal();
        }

        private void Update() {
            if (sliceAuto != null) {
                sliceAuto.Update(Time.deltaTime);
            }
        }

        private void BuildLeftArea() {
            int width = 200;
            GUILayout.BeginVertical(GUILayout.Width(width), GUILayout.ExpandHeight(true));
            GUILayout.Space(5);
            GUIStyle style = new GUIStyle();
            style.fontStyle = FontStyle.Bold;
            style.normal.textColor = new Color(1, 1, 1);
            GUILayout.Label(" 九宫格切割图片",  style);
            GUILayout.Box("", new []{GUILayout.Height(1), GUILayout.ExpandWidth(true)});
            EditorGUIUtility.labelWidth = 100;
            EditorGUI.BeginChangeCheck();
            texture = EditorGUILayout.ObjectField("拖入或选择图片", texture, typeof(Texture2D), false) as Texture2D;
            if (EditorGUI.EndChangeCheck()) {
                pslice = new PSlice();
                tmpTexture = null;
                warnMsg = null;
                if (texture != null) {
                    path = AssetDatabase.GetAssetPath(texture);
                } else {
                    path = null;
                }
            }
            GUILayout.Space(5);
            EditorGUIUtility.labelWidth = 130;
            onlySliceSingle = EditorGUILayout.Toggle("仅作用于已设置九宫图片:", onlySliceSingle);
            EditorGUIUtility.labelWidth = 50;
            GUILayout.BeginHorizontal();
            pslice.left = EditorGUILayout.IntField("left:", pslice.left);
            pslice.top = EditorGUILayout.IntField("top:", pslice.top);
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            pslice.right = EditorGUILayout.IntField("right:", pslice.right);
            pslice.bottom = EditorGUILayout.IntField("bottom:", pslice.bottom);
            GUILayout.EndHorizontal();
            using (new EditorGUILayout.HorizontalScope()) {
                if (GUILayout.Button("切割")) {
                    if (texture != null) {
                        string path = AssetDatabase.GetAssetPath(texture);
                        if (!onlySliceSingle || (onlySliceSingle && ExportUtility.IsSliceSprite(path))) {
                            SliceWinUtility.ImportReadableTexture(path, true);
                            tmpTexture = SliceWinUtility.Slice(texture, pslice);
                            SliceWinUtility.ImportReadableTexture(path, false);
                            if (tmpTexture == null) {
                                EditorUtility.DisplayDialog("提示", "该图不可切", "确定");
                            }
                        } else {
                            if (onlySliceSingle) {
                                EditorUtility.DisplayDialog("提示", "该图不可切【原图没有设置九宫】", "确定");
                            }
                        }

                        // // //创建文件读取流
                        // FileStream fileStream = new FileStream(path, FileMode.Open, FileAccess.Read);
                        // fileStream.Seek(0, SeekOrigin.Begin);
                        // //创建文件长度缓冲区
                        // byte[] buf = new byte[fileStream.Length];
                        // //读取文件
                        // fileStream.Read(buf, 0, (int)fileStream.Length);
                        // //释放文件读取流
                        // fileStream.Close();
                        // fileStream.Dispose();


                        // Texture2D png = new Texture2D(texture.width, texture.height, TextureFormat.RGBA32, false);
                        // byte[] buf = File.ReadAllBytes(path);
                        // png.LoadImage(buf);
                        // png.Apply();
                        // tmpTexture = SliceWinUtility.Slice(png, pslice);
                    }
                }

                if (GUILayout.Button("确定")) {
                    if (tmpTexture != null) {
                        string path = AssetDatabase.GetAssetPath(texture);
                        SliceWinUtility.SaveTexture(path, tmpTexture, pslice);
                    }
                }

                if (GUILayout.Button("原还")) {
                    tmpTexture = null;
                    pslice = new PSlice();
                }

                if (GUILayout.Button("清空")) {
                    pslice = new PSlice();
                }
            }

            GUILayout.Space(50);
            GUILayout.Label(" 九宫格一键切割【慎用】",  style);
            GUILayout.Box("", new []{GUILayout.Height(1), GUILayout.ExpandWidth(true)});
            GUILayout.Label(" 请输入模块名");
            module = EditorGUILayout.TextField(module);
            EditorGUIUtility.labelWidth = 130;
            onlySliceModule = EditorGUILayout.Toggle("仅作用于已设置九宫图片:", onlySliceModule);
            using (new EditorGUILayout.HorizontalScope()) {
                if (GUILayout.Button("一键切割")) {
                    if (module != null && module.Trim().Length > 0) {
                        if (sliceAuto == null) {
                            warnMsg = null;
                            texture = null;
                            pslice = new PSlice();
                            sliceAuto = new SliceAuto(this, module);
                        } else {
                            EditorUtility.DisplayDialog("提示", "上一个任务还没有执行完", "确定");
                        }
                    } else {
                        EditorUtility.DisplayDialog("提示", "请填写模块名", "确定");
                    }
                }
                if (GUILayout.Button("停止")) {
                    if (sliceAuto != null) {
                        sliceAuto.isStop = true;
                    }
                }
            }
            GUILayout.EndVertical();
        }

        private void BuildRightArea() {
            GUILayout.BeginVertical(GUILayout.ExpandWidth(true), GUILayout.ExpandHeight(true));
            GUILayout.Space(2);
            Texture2D tex = GetShowTexture();
            if (tex != null) {
                GUILayout.BeginHorizontal();
                GUILayout.Label("" + tex.width + "X" + tex.height, GUILayout.Width(80));
                GUILayout.Label(path);
                GUILayout.EndHorizontal();
                GUILayout.Box(GUIContent.none, new[] { GUILayout.Height(1), GUILayout.ExpandWidth(true) });
                ShowTexture(tex);
            }

            int width = (int)position.width - 230;
            int mul = 3;
            var rect = new Rect(position.width - width - 2, position.height - EditorGUIUtility.singleLineHeight * mul, width - 2, EditorGUIUtility.singleLineHeight * mul);
            GUILayout.BeginArea(rect);
            {
                GUILayout.BeginHorizontal();
                {
                    if (warnMsg != null) {
                        GUIStyle style = new GUIStyle();
                        // style.fontStyle = FontStyle.Bold;
                        style.normal.textColor = new Color(1, 0, 0);
                        style.wordWrap = true;
                        // scroll = EditorGUILayout.BeginScrollView(scroll);
                        GUILayout.TextArea(warnMsg, style, GUILayout.ExpandWidth(true), GUILayout.Height(EditorGUIUtility.singleLineHeight * mul));
                        // EditorGUILayout.EndScrollView();

                    }
                }
                GUILayout.EndHorizontal();
            }
            GUILayout.EndArea();
            GUILayout.EndVertical();
        }

        private void OnDestroy() {
        }

        private void ShowTexture(Texture2D texture) {
            if (texture == null)
                return;
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
            GUILayout.Box(texture, GUILayout.Width(width * ratio + 10), GUILayout.Height(height * ratio + 10));
        }

        private Texture2D GetShowTexture() {
            if (tmpTexture != null) {
                return tmpTexture;
            } else {
                return texture;
            }
        }

    }
}
