using System.Collections.Generic;
using UnityEngine;

namespace EditorTools.AssetBundle {
    public class ParticleSystemRendererMeshProcessor : ComponentProcessor {
        public ParticleSystemRendererMeshProcessor() {
            this.Name = "ParticleSystemRendererMesh";
        }

        public override HashSet<string> Process(string entryPath, GameObject go, StrategyNode node) {
            HashSet<string> result = new HashSet<string>();
            ParticleSystemRenderer renderer = go.GetComponent<ParticleSystemRenderer>();
            if (renderer != null && renderer.mesh != null) {
                string meshPath = GetMeshPath(renderer.mesh);
                if (node.pattern.IsMatch(meshPath) == true) {
                    result.Add(meshPath);
                }
            }
            return result;
        }

    }
}
