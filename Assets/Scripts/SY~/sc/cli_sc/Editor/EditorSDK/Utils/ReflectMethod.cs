using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEditor;
using UnityEngine;

namespace ShanShuo.EditorSdk.Utils
{
    public class ReflectMethod
    {
        public static string SearchField(string value, params GUILayoutOption[] options)
        {
            MethodInfo info = typeof(EditorGUILayout).GetMethod("ToolbarSearchField", BindingFlags.NonPublic | BindingFlags.Static, null, new System.Type[] { typeof(string), typeof(GUILayoutOption[]) }, null);
            if (info != null)
            {
                value = (string)info.Invoke(null, new object[] { value, options });
            }
            return value;
        }
    }
}


