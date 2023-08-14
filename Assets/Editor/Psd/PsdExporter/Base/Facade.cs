using System;
using System.Collections.Generic;
using UnityDebug = UnityEngine.Debug;
using SystemDebug = System.Diagnostics.Debug;

public class Facade : ModuleBase
{
    private Dictionary<Type, Controller> m_Ctrls = new Dictionary<Type, Controller>();
    private Dictionary<Type, Proxy> m_Proxys = new Dictionary<Type, Proxy>();

    protected void BindCtrl<T>() where T : Controller, new()
    {
        var ctrl = new T();
        ctrl.SetFacade(this);
        var success = m_Ctrls.TryAdd(ctrl.GetType(), ctrl);
        SystemDebug.Assert(success, "Facade重复绑定Ctrl");
    }

    protected void BindProxy<T>() where T : Proxy, new()
    {
        var proxy = new T();
        proxy.SetFacade(this);
        var success = m_Proxys.TryAdd(proxy.GetType(), proxy);
        SystemDebug.Assert(success, "Facade重复绑定Proxy");
    }

    public Controller GetCtrl<T>() where T : Controller, new()
    {
        Controller target;
        m_Ctrls.TryGetValue(typeof(T), out target);
        return target;
    }

    public Proxy GetProxy<T>() where T : Proxy, new()
    {
        Proxy target;
        m_Proxys.TryGetValue(typeof(T), out target);
        return target;
    }

    protected override void OnInit()
    {
        foreach (var ctrl in m_Ctrls.Values)
        {
            ctrl.Init();
        }
        foreach (var proxy in m_Proxys.Values)
        {
            proxy.Init();
        }
        base.OnInit();
    }

    protected override void OnInitComplete()
    {
        base.OnInitComplete();
        foreach (var ctrl in m_Ctrls.Values)
        {
            ctrl.InitComplete();
        }
        foreach (var proxy in m_Proxys.Values)
        {
            proxy.InitComplete();
        }
    }
}