using UnityEngine;
using UnityEditor;
using System;
using System.Collections;
using System.Collections.Generic;
using Object = UnityEngine.Object;

namespace EditorTools.Inspector {
    public class AssetDependencyInspector : EditorWindow {
        private static AssetDependencyInspector _window;

        private Object[] _selectedObjs;
        private Vector2 _scrollPosition;

        [MenuItem("Window/AssetDependencyInspector")]
        public static void Main() {
            _window = EditorWindow.GetWindow<AssetDependencyInspector>("AssetDependencyInspector");
            _window.Show();
        }

        private void OnGUI() {
            try {
                _selectedObjs = GetSelectedObjects();
                if (_selectedObjs != null) {
                    foreach (Object o in _selectedObjs) {
                        GUILayout.Label(AssetDatabase.GetAssetPath(o));
                    }
                    Object[] objs = EditorUtility.CollectDependencies(_selectedObjs);
                    _scrollPosition = GUILayout.BeginScrollView(_scrollPosition);
                    foreach (Object o in objs) {
                        GUILayout.BeginHorizontal();
                        GUILayout.Space(40);
                        GUILayout.Label(o.name, GUILayout.Width(200));
                        GUILayout.Label(o.GetType().Name, GUILayout.Width(160));
                        GUILayout.Label(AssetDatabase.GetAssetPath(o));
                        GUILayout.EndHorizontal();
                    }
                    GUILayout.EndScrollView();
                }
            } catch (Exception e) {
                Debug.LogException(e);
            }
        }

        private Object[] GetSelectedObjects() {
            return Selection.GetFiltered(typeof(Object), SelectionMode.Assets);
        }

        private void OnDestroy() {
            _selectedObjs = null;
        }

    }
}