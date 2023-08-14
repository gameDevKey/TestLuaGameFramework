using ShanShuo.EditorSdk.Utils;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

[CustomEditor(typeof(AEMaterialBehaviour))]
public class AEMaterialInspector : Editor
{
    AEMaterialBehaviour behaviour;

    void OnEnable()
    {
        if (target != null)
        {
            behaviour = (AEMaterialBehaviour)target;
        }
    }



    public override void OnInspectorGUI()
    {
        var dirty = false;
        GameObject lastNode = behaviour.node;
        behaviour.node = (GameObject)EditorGUILayout.ObjectField(behaviour.node, typeof(GameObject), true);
        
        if(lastNode != null && behaviour.node != lastNode)
        {
            dirty = true;
            GameObject.Destroy(lastNode.GetComponent<MaterialAnim>());
        }

        if (behaviour.node != null && dirty)
        {
            behaviour.nodePath = UIUtils.GetTransformPath(behaviour.node.transform);
        }

        EditorGUILayout.DelayedTextField(behaviour.nodePath);

        EditorGUILayout.Space();
        EditorGUILayout.Space();
        EditorGUILayout.Space();

        if (behaviour.node != null && (behaviour.node.GetComponent<MaterialAnim>() == null || behaviour.Property.Count <= 0))
        {
            MaskableGraphic graphic =  behaviour.node.GetComponent<MaskableGraphic>();

            MaterialAnim materialAnim = behaviour.node.GetComponent<MaterialAnim>();
            if (materialAnim == null)
            {
                materialAnim = behaviour.node.AddComponent<MaterialAnim>();
                materialAnim.InitAnim();
                materialAnim.ActiveEditorUpdate(true);
            }

            behaviour.Property.Clear();
            materialAnim.Property.Clear();

            Shader shader = graphic.material.shader;
            int count = shader.GetPropertyCount();
            for (int i = 0; i < count; i++)
            {
                behaviour.Property.Add(new MaterialAnim.Data() { name = shader.GetPropertyName(i), type = shader.GetPropertyType(i).ToString() });
                materialAnim.Property.Add(new MaterialAnim.Data() { name = shader.GetPropertyName(i), type = shader.GetPropertyType(i).ToString() });
            }
        }

        if (behaviour.node != null && behaviour.node.GetComponent<MaterialAnim>() != null)
        {
            MaterialAnim materialAnim = behaviour.node.GetComponent<MaterialAnim>();
            for (int i = 0; i < behaviour.Property.Count; i++)
            {
                behaviour.Property[i].enable = EditorGUILayout.Toggle(behaviour.Property[i].name, behaviour.Property[i].enable);
                materialAnim.Property[i].enable = behaviour.Property[i].enable;
            }
        }
        else
        {
            for (int i = 0; i < behaviour.Property.Count; i++)
            {
                EditorGUILayout.Toggle(behaviour.Property[i].name, behaviour.Property[i].enable);
            }
        }
    }
}
