using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ShanShuo.EditorSdk.Variables
{
    public class EditorClass : EditorVariables<string>
    {
        public EditorClass() : base("Class")
        {
            Value = string.Empty;
        }

        public static implicit operator EditorClass(string value) { return new EditorClass { Value = value }; }

        public override void DrawInspector()
        {
            Value = EditorGUILayout.TextField(Value);
        }

        public override void ReadValue(Dictionary<string, object> data)
        {
            Value = (string)data["value"];
        }
    }
}
