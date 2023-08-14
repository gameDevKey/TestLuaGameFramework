using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ShanShuo.EditorSdk.Frame
{
    public class Facade
    {
        public string FacadeName { get; protected set; }

        Dictionary<string, Proxy> proxys = new Dictionary<string, Proxy>();
        Dictionary<string, Controller> ctrls = new Dictionary<string, Controller>();

        static Dictionary<string, Facade> facades = new Dictionary<string, Facade>();


        public delegate void ViewEventFunc(object args);
        Dictionary<string,List<ViewEventFunc>> events = new Dictionary<string, List<ViewEventFunc>>();

        public Facade(string facadeName)
        {
            FacadeName = facadeName;
            facades[FacadeName] = this;

            OnInit();

            foreach(var v in proxys)
            {
                v.Value.OnInitComplete();
            }

            foreach (var v in ctrls)
            {
                v.Value.OnInitComplete();
            }
        }

        public static Facade GetFacade(string facadeName)
        {
            return facades.ContainsKey(facadeName) ? facades[facadeName] : null;
        }

        public void BindProxy(Proxy proxy)
        {
            proxys[proxy.ProxyName] = proxy;
        }

        public Proxy GetProxy(string proxyName)
        {
            return proxys.ContainsKey(proxyName) ? proxys[proxyName] : null;
        }

        public void BindEvent(string eventName, ViewEventFunc func)
        {
            if(!events.ContainsKey(eventName))
            {
                events.Add(eventName, new List<ViewEventFunc>());
            }

            events[eventName].Add(func);
        }

        public void SendEvent(string eventName,object args = null)
        {
            if (!events.ContainsKey(eventName))
            {
                return;
            }

            foreach(var func in events[eventName])
            {
                func(args);
            }
        }

        public void BindCtrl(Controller ctrl)
        {
            ctrls[ctrl.CtrlName] = ctrl;
        }

        public Controller GetCtrl(string ctrlName)
        {
            return ctrls.ContainsKey(ctrlName) ? ctrls[ctrlName] : null;
        }

        protected virtual void OnInit()
        {
        }
    }
}


