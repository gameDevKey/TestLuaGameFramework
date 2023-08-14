using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ShanShuo.EditorSdk.Variables
{
    public class EditorVector3Int : EditorVariables<Vector3Int>
    {
        public EditorVector3Int() : base("Vector3Int")
        {
            this.Value = Vector3Int.zero;
        }

        public static implicit operator EditorVector3Int(Vector3Int value) { return new EditorVector3Int { Value = value }; }

        public override void DrawInspector()
        {
            Value = EditorGUILayout.Vector3IntField("", Value);
        }

        public override void ReadValue(Dictionary<string, object> data)
        {
            Value = new Vector3Int(Convert.ToInt32(data["x"]), Convert.ToInt32(data["y"]), Convert.ToInt32(data["z"]));
        }

        public override void Clone(object data)
        {
            Vector3Int srcData = (Vector3Int)data;
            Vector3Int newData = new Vector3Int(srcData.x, srcData.y, srcData.z);
            Value = newData;
        }
    }
}
