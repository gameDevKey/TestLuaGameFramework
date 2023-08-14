using System.IO;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Object = UnityEngine.Object;

namespace EditorTools.AssetBundle {
    public class MaterialAssetProcessor : AssetProcessor {
        private const string SHADER = "Shader";
        private const string TEXTURE = "Texture";
        private const string MATERIAL = "Material";

        private MaterialShaderProcessor _shaderProcessor;
        private MaterialTextureProcessor _textureProcessor;
        private MaterialProcessor _materialProcessor;

        public MaterialAssetProcessor() {
            _shaderProcessor = new MaterialShaderProcessor();
            _textureProcessor = new MaterialTextureProcessor();
            _materialProcessor = new MaterialProcessor();
        }

        protected override Object GetAsset(string path) {
            return AssetDatabase.LoadAssetAtPath(path, typeof(Material));
        }

        protected override HashSet<string> ApplyStrategyNode(string entryPath, Object asset, StrategyNode node) {
            Material material = asset as Material;
            HashSet<string> result = new HashSet<string>();
            switch (node.processor) {
                case SHADER:
                    result = _shaderProcessor.Process(entryPath, material, node);
                    break;
                case TEXTURE:
                    result = _textureProcessor.Process(entryPath, material, node);
                    break;
                case MATERIAL:
                    result = _materialProcessor.Process(entryPath, material, node);
                    break;
            }
            return result;
        }

        public static string GetMaterialPath(Material material) {
            string path = AssetDatabase.GetAssetPath(material);
            if (Path.GetExtension(path) == string.Empty && !path.StartsWith("Resources")) {
                string msg = "使用了不带.mat后缀的内置Material，请使用项目创建的Material代替: " + material.name;
                AssetBundleExporter.ThrowException(msg);
            }
            return path;
        }

        public static string GetShaderPath(Shader shader, string originPath = null)
        {
            string path = AssetDatabase.GetAssetPath(shader);
            //TODO:
            if (Path.GetExtension(path) == string.Empty && !path.StartsWith("Resources") && !shader.name.Equals("Hidden/InternalErrorShader"))  {
                string msg = "使用了不带.shader后缀的内置Shader，请使用项目中创建的Shader代替: " + shader.name + "该资源路径 :" + originPath;
                AssetBundleExporter.ThrowException(msg);
            }
            return path;
        }

        public static string GetTexturePath(Texture texture,string originPath=null){
            string path = AssetDatabase.GetAssetPath(texture);
			if (texture != null && Path.GetExtension(path) == string.Empty) {
                string msg = "使用了不带后缀的内置Texture，请使用项目中创建的Texture代替: " + texture.name + "问题文件位于: " + originPath;
                AssetBundleExporter.ThrowException(msg);
            }
            return path;
        }

    }
}
