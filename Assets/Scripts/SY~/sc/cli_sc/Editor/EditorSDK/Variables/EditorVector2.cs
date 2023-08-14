using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ShanShuo.EditorSdk.Variables
{
    public class EditorVector2 : EditorVariables<Vector2>
    {
        public EditorVector2() : base("Vector2")
        {
            this.Value = Vector2.zero;
        }

        public static implicit operator EditorVector2(Vector2 value) { return new EditorVector2 { Value = value }; }

        public override void DrawInspector()
        {
            Value = EditorGUILayout.Vector2Field("", Value);
        }

        public override void ReadValue(Dictionary<string, object> data)
        {
            Value = new Vector2(Convert.ToSingle(data["x"]), Convert.ToSingle(data["y"]));
        }

        public override void Clone(object data)
        {
            Vector2 srcData = (Vector2)data;
            Vector2 newData = new Vector2(srcData.x, srcData.y);
            Value = newData;
        }
    }
}
