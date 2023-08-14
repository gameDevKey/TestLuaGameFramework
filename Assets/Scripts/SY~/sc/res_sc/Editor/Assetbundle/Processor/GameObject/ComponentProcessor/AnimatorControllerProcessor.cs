using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace EditorTools.AssetBundle {
    /// <summary>
    /// 若业务需要可以将AnimatorController和AnimationClip进行分离打包
    /// </summary>
    public class AnimatorControllerProcessor : ComponentProcessor {
        public AnimatorControllerProcessor() {
            this.Name = "AnimatorController";
        }

        public override HashSet<string> Process(string entryPath, GameObject go, StrategyNode node) {
            HashSet<string> result = new HashSet<string>();
            Animator animator = go.GetComponent<Animator>();
            if (animator != null && animator.runtimeAnimatorController != null) {
                string controllerPath = AssetDatabase.GetAssetPath(animator.runtimeAnimatorController);
                if (node.pattern.IsMatch(controllerPath) == true) {
                    string controllerKey = AssetPathHelper.GetObjectKey(entryPath, controllerPath, animator.runtimeAnimatorController, node);
                    result.Add(controllerPath);
                }
            }
            return result;
        }
    }
}
