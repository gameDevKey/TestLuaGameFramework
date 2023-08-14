using UnityEditor;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using System.Reflection;

namespace EditorTools.Inspector {
    public class AssetPoolInspector : EditorWindow {
        private static AssetPoolInspector _window;

        private Vector2 _scrollPosition;
        private string input = "";
        private string searchInput = "";

        [MenuItem("Window/AssetPoolInspector")]
        public static void Main() {
            _window = EditorWindow.GetWindow<AssetPoolInspector>("AssetPoolInspector");
            _window.Show();
        }

        private void OnGUI() {
            if (Application.isPlaying) {
                try {
                    Refresh();
                } catch (Exception e) {
                    Debug.LogException(e);
                }
            }
        }

        private Dictionary<string, bool> showDetailDict = new Dictionary<string, bool>();


        private void Refresh() {
            Type type = GetAssetManagerType();
            if (type == null) return;

            _scrollPosition = EditorGUILayout.BeginScrollView(_scrollPosition);
            Color recordColor = GUI.backgroundColor;
            GUILayout.BeginHorizontal();
            GUILayout.Label("搜索:", GUILayout.Width(90f), GUILayout.Height(20));
            input = EditorGUILayout.TextField(input, GUILayout.Width(320f));
            if (GUILayout.Button("确定", GUILayout.Width(80f))) {
                if (input.Trim().Length == 0) {
                    searchInput = "";
                } else {
                    DoSearch(input);
                }
            }
            GUILayout.EndHorizontal();
            MethodInfo GetAssetDict = type.GetMethod("GetAssetDict", BindingFlags.Static | BindingFlags.Public);
            Dictionary<string, List<string>> assetDict = GetAssetDict.Invoke(null, null) as Dictionary<string, List<string>>;
            MethodInfo GetAssetReferenceCountDict = type.GetMethod("GetAssetReferenceCountDict", BindingFlags.Static | BindingFlags.Public);
            Dictionary<string, int> assetReferenceCountDict = GetAssetReferenceCountDict.Invoke(null, null) as Dictionary<string, int>;

            string text = string.Format("==========================Active Asset Total = {0}==========================", assetDict.Count);
            GUILayout.Button(text);

            foreach (string key in GetSortedKeys(assetDict.Keys))
            {
                if (!showDetailDict.ContainsKey(key))
                {
                    showDetailDict[key] = false;
                }


                GUILayout.BeginHorizontal();
                GUI.backgroundColor = Color.yellow;

                int count = 0;
                assetReferenceCountDict.TryGetValue(key, out count);
                string countStr = "引用次数: " + count.ToString();
                if (GUILayout.Button(countStr, GUILayout.Width(80)))
                {
                    showDetailDict[key] = !showDetailDict[key];
                }

                GUI.backgroundColor = Color.gray;
                GUI.skin.label.normal.textColor = Color.yellow;
                GUI.backgroundColor = Color.yellow;
                GUILayout.Label(key);
                GUILayout.EndHorizontal();
                List<string> list = assetDict[key];

                GUI.skin.label.normal.textColor = Color.white;
                if (showDetailDict[key])
                {
                    foreach (string s in list)
                    {
                        GUILayout.BeginHorizontal();
                        GUILayout.Space(100);
                        GUILayout.Label(s);
                        GUILayout.EndHorizontal();
                    }
                }


            }
            GUI.backgroundColor = Color.red;
            GUILayout.Button("============================Asset To Delete============================");
            GUI.backgroundColor = recordColor;
            MethodInfo GetZeroReferenceAssetSet = type.GetMethod("GetZeroReferenceAssetSet", BindingFlags.Static | BindingFlags.Public);
            HashSet<string> set = GetZeroReferenceAssetSet.Invoke(null, null) as HashSet<string>;
            foreach (string key in set) {
                GUILayout.Label(key);
            }
            EditorGUILayout.EndScrollView();
        }

        private void DoSearch(string input) {
            searchInput = input;
        }

        private Type GetAssetManagerType() {
            Assembly[] assemblies = AppDomain.CurrentDomain.GetAssemblies();
            for (int i = 0; i < assemblies.Length; i++) {
                Assembly assembly = assemblies[i];
                Type type = assembly.GetType("Game.Asset.AssetManager");
                if (type != null) {
                    return type;
                }
            }
            return null;
        }

        private string[] GetSortedKeys(ICollection collection) {
            // string[] result = new string[collection.Count];
            // collection.CopyTo(result, 0);
            // Array.Sort<string>(result);
            // return result;
            List<string> list = new List<string>();
            foreach (string s in collection) {
                if (searchInput != null && searchInput.Trim().Length > 0) {
                    if (s.ToLower().Contains(searchInput.Trim().ToLower())) {
                        list.Add(s);
                    }
                } else {
                    list.Add(s);
                }
            }
            string[] result = list.ToArray();
            Array.Sort<string>(result);
            return result;
        }
    }
}

