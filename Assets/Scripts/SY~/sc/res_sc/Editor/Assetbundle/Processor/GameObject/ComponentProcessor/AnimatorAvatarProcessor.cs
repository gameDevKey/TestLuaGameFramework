using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace EditorTools.AssetBundle {
    public class AnimatorAvatarProcessor : ComponentProcessor {
        public AnimatorAvatarProcessor() {
            this.Name = "AnimatorAvatar";
        }

        public override HashSet<string> Process(string entryPath, GameObject go, StrategyNode node) {
            HashSet<string> result = new HashSet<string>();
            Animator animator = go.GetComponent<Animator>();
            if (animator != null && animator.avatar != null) {
                string avatarPath = AssetDatabase.GetAssetPath(animator.avatar);
                if (node.pattern.IsMatch(avatarPath) == true) {
                    string avatarKey = AssetPathHelper.GetObjectKey(entryPath, avatarPath, animator.avatar, node);
                    result.Add(avatarPath);
                }
            }
            return result;
        }
    }
}
