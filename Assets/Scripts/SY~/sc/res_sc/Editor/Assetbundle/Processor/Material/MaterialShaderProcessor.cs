using System.IO;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace EditorTools.AssetBundle {
    public class MaterialShaderProcessor {
        public MaterialShaderProcessor() {

        }

        public HashSet<string> Process(string entryPath, Material material, StrategyNode node) {
            HashSet<string> result = new HashSet<string>();
            if (material == null) {
                Debug.LogError ("资源打包出错, 缺少Material:" + entryPath);
            }
            string materialPath = MaterialAssetProcessor.GetMaterialPath(material);
            string shaderPath = MaterialAssetProcessor.GetShaderPath(material.shader,entryPath);
            if (node.pattern.IsMatch(shaderPath) == true)
            {
                MaterialJsonData jsonData = MaterialJsonData.GetMaterialJsonData(materialPath);
                jsonData.shaderFileName = GetShaderFileName(material.shader);
                jsonData.shaderKey = AssetPathHelper.GetObjectKey(entryPath, shaderPath, material.shader, node);
                jsonData.FillNonTexturePropertyData(material, node);
                result.Add(shaderPath);
            }
            return result;
        }

        private string GetShaderFileName(Shader shader) {
            string path = AssetDatabase.GetAssetPath(shader);
            return Path.GetFileNameWithoutExtension(path);
        }
    }
}
