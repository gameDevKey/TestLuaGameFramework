using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;

namespace EditorTools.AssetBundle {
    public class TextMeshFontProcessor : ComponentProcessor {

        public TextMeshFontProcessor() {
            this.Name = "TextMeshFont";
        }

        public override HashSet<string> Process(string entryPath, GameObject go, StrategyNode node) {
            HashSet<string> result = new HashSet<string>();
            TextMesh textMesh = go.GetComponent<TextMesh>();
            if (textMesh != null && textMesh.font != null) {
                string fontPath = FontAssetProcessor.GetFontPath(textMesh.font);
                if (node.pattern.IsMatch(fontPath) == true) {
                    result.Add(fontPath);
                }
            }
            return result;
        }
    }
}

