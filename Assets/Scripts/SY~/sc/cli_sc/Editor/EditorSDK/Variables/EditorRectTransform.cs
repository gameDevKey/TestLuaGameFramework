using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ShanShuo.EditorSdk.Variables
{
    public class EditorRectTransform : EditorVariables<RectTransform>
    {
        public EditorRectTransform() : base("RectTransform")
        {
            Value = null;
        }

        public static implicit operator EditorRectTransform(RectTransform value) { return new EditorRectTransform { Value = value }; }

        public override void DrawInspector()
        {
            Value = (RectTransform)EditorGUILayout.ObjectField(Value, typeof(RectTransform), true);
        }

        public override void ReadValue(Dictionary<string, object> data)
        {
            //Value = (string)data["value"];
        }

    }
}
