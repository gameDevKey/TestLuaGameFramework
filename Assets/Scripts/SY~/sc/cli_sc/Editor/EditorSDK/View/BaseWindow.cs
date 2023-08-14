using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ShanShuo.EditorSdk.View
{
    public class BaseWindow : EditorWindow
    {
        Dictionary<string, BaseView> views = new Dictionary<string, BaseView>();

        protected void AddView(string name,BaseView view)
        {
            views.Add(name,view);
        }

        protected bool inited = false;

        void OnGUI()
        {
            if (!inited)
            {
                Initialize();
            }

            foreach (var v in views)
            {
                GUILayout.BeginArea(v.Value.Rect,v.Value.Style);
                v.Value.OnGUI();
                GUILayout.EndArea();
            }
        }

        void Initialize()
        {
            inited = true;
            foreach (var v in views)
            {
                v.Value.OnInit();
            }
        }
    }
}


