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

        behaviour.initInvisible = EditorGUILayout.Toggle("初始隐藏", behaviour.initInvisible);
        behaviour.animName = EditorGUILayout.DelayedTextField("动画名", behaviour.animName);
        behaviour.animLayer = EditorGUILayout.DelayedIntField("动画层", behaviour.animLayer);
        behaviour.beginTime = EditorGUILayout.DelayedFloatField("开始时间", behaviour.beginTime);
        behaviour.intervalTime = EditorGUILayout.DelayedFloatField("间隔时间", behaviour.intervalTime);
        behaviour.eventId = EditorGUILayout.DelayedTextField("事件ID(可选)", behaviour.eventId);
    }
}
