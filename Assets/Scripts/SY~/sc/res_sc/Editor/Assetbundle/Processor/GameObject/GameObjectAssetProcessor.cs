using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;
using System.Text.RegularExpressions;
using EditorTools.UI;

namespace EditorTools.AssetBundle {
    public class GameObjectAssetProcessor : AssetProcessor {

        private Dictionary<string, ComponentProcessor> _componentProcessorDict;

        public GameObjectAssetProcessor() {
            _componentProcessorDict = new Dictionary<string, ComponentProcessor>();

            AddComponentProcessor(new AnimatorControllerProcessor());
            AddComponentProcessor(new AnimationProcessor());
            AddComponentProcessor(new AtlasProcessor());
            AddComponentProcessor(new AnimatorAvatarProcessor());
            AddComponentProcessor(new TextFontProcessor());
            AddComponentProcessor(new ImageMaterialProcessor());
            AddComponentProcessor(new ImageShaderProcessor());
            AddComponentProcessor(new MeshFilterProcessor());
            AddComponentProcessor(new ParticleSystemRendererMeshProcessor());
            AddComponentProcessor(new RendererMaterialProcessor());
            AddComponentProcessor(new RendererMaterialShaderProcessor());
            AddComponentProcessor(new RendererMaterialTextureProcessor());
            AddComponentProcessor(new SkinnedMeshRendererMeshProcessor());
            AddComponentProcessor(new TextMeshFontProcessor());
            AddComponentProcessor(new LightMapExrProcessor());
        }

        private void AddComponentProcessor(ComponentProcessor processor) {
            _componentProcessorDict.Add(processor.Name, processor);
        }

        private ComponentProcessor GetComponentProcessor(string name) {
            if (_componentProcessorDict.ContainsKey(name) == false) {
                string msg = name + " Processor not found!";
                AssetBundleExporter.ThrowException(msg);
            }
            return _componentProcessorDict[name];
        }

        protected override Object GetAsset(string path)
        {
            Object go = AssetDatabase.LoadAssetAtPath(path, typeof(Object));
            if (UIPrefabProcessor.UI_PREFAB_ROOT_SHADOW_PATTERN.IsMatch(path) == true)
            {
                go = PrefabUtility.InstantiatePrefab(go) as GameObject;
            }
            return go;
        }

        protected override void SaveAsset(Object asset, string path)
        {
            if (UIPrefabProcessor.UI_PREFAB_ROOT_SHADOW_PATTERN.IsMatch(path) == true)
            {
                GameObject go = asset as GameObject;
                PrefabUtility.UnpackPrefabInstance(go, PrefabUnpackMode.Completely, InteractionMode.AutomatedAction);
                PrefabUtility.SaveAsPrefabAssetAndConnect(go, path, InteractionMode.AutomatedAction);
                Object.DestroyImmediate(asset, true);
            }
        }


        protected override HashSet<string> ApplyStrategyNode(string entryPath, Object asset, StrategyNode node) {
            GameObject go = asset as GameObject;
            HashSet<string> result = new HashSet<string>();
            ComponentProcessor processor = GetComponentProcessor(node.processor);
            HashSet<string> sub = processor.Process(entryPath, go, node);
            result.UnionWith(sub);
            int count = go.transform.childCount;
            for (int i = 0; i < count; i++) {
                GameObject child = go.transform.GetChild(i).gameObject;
                result.UnionWith(ApplyStrategyNode(entryPath, child, node));
            }
            return result;
        }
    }
}
