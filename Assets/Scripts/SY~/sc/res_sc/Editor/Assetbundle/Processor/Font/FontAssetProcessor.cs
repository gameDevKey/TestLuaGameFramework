using System;
using System.IO;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Object = UnityEngine.Object;

namespace EditorTools.AssetBundle {
    public class FontAssetProcessor : AssetProcessor {
        protected override Object GetAsset(string path) {
            return AssetDatabase.LoadAssetAtPath(path, typeof(Font));
        }

        protected override HashSet<string> ApplyStrategyNode(string path, Object asset, StrategyNode node) {
            HashSet<string> result = new HashSet<string>();
            string[] depentAssetPaths = AssetDatabase.GetDependencies(new string[] { path });
            foreach (string s in depentAssetPaths) {
                if (node.pattern.IsMatch(s) == true) {
                    result.Add(s);
                }
            }
            return result;
        }

        public static string GetFontPath(Font font) {
            string path = AssetDatabase.GetAssetPath(font);
            if (Path.GetExtension(path) == string.Empty) {
                string msg = "发现不带后缀的内置Font，请使用项目中创建的资源代替，或者调整策略不分离该资源:  " + path + " " + font.name;
                AssetBundleExporter.ThrowException(msg);
            }
            return path;
        }
    }
}
