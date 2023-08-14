using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ShanShuo.EditorSdk.Variables
{
    public class EditorTransform : EditorVariables<Transform>
    {
        public EditorTransform() : base("Transform")
        {
            Value = null;
        }

        public static implicit operator EditorTransform(Transform value) { return new EditorTransform { Value = value }; }

        public override void DrawInspector()
        {
            Value = (Transform)EditorGUILayout.ObjectField(Value, typeof(Transform), true);
        }

        public override void ReadValue(Dictionary<string, object> data)
        {
            //Value = (string)data["value"];
        }

    }
}
