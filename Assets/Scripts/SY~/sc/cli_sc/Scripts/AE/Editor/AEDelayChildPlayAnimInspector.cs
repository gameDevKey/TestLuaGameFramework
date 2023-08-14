using ShanShuo.EditorSdk.Utils;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(AEDelayChildPlayAnimBehaviour))]
public class AEDelayChildPlayAnimInspector : Editor
{
    AEDelayChildPlayAnimBehaviour behaviour;

    void OnEnable()
    {
        if (target != null)
        {
            behaviour = (AEDelayChildPlayAnimBehaviour)target;
        }
    }

    public override void OnInspectorGUI()
    {
        behaviour.node = (GameObject)EditorGUILayout.ObjectField(behaviour.node, typeof(GameObject), true);

        if (behaviour.node != null)
        {
            behaviour.nodePath = UIUtils.GetTransformPath(behaviour.node.transform);
        }

        behaviour.nodePath = EditorGUILayout.DelayedTextField(behaviour.nodePath);

        EditorGUILayout.Space();
        EditorGUILayout.Space();
        EditorGUILayout.Space();

        behaviour.initInvisible = EditorGUILayout.Toggle("��ʼ����", behaviour.initInvisible);
        behaviour.animName = EditorGUILayout.DelayedTextField("������", behaviour.animName);
        behaviour.animLayer = EditorGUILayout.DelayedIntField("������", behaviour.animLayer);
        behaviour.beginTime = EditorGUILayout.DelayedFloatField("��ʼʱ��", behaviour.beginTime);
        behaviour.intervalTime = EditorGUILayout.DelayedFloatField("���ʱ��", behaviour.intervalTime);
        behaviour.eventId = EditorGUILayout.DelayedTextField("�¼�ID(��ѡ)", behaviour.eventId);
    }
}
