using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ZTestToggle :MaterialPropertyDrawer 
{

	bool alwaysShow;

 public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
    {


        base.OnGUI(position, prop, label, editor);
        EditorGUI.BeginChangeCheck();
        EditorGUI.showMixedValue = prop.hasMixedValue;

        if(prop.type!=MaterialProperty.PropType.Float){
			Debug.LogWarning("目标属性类型需要为float");
            return;
        }
		alwaysShow = EditorGUI.Toggle(position, label, alwaysShow);

        EditorGUI.showMixedValue = false;
        if (EditorGUI.EndChangeCheck())
        {
			OnValueChange(prop);
        }

    }   

    


    private void OnValueChange(MaterialProperty prop){

        // UnityEngine.Rendering.CompareFunction
        if(alwaysShow) prop.floatValue = 8;
        else prop.floatValue =  4;
    }

}



