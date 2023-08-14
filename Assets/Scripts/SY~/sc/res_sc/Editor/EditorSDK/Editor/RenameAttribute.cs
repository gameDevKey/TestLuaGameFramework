using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ShanShuo.EditorSdk.Editor
{
    public class RenameAttribute : PropertyAttribute
    {
        public string name;
        public RenameAttribute(string name)
        {
            this.name = name;
        }
    }

    [CustomPropertyDrawer(typeof(RenameAttribute))]
    public class RenameDrawer : PropertyDrawer
    {
        public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
        {
            RenameAttribute rename = (RenameAttribute)attribute;
            label.text = rename.name;
            EditorGUI.PropertyField(position, property, label);
        }
    }
}

