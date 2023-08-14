using System.Collections.Generic;
using UnityEngine;

namespace EditorTools.AssetBundle {
    public class SkinnedMeshRendererMeshProcessor : ComponentProcessor {
        public SkinnedMeshRendererMeshProcessor() {
            this.Name = "SkinnedMeshRendererMesh";
        }

        public override HashSet<string> Process(string entryPath, GameObject go, StrategyNode node) {
            HashSet<string> result = new HashSet<string>();
            SkinnedMeshRenderer renderer = go.GetComponent<SkinnedMeshRenderer>();
            if (renderer != null && renderer.sharedMesh != null) {
                string meshPath = GetMeshPath(renderer.sharedMesh);
                if (node.pattern.IsMatch(meshPath) == true) {
                    result.Add(meshPath);
                }
            }
            return result;
        }

    }
}
