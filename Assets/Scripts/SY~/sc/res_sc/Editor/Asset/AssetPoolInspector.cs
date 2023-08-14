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

        private void Refresh() {
            Type type = GetAssetManagerType();
            if (type == null) return;

            _scrollPosition = EditorGUILayout.BeginScrollView(_scrollPosition);
            Color recordColor = GUI.backgroundColor;
            GUI.backgroundColor = Color.green;
            GUILayout.Button("==========================Active Asset Dictionary==========================");
            GUI.backgroundColor = recordColor;
            MethodInfo GetAssetDict = type.GetMethod("GetAssetDict", BindingFlags.Static | BindingFlags.Public);
            Dictionary<string, List<string>> assetDict = GetAssetDict.Invoke(null, null) as Dictionary<string, List<string>>;
            MethodInfo GetAssetReferenceCountDict = type.GetMethod("GetAssetReferenceCountDict", BindingFlags.Static | BindingFlags.Public);
            Dictionary<string, int> assetReferenceCountDict = GetAssetReferenceCountDict.Invoke(null, null) as Dictionary<string, int>;
            foreach (string key in GetSortedKeys(assetDict.Keys)) {
                GUILayout.BeginHorizontal();
                GUI.backgroundColor = Color.yellow;
                GUILayout.Button("Asset", GUILayout.Width(50));
                GUI.backgroundColor = Color.gray;
                int count = 0;
                assetReferenceCountDict.TryGetValue(key, out count);
                GUILayout.Button("引用次数: " + count.ToString(), GUILayout.Width(80));
                GUI.backgroundColor = recordColor;
                GUILayout.Label(key);
                GUILayout.EndHorizontal();
                List<string> list = assetDict[key];
                foreach (string s in list) {
                    GUILayout.BeginHorizontal();
                    GUILayout.Space(50);
                    GUI.backgroundColor = Color.cyan;
                    GUILayout.Button("Object", GUILayout.Width(50));
                    GUI.backgroundColor = recordColor;
                    GUILayout.Label(s);
                    GUILayout.EndHorizontal();
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
            string[] result = new string[collection.Count];
            collection.CopyTo(result, 0);
            Array.Sort<string>(result);
            return result;
        }

    }
}

