using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ShanShuo.EditorSdk.Variables
{
    public class EditorBool : EditorVariables<bool>
    {
        public EditorBool():base("Bool")
        {
            this.Value = false;
        }

        public static implicit operator EditorBool(bool value) { return new EditorBool { Value = value }; }

        public override void DrawInspector()
        {
            this.Value = EditorGUILayout.Toggle(Value);
        }

        public override void ReadValue(Dictionary<string, object> data)
        {
            Value = bool.Parse(((string)data["value"]));
        }
    }
}
