using System.Collections.Generic;
using UnityEngine;

namespace EditorTools.AssetBundle {
    public class MeshFilterProcessor : ComponentProcessor {
        public MeshFilterProcessor() {
            this.Name = "MeshFilter";
        }

        public override HashSet<string> Process(string entryPath, GameObject go, StrategyNode node) {
            HashSet<string> result = new HashSet<string>();
            MeshFilter filter = go.GetComponent<MeshFilter>();
            if (filter != null && filter.sharedMesh != null) {
                string meshPath = GetMeshPath(filter.sharedMesh);
                if (node.pattern.IsMatch(meshPath) == true) {
                    result.Add(meshPath);
                }
            }
            return result;
        }
    }
}
