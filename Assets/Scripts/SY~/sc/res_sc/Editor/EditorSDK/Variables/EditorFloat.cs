using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ShanShuo.EditorSdk.Variables
{
    public class EditorFloat : EditorVariables<float>
    {
        public EditorFloat() : base("Float")
        {
            Value = 0.0f;
        }

        public static implicit operator EditorFloat(float value) { return new EditorFloat { Value = value }; }

        public override void DrawInspector()
        {
            Value = EditorGUILayout.FloatField(Value);
        }

        public override void ReadValue(Dictionary<string, object> data)
        {
            Value = Convert.ToSingle(data["value"]);
        }
    }
}
