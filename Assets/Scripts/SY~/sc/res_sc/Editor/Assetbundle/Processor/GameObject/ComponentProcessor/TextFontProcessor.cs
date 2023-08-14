using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEditor;


namespace EditorTools.AssetBundle {
    /// <summary>
    /// UnityEngine.UI库中Text组件依赖的Font资源分离
    /// </summary>
    public class TextFontProcessor : ComponentProcessor {
        public TextFontProcessor() {
            this.Name = "TextFont";
        }

        public override HashSet<string> Process(string entryPath, GameObject go, StrategyNode node) {
            HashSet<string> result = new HashSet<string>();
            Text text = go.GetComponent<Text>();
            if (text != null && text.font != null) {
                string fontPath = AssetDatabase.GetAssetPath(text.font);
                if (node.pattern.IsMatch(fontPath) == true) {
                    result.Add(fontPath);
                }
            }
            return result;
        }
    }
}
