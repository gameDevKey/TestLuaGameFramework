using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

namespace ShanShuo.EditorSdk.Variables
{
    public abstract class EditorVariables
    {
        protected EditorVariables(string type)
        {
            this.Type = type;
        }

        public string Name { get; set; }
        public string Type { get;}
        public object Args { get; set; }
        public string Label { get; set; }
        public abstract object GetValue();
        public abstract void SetValue(object value);
        public abstract void SaveConfig(StreamWriter sw);
        public abstract void DrawInspector();
        public abstract void DrawFieldInspector();
        public abstract void ReadValue(Dictionary<string, object> data);
        public abstract void Clone(object data);
    }

    public abstract class EditorVariables<T> : EditorVariables
    {
        protected EditorVariables(string type):base(type)
        {

        }

        public T Value { get; set; }

        public override void SetValue(object value)
        {
            this.Value = (T)value;
        }

        public override object GetValue()
        {
            return this.Value;
        }

        public override string ToString()
        {
            return Value.ToString();
        }

        public override void SaveConfig(StreamWriter sw)
        {

        }

        public override void DrawInspector()
        {
            GUILayout.Label("该变量类型没有重写DrawInspector");
        }

        public override void DrawFieldInspector()
        {
            GUILayout.Label("该变量类型没有重写DrawFieldInspector");
        }

        public override void ReadValue(Dictionary<string, object> data)
        {

        }

        public override void Clone(object data)
        {
            this.Value = (T)data;
        }

        public void SetArgs(object args)
        {
            Args = args;
        }
    }

}

