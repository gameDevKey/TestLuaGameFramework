using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace EditorTools.AssetBundle {
    public class MaterialTextureProcessor {
        public MaterialTextureProcessor() {

        }

        /// <summary>
        /// 分离材质依赖的贴图资源，其中go上的Renderer类型的组件通过添加AssetBridge记录依赖信息，uGUI Image组件不需要记录依赖信息
        /// </summary>
        /// <param name="entryPath"></param>
        /// <param name="go"></param>
        /// <param name="material"></param>
        /// <param name="node"></param>
        /// <returns></returns>
        public HashSet<string> Process(string entryPath, Material material, StrategyNode node) {
            HashSet<string> result = new HashSet<string>();
            string materialPath = MaterialAssetProcessor.GetMaterialPath(material);
            MaterialJsonData jsonData = MaterialJsonData.GetMaterialJsonData(materialPath);
            int count = ShaderUtil.GetPropertyCount(material.shader);
            for (int i = 0; i < count; i++) {
                ShaderUtil.ShaderPropertyType type = ShaderUtil.GetPropertyType(material.shader, i);
                if (type == ShaderUtil.ShaderPropertyType.TexEnv) {
                    string propertyName = ShaderUtil.GetPropertyName(material.shader, i);
                    Texture texture = material.GetTexture(propertyName);
                    if (texture != null) {
                        string texturePath = MaterialAssetProcessor.GetTexturePath(texture,entryPath);
                        if (node.pattern.IsMatch(texturePath) == true) {
                            jsonData.FillTexturePropertyData(entryPath, material, propertyName, texturePath, texture, node);
                            result.Add(texturePath);
                        }
                    }
                }
            }
            return result;
        }

        public string GetTexturePropertyName(Material material, string texturePath) {
            string result = string.Empty;
            int count = ShaderUtil.GetPropertyCount(material.shader);
            for (int i = 0; i < count; i++) {
                ShaderUtil.ShaderPropertyType type = ShaderUtil.GetPropertyType(material.shader, i);
                if (type == ShaderUtil.ShaderPropertyType.TexEnv) {
                    string propertyName = ShaderUtil.GetPropertyName(material.shader, i);
                    Texture texture = material.GetTexture(propertyName);
                    if (texturePath == MaterialAssetProcessor.GetTexturePath(texture)) {
                        result = propertyName;
                    }
                }
            }
            return result;
        }

    }
}
