using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ShanShuo.EditorSdk.Variables
{
    public class EditorInt : EditorVariables<int>
    {
        public EditorInt() : base("Int")
        {
            Value = 0;
        }

        public static implicit operator EditorInt(int value) { return new EditorInt { Value = value }; }

        public override void DrawInspector()
        {
            Value = EditorGUILayout.IntField(Value);
        }

        public override void ReadValue(Dictionary<string, object> data)
        {
            Value = Convert.ToInt32(data["value"]);
        }
    }
}
