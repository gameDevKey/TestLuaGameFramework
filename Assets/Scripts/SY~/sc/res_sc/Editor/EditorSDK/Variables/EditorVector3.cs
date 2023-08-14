using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ShanShuo.EditorSdk.Variables
{
    public class EditorVector3 : EditorVariables<Vector3>
    {
        public EditorVector3() : base("Vector3")
        {
            this.Value = Vector3.zero;
        }

        public static implicit operator EditorVector3(Vector3 value) { return new EditorVector3 { Value = value }; }

        public override void DrawInspector()
        {
            Value = EditorGUILayout.Vector3Field("",Value);
        }

        public override void ReadValue(Dictionary<string, object> data)
        {
            Value = new Vector3(Convert.ToSingle(data["x"]), Convert.ToSingle(data["y"]), Convert.ToSingle(data["z"]));
        }

        public override void Clone(object data)
        {
            Vector3 srcData = (Vector3)data;
            Vector3 newData = new Vector3(srcData.x, srcData.y, srcData.z);
            Value = newData;
        }
    }
}
