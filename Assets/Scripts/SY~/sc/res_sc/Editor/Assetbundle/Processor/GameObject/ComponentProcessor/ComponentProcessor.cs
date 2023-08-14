using System.IO;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Object = UnityEngine.Object;

namespace EditorTools.AssetBundle {
    public abstract class ComponentProcessor {
        public string Name { get; set; }
        public abstract HashSet<string> Process(string entryPath, GameObject go, StrategyNode node);

        protected void DestroyComponent<T>(GameObject go) where T : Component {
            T component = go.GetComponent<T>();
            Object.DestroyImmediate(component, true);
        }

        protected string GetMeshPath(Mesh mesh) {
            string path = AssetDatabase.GetAssetPath(mesh);
            if (Path.GetExtension(path) == string.Empty) {
                string msg = "发现不带后缀的内置Mesh，请使用项目中创建的资源代替，或者调整策略不分离该资源:  " + path + " " + mesh.name;
                AssetBundleExporter.ThrowException(msg);
            }
            return path;
        }

        protected string GetMaterialPath(Material material) {
            return MaterialAssetProcessor.GetMaterialPath(material);
        }

        protected string GetShaderPath(Shader shader) {
            return MaterialAssetProcessor.GetShaderPath(shader);
        }

        protected string GetTexturePath(Texture texture) {
            return MaterialAssetProcessor.GetTexturePath(texture);
        }

        protected void AddMeshAssetEntry(GameObject go, string asset, string objKey) {
            AssetBridgeHelper.AddEntry(go, asset, new string[] { objKey });
        }

        protected string GetVector2Token(Vector2 v) {
            return v.x.ToString() + "," + v.y.ToString();
        }
    }
}
