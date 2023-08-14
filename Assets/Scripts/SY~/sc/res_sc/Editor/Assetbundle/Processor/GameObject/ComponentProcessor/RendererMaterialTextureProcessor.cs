using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace EditorTools.AssetBundle {
    public class RendererMaterialTextureProcessor : ComponentProcessor {
        private MaterialTextureProcessor _textureProcessor;

        public RendererMaterialTextureProcessor() {
            this.Name = "RendererMaterialTexture";
            _textureProcessor = new MaterialTextureProcessor();
        }

        public override HashSet<string> Process(string entryPath, GameObject go, StrategyNode node) {
            HashSet<string> result = new HashSet<string>();
            Renderer[] renderers = go.GetComponents<Renderer>();
            for (int i = 0; i < renderers.Length; i++) {
                Renderer renderer = renderers[i];
                Material[] materials = renderer.sharedMaterials;
                List<string> textureKeyList = new List<string>();
                for (int j = 0; j < materials.Length; j++) {
                    if (materials[j] == null)
                        continue;
                    HashSet<string> texturePathSet = _textureProcessor.Process(entryPath, materials[j], node);
                    result.UnionWith(texturePathSet);
                }
            }
            return result;
        }
    }
}
