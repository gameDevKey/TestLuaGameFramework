using System.Collections.Generic;
using UnityEngine;

namespace EditorTools.AssetBundle {
    public class MaterialProcessor {
        public MaterialProcessor() {

        }

        public HashSet<string> Process(string entryPath, Material material, StrategyNode node) {
            HashSet<string> result = new HashSet<string>();
            string materialPath = MaterialAssetProcessor.GetMaterialPath(material);
            string objPath = MaterialJsonData.GetMaterialScriptableObjectPath(materialPath);
            if (node.pattern.IsMatch(materialPath) == true || node.pattern.IsMatch(objPath) == true) {
                MaterialJsonData.CreateMaterialScriptableObjectAsset(materialPath);
                result.Add(objPath);
            }
            return result;
        }

    }
}
