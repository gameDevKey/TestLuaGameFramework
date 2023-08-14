using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ShanShuo.EditorSdk.Variables
{
    public class EditorTable : EditorVariables<string>
    {
        public EditorTable() : base("Table")
        {
            Value = string.Empty;
        }

        public static implicit operator EditorTable(string value) { return new EditorTable { Value = value }; }

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
