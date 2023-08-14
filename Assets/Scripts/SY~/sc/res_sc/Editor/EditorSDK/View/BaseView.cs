using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ShanShuo.EditorSdk.Frame;
using System;

namespace ShanShuo.EditorSdk.View
{
    public class BaseView
    {
        Rect rect;
        public Rect Rect
        {
            get { return rect; }
            set { rect = value; }
        }

        protected GUIStyle style;
        public GUIStyle Style
        {
            get { return style; }
            set { style = value; }
        }

        protected bool inited = false;

        Facade facade;

        public BaseView(string facade)
        {
            this.facade = Facade.GetFacade(facade);

            OnBindEvent();
        }

        public virtual void OnBindEvent()
        {

        }

        protected void BindEvent(string eventName, Facade.ViewEventFunc func)
        {
            facade.BindEvent(eventName,func);
        }

        public virtual void OnGUI()
        {
            
        }

        public virtual void OnInit()
        {

        }
    }
}
