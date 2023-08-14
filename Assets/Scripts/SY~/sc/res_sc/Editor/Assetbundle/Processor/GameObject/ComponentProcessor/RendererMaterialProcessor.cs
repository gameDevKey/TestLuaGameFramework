using System;
using System.Collections.Generic;
using UnityEngine;

namespace EditorTools.AssetBundle {
    public class RendererMaterialProcessor : ComponentProcessor {
        private MaterialProcessor _materialProcessor;

        public RendererMaterialProcessor() {
            this.Name = "RendererMaterial";
            _materialProcessor = new MaterialProcessor();
        }

        public override HashSet<string> Process(string entryPath, GameObject go, StrategyNode node) {
            HashSet<string> result = new HashSet<string>();
            Renderer[] renderers = go.GetComponents<Renderer>();
            for (int i = 0; i < renderers.Length; i++) {
                Renderer renderer = renderers[i];
                Material[] materials = renderer.sharedMaterials;
                List<string> materialKeyList = new List<string>();
                for (int j = 0; j < materials.Length; j++) {
                    HashSet<string> materialScriptableObjectPathSet = _materialProcessor.Process(entryPath, materials[j], node);
                    if (materialScriptableObjectPathSet.Count > 0) {
                        result.UnionWith(materialScriptableObjectPathSet);
                    }
                }
            }
            return result;
        }

        private void AddMaterialEntry(GameObject go, string rendererType, string[] materialKeys) {
            string[] tokens = new string[materialKeys.Length + 1];
            tokens[0] = rendererType;
            Array.Copy(materialKeys, 0, tokens, 1, materialKeys.Length);
            AssetBridgeHelper.AddEntry(go, "RendererMaterial", tokens);
        }

    }
}
