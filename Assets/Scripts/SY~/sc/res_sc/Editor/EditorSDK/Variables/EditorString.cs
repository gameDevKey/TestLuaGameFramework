using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ShanShuo.EditorSdk.Variables
{
    public class EditorString : EditorVariables<string>
    {
        public EditorString() : base("String")
        {
            Value = string.Empty;
        }

        public EditorString(string type) : base(type)
        {
            Value = string.Empty;
        }

        public static implicit operator EditorString(string value) { return new EditorString { Value = value }; }

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
