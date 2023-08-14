using System.Collections.Generic;
using UnityEngine;

namespace EditorTools.AssetBundle {
    public class RendererMaterialShaderProcessor : ComponentProcessor {
        private MaterialShaderProcessor _shaderProcessor;

        public RendererMaterialShaderProcessor() {
            this.Name = "RendererMaterialShader";
            _shaderProcessor = new MaterialShaderProcessor();
        }

        public override HashSet<string> Process(string entryPath, GameObject go, StrategyNode node) {
            HashSet<string> result = new HashSet<string>();
            Renderer[] renderers = go.GetComponents<Renderer>();
            for (int i = 0; i < renderers.Length; i++) {
                Material[] materials = renderers[i].sharedMaterials;
                for (int j = 0; j < materials.Length; j++) {
					if (materials [j] != null) {
						result.UnionWith (_shaderProcessor.Process (entryPath, materials [j], node));
					}
                }
            }
            return result;
        }
    }
}
