using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ShanShuo.EditorSdk.Frame
{
    public class Controller
    {
        public string CtrlName { get; protected set; }

        public Controller(string ctrlName)
        {
            CtrlName = ctrlName;
            OnInit();
        }

        protected virtual void OnClear()
        {
        }

        protected virtual void OnInit()
        {
        }

        public virtual void OnInitComplete()
        {

        }
    }
}
