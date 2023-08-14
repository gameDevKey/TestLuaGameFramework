using ShanShuo.EditorSdk.Utils;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(AEEffectBehaviour))]
public class AEEffectBehaviourInspector : Editor
{
    AEEffectBehaviour behaviour;

    void OnEnable()
    {
        if(target != null)
        {
            behaviour = (AEEffectBehaviour)target;
        }
    }

    public override void OnInspectorGUI()
    {
        behaviour.num = EditorGUILayout.DelayedIntField("��Ч����", behaviour.num);
        if(behaviour.num < 0)
        {
            behaviour.num = 0;
        }

        EditorGUILayout.Space();
        EditorGUILayout.Space();
        EditorGUILayout.Space();

        if (behaviour.effectInfos.Count < behaviour.num)
        {
            AEEffectBehaviour.AnimEffectInfo effectInfo = new AEEffectBehaviour.AnimEffectInfo();
            behaviour.effectInfos.Add(effectInfo);
        }
        else if(behaviour.effectInfos.Count > behaviour.num)
        {
            for(int i=0;i< behaviour.effectInfos.Count  - behaviour.num;i++)
            {
                behaviour.effectInfos.RemoveAt(behaviour.effectInfos.Count - 1);
            }
        }

        for(int i=0;i< behaviour.effectInfos.Count;i++)
        {
            if(i > 0)
            {
                EditorGUILayout.Space();
                EditorGUILayout.Space();
            }
            AEEffectBehaviour.AnimEffectInfo effectInfo = behaviour.effectInfos[i];
            effectInfo.node = (GameObject)EditorGUILayout.ObjectField(effectInfo.node, typeof(GameObject),true);
            if(effectInfo.node != null)
            {
                effectInfo.path = UIUtils.GetTransformPath(effectInfo.node.transform);
            }
            EditorGUILayout.DelayedTextField(effectInfo.path);
            effectInfo.beginTime = EditorGUILayout.DelayedFloatField("��ʼʱ��(��)", effectInfo.beginTime);
            if(effectInfo.beginTime < 0) effectInfo.beginTime = 0;

            effectInfo.lastTime = EditorGUILayout.DelayedFloatField("����ʱ��(��)", effectInfo.lastTime);
            if(effectInfo.lastTime < 0) effectInfo.lastTime = 0;

            effectInfo.effectId = EditorGUILayout.DelayedTextField("��ЧId", effectInfo.effectId);

            effectInfo.order = EditorGUILayout.DelayedIntField("��Բ㼶(��Χ[-10,10])", effectInfo.order);
            effectInfo.order = Mathf.Clamp(effectInfo.order, -10, 10);

            effectInfo.pos = EditorGUILayout.Vector3Field("λ��", effectInfo.pos);

            effectInfo.scale = EditorGUILayout.Vector3Field("����", effectInfo.scale);
            if (effectInfo.scale == Vector3.zero)effectInfo.scale = Vector3.one;

            behaviour.effectInfos[i] = effectInfo;
        }

        if(GUI.changed)
        {
            EditorUtility.SetDirty(target);
        }
    }
}
