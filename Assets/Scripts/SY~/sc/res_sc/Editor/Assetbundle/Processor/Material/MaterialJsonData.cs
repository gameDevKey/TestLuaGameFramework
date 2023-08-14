using System.IO;
using System.Collections.Generic;
using System.Text;
using UnityEditor;
using UnityEngine;
using LitJson;
using Game.Asset;

namespace EditorTools.AssetBundle {
    public class MaterialJsonData {
        public string type = "Material";
        public string shaderKey;
        public string shaderFileName;
        /// <summary>
        /// 将Shader和Meterial分离打包时（不保持其依赖关系的分离），Material不能独立存在
        /// 所以将Material中的属性以Json形式的记录，并且最终序列化ScriptableObject的形式保存
        /// </summary>
        public List<List<string>> propertyTokenListList;

        private HashSet<string> _recordPropertySet;

        public MaterialJsonData() {
            propertyTokenListList = new List<List<string>>();
            _recordPropertySet = new HashSet<string>();
        }

        public void FillTexturePropertyData(string entryPath, Material material, string propertyName, string texturePath, Texture texture, StrategyNode node) {
            if (_recordPropertySet.Contains(propertyName) == false) {
                _recordPropertySet.Add(propertyName);
                List<string> list = new List<string>();
                list.Add(ShaderUtil.ShaderPropertyType.TexEnv.ToString());
                list.Add(propertyName);
                list.AddRange(FormatTexture(entryPath, material, propertyName, texturePath, texture, node));
                propertyTokenListList.Add(list);
            }
        }

        public void FillNonTexturePropertyData(Material material, StrategyNode node) {
            int propertyCount = ShaderUtil.GetPropertyCount(material.shader);
            for (int i = 0; i < propertyCount; i++) {
                if (ShaderUtil.GetPropertyType(material.shader, i) != ShaderUtil.ShaderPropertyType.TexEnv) {
                    string propertyName = ShaderUtil.GetPropertyName(material.shader, i);
                    if (_recordPropertySet.Contains(propertyName) == false) {
                        _recordPropertySet.Add(propertyName);
                        List<string> list = GenerateNonTexturePropertyTokenList(material, i);
                        propertyTokenListList.Add(list);
                    }
                }
            }
        }

        private List<string> GenerateNonTexturePropertyTokenList(Material material, int propertyIndex) {
            List<string> result = new List<string>();
            ShaderUtil.ShaderPropertyType propertyType = ShaderUtil.GetPropertyType(material.shader, propertyIndex);
            string propertyName = ShaderUtil.GetPropertyName(material.shader, propertyIndex);
            result.Add(propertyType.ToString());
            result.Add(propertyName);
            result.AddRange(FormatNonTextureProperty(material, propertyType, propertyName));
            return result;
        }

        private List<string> FormatNonTextureProperty(Material material, ShaderUtil.ShaderPropertyType type, string propertyName) {
            List<string> result = new List<string>();
            switch (type) {
                case ShaderUtil.ShaderPropertyType.Color:
                    result = FormatColor(material, propertyName);
                    break;
                case ShaderUtil.ShaderPropertyType.Float:
                    result = FormatFloat(material, propertyName);
                    break;
                case ShaderUtil.ShaderPropertyType.Range:
                    result = FormatFloat(material, propertyName);
                    break;
                case ShaderUtil.ShaderPropertyType.Vector:
                    result = FormatVector4(material, propertyName);
                    break;
            }
            return result;
        }

        private List<string> FormatColor(Material material, string propertyName) {
            Color color = material.GetColor(propertyName);
            return new List<string>() { color.r.ToString(), color.g.ToString(), color.b.ToString(), color.a.ToString() };
        }

        private List<string> FormatFloat(Material material, string propertyName) {
            return new List<string>() { material.GetFloat(propertyName).ToString() };
        }

        private List<string> FormatVector4(Material material, string propertyName) {
            Vector4 value = material.GetVector(propertyName);
            return new List<string>() { value.x.ToString(), value.y.ToString(), value.z.ToString(), value.w.ToString() };
        }

        private List<string> FormatTexture(string entryPath, Material material, string propertyName, string texturePath, Texture texture, StrategyNode node) {
            Vector2 offset = material.GetTextureOffset(propertyName);
            Vector2 scale = material.GetTextureScale(propertyName);
            return new List<string>() { AssetPathHelper.GetObjectKey(entryPath, texturePath, texture, node), offset.x.ToString(), offset.y.ToString(), scale.x.ToString(), scale.y.ToString() };
        }

        //Key为Material路径，Value为对应的MaterialJsonData
        private static Dictionary<string, MaterialJsonData> _materialJsonDataDict = new Dictionary<string, MaterialJsonData>();

        public static void Initialize() {
            _materialJsonDataDict.Clear();
        }

        public static MaterialJsonData GetMaterialJsonData(string materialPath) {
            if (_materialJsonDataDict.ContainsKey(materialPath) == false) {
                _materialJsonDataDict.Add(materialPath, new MaterialJsonData());
            }
            return _materialJsonDataDict[materialPath];
        }

        public static string GetMaterialJsonDataPath(string materialPath) {
            return materialPath.Replace(".mat", "_shadow.json");
        }

        public static string GetMaterialScriptableObjectPath(string materialPath) {
            return materialPath.Replace(".mat", ".asset");
        }

        public static void CreateMaterialJsonAsset(string materialPath) {
            string jsonPath = GetMaterialJsonDataPath(materialPath);
            if (TemporaryAssetHelper.HasTempAsset(jsonPath) == false) {
                TemporaryAssetHelper.RecordTempAssetPath(jsonPath);
                MaterialJsonData jsonData = GetMaterialJsonData(materialPath);
                string json = JsonMapper.ToJson(jsonData);
                string filePath = AssetPathHelper.ToFileSystemPath(jsonPath);
                File.WriteAllText(filePath, json, Encoding.ASCII);
                AssetDatabase.ImportAsset(jsonPath, ImportAssetOptions.ForceUpdate);
            }
        }

        public static void CreateMaterialScriptableObjectAsset(string materialPath) {
            string objPath = GetMaterialScriptableObjectPath(materialPath);
            if (TemporaryAssetHelper.HasTempAsset(objPath) == false) {
                TemporaryAssetHelper.RecordTempAssetPath(objPath);
                MaterialJsonData jsonData = GetMaterialJsonData(materialPath);
                MaterialScriptableObject obj = ScriptableObject.CreateInstance<MaterialScriptableObject>();
                obj.type = jsonData.type;
                obj.shaderKey = jsonData.shaderKey;
                obj.shaderFileName = jsonData.shaderFileName;
                obj.propertyTokenList = new List<MaterialPropertyEntry>();
                for (int i = 0; i < jsonData.propertyTokenListList.Count; i++) {
                    obj.propertyTokenList.Add(GetMaterialPropertyEntry(jsonData.propertyTokenListList[i]));
                }
                AssetDatabase.CreateAsset(obj, GetMaterialScriptableObjectPath(materialPath));
            }
        }

        private static MaterialPropertyEntry GetMaterialPropertyEntry(List<string> list) {
            MaterialPropertyEntry entry = new MaterialPropertyEntry();
            entry.tokens = new string[list.Count];
            for (int i = 0; i < list.Count; i++) {
                entry.tokens[i] = list[i];
            }
            return entry;
        }

    }
}
