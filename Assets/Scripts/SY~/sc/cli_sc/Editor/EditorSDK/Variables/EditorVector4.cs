using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ShanShuo.EditorSdk.Variables
{
    public class EditorVector4 : EditorVariables<Vector4>
    {
        public EditorVector4() : base("Vector4")
        {
            this.Value = Vector4.zero;
        }

        public static implicit operator EditorVector4(Vector4 value) { return new EditorVector4 { Value = value }; }

        public override void DrawInspector()
        {
            Value = EditorGUILayout.Vector4Field("", Value);
        }

        public override void ReadValue(Dictionary<string, object> data)
        {
            Value = new Vector4(Convert.ToSingle(data["x"]), Convert.ToSingle(data["y"]), Convert.ToSingle(data["z"]), Convert.ToSingle(data["w"]));
        }

        public override void Clone(object data)
        {
            Vector4 srcData = (Vector4)data;
            Vector4 newData = new Vector4(srcData.x, srcData.y, srcData.z, srcData.w);
            Value = newData;
        }
    }
}
