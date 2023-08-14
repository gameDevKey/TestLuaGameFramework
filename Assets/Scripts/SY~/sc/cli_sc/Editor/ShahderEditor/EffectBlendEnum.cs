using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class EffectBlendEnum : MaterialPropertyDrawer
{

    static readonly string[] BlendType = new string[2] {
    "Add","Blend"


    };
    GUIContent[] contents = new GUIContent[2]
    {
        new GUIContent(BlendType[0]), new GUIContent(BlendType[1])
        // new GUIContent(BlendType[2]),
        // new GUIContent(BlendType[3])

};


    public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
    {


        base.OnGUI(position, prop, label, editor);
        EditorGUI.BeginChangeCheck();
        EditorGUI.showMixedValue = prop.hasMixedValue;
        float value = prop.floatValue;
        value = EditorGUI.Popup(position, label, (int)value, contents);
        EditorGUI.showMixedValue = false;
        if (EditorGUI.EndChangeCheck())
        {

            EnumChange(prop, (int)value);
        }

    }

    public string _SrcBlend = "_SrcBlend";
    public string _DestBlend = "_DestBlend";
    public string _ZTest = "_ZTest";
    public string _BlendOP = "_BlendOP";

    private void EnumChange(MaterialProperty prop, int value)
    {
        var objs = prop.targets;
        prop.floatValue = value;
        foreach (var i in objs)
        {

            var mat = (i as Material);
            
            switch (value)
            {
                case 0:
                    //ADD
                    mat.SetInt(_SrcBlend, 1);
                    mat.SetInt(_DestBlend, 1);
                    mat.SetInt(_BlendOP, 0);
                    Debug.Log("Value is 0 or 1");
                    break;
                case 1:
                    //SRC BLEND
                    mat.SetInt(_SrcBlend, 5);
                    mat.SetInt(_BlendOP, 0);
                    mat.SetInt(_DestBlend, 10);
                    break;
            }
            

            Debug.Log("Value Change :" + value);
        }
    }
}
