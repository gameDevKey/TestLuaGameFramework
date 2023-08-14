using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.UI;

public class AEMaterialBehaviour : StateMachineBehaviour
{
    [SerializeField]
    public GameObject node;

    [SerializeField]
    public string nodePath;

    [SerializeField]
    public List<MaterialAnim.Data> Property = new List<MaterialAnim.Data>();


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

        MaterialAnim materialAnim = node.GetComponent<MaterialAnim>();
        if(materialAnim == null)
        {
            materialAnim = node.AddComponent<MaterialAnim>();
        }

        materialAnim.InitAnim();
        materialAnim.Property = Property;
    }
}
