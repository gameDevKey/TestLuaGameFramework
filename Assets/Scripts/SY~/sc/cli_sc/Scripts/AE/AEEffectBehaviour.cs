using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

public class AEEffectBehaviour : StateMachineBehaviour
{
    [System.Serializable]
    public class AnimEffectInfo
    {
        public GameObject node;
        public string path;
        public float beginTime;
        public float lastTime;
        public string effectId;
        public Vector3 scale;
        public Vector3 pos;
        public int order;
        [System.NonSerialized] public GameObject effect;
    }

    [SerializeField]
    public List<AnimEffectInfo> effectInfos = new List<AnimEffectInfo>();

    public int num;

    static LuaFunction animEffectFunc;

    public static void SetAnimEffectFunc(LuaTable owner, string animEffectFunc)
    {
        AEEffectBehaviour.animEffectFunc = owner.Get<LuaFunction>(animEffectFunc);
    }

    public override void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        foreach(AnimEffectInfo info in effectInfos)
        {
            if(animEffectFunc != null)
            {
                animEffectFunc.Call(animator.gameObject.GetInstanceID(),stateInfo.shortNameHash,info);
            }
            else
            {
                EditorPlayEffect(info);
            }
        }
    }

    public override void OnStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
#if UNITY_EDITOR
        foreach(AnimEffectInfo info in effectInfos)
        {
            if (info.effect != null)
            {
                info.effect.transform.localPosition = info.pos;
                info.effect.transform.localScale = info.scale;
            }
        }
#endif
    }

    async void EditorPlayEffect(AnimEffectInfo info)
    {
        if(info.beginTime > 0)
        {
            await new WaitForSeconds(info.beginTime);
        }

        string effectFile = "Assets/Res/effect/" + info.effectId + ".prefab";

        Object original = null;

#if UNITY_EDITOR
        original = UnityEditor.AssetDatabase.LoadAssetAtPath(effectFile,typeof(GameObject));
#endif

        Transform parent = info.node ? info.node.transform : null;
        GameObject effect =  (GameObject)Instantiate(original, parent);
        effect.transform.localPosition = info.pos;
        effect.transform.localEulerAngles = Vector3.zero;
        effect.transform.localScale = info.scale;
        info.effect = effect;

        if(info.lastTime > 0)
        {
            await new WaitForSeconds(info.lastTime);
            GameObject.Destroy(effect);
        }
    }
    
}
