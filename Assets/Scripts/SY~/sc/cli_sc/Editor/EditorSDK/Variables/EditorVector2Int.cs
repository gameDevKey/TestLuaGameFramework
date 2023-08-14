using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ShanShuo.EditorSdk.Variables
{
    public class EditorVector2Int : EditorVariables<Vector2Int>
    {
        public EditorVector2Int() : base("Vector2Int")
        {
            this.Value = Vector2Int.zero;
        }

        public static implicit operator EditorVector2Int(Vector2Int value) { return new EditorVector2Int { Value = value }; }

        public override void DrawInspector()
        {
            Value = EditorGUILayout.Vector2IntField("", Value);
        }

        public override void ReadValue(Dictionary<string, object> data)
        {
            Value = new Vector2Int(Convert.ToInt32(data["x"]), Convert.ToInt32(data["y"]));
        }

        public override void Clone(object data)
        {
            Vector2Int srcData = (Vector2Int)data;
            Vector2Int newData = new Vector2Int(srcData.x, srcData.y);
            Value = newData;
        }
    }
}
