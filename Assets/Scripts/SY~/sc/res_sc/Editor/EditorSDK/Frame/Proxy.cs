using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ShanShuo.EditorSdk.Frame
{
    public class Proxy
    {
        public string ProxyName { get; protected set; }

        public Proxy(string proxyName)
        {
            ProxyName = proxyName;
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


