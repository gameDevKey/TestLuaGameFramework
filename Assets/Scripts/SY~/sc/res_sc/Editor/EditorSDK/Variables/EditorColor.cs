using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ShanShuo.EditorSdk.Variables
{
    public class EditorColor : EditorVariables<Color>
    {
        public EditorColor() : base("Color")
        {
            Value = Color.white;
        }

        public static implicit operator EditorColor(Color value) { return new EditorColor { Value = value }; }

        public override void DrawInspector()
        {
            Value = EditorGUILayout.ColorField(Value);
        }

        public override void ReadValue(Dictionary<string, object> data)
        {
            Value = new Color(Convert.ToSingle(data["r"]), Convert.ToSingle(data["g"]), Convert.ToSingle(data["b"]), Convert.ToSingle(data["a"]));
        }

        public override void Clone(object data)
        {
            Color srcData = (Color)data;
            Color newData = new Color(srcData.r, srcData.g, srcData.b, srcData.a);
            Value = newData;
        }
    }
}
