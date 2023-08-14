using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

public class AEDelayChildPlayAnimBehaviour : StateMachineBehaviour
{
    [SerializeField]
    public GameObject node;

    [SerializeField]
    public string nodePath;

    [SerializeField]
    public bool initInvisible;

    [SerializeField]
    public string animName;

    [SerializeField]
    public string eventId;

    [SerializeField]
    public int animLayer;

    [SerializeField]
    public float beginTime;

    [SerializeField]
    public float intervalTime;

    static LuaFunction animPlayFunc;

    public static void SetAnimPlayFunc(LuaTable owner, string animFunc)
    {
        AEDelayChildPlayAnimBehaviour.animPlayFunc = owner.Get<LuaFunction>(animFunc);
    }  

    public override void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        if (node == null && !string.IsNullOrEmpty(nodePath))
        {
            Transform nodeTrans = animator.gameObject.transform.Find(nodePath);
            node = nodeTrans ? nodeTrans.gameObject : null;
        }

        if(node == null)
        {
            return;
        }

        var time = beginTime;
        // var anims = node.GetComponentsInChildren<Animator>();  // 获取所有子节点孙节点的Animator
        var anims = GetChildrenAnimatorComponent(node);  // 只获取子节点的Animator
        foreach(var anim in anims)
        {
            PlayAnim(anim,stateInfo,time);
            time += intervalTime;
        }
    }

    public Animator[] GetChildrenAnimatorComponent(GameObject node)
    {
        var childCount = node.transform.childCount;
        Animator[] anims = new Animator[childCount];
        int index = 0;
        foreach (Transform item in node.transform)
        {
            var animator = item.gameObject.GetComponent<Animator>();
            anims[index] = animator;
            index += 1;
        }
        return anims;
    }

    async void PlayAnim(Animator animator, AnimatorStateInfo stateInfo, float delayTime)
    {
        if (animator)
        {
            if (initInvisible)
            {
                animator.gameObject.SetActive(false);
            }

            if (delayTime > 0)
            {
                await new WaitForSeconds(delayTime);
            }

            if( animator == null ) return;
#if UNITY_EDITOR && !DEV_EDITOR
            if (initInvisible)
            {
                animator.gameObject.SetActive(true);
            }

            if(!string.IsNullOrEmpty(animName))
            {
                animator.Play(animName, animLayer, 0);
            }
#endif
            animPlayFunc.Call(animator.gameObject.GetInstanceID(),stateInfo.shortNameHash,eventId,animName);
        }
    }
}
