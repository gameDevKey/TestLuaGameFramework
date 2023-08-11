using System;
using System.Collections.Generic;
using System.Diagnostics;

public class Facade : ModuleBase<Facade>
{
    private Dictionary<Type, Controller<object>> m_Ctrls;
    private Dictionary<Type, Proxy<object>> m_Proxys;

    protected void BindCtrl<T>(T ctrl) where T:Controller<T>,new()
    {
        var target = ctrl as Controller<object>;
        target.SetFacade(this);
        var success = m_Ctrls.TryAdd(target.GetType(), target);
        Debug.Assert(success, "Facade重复绑定Ctrl");
    }

    protected void BindProxy<T>(T proxy) where T:Proxy<T>,new()
    {
        var target = proxy as Proxy<object>;
        target.SetFacade(this);
        var success = m_Proxys.TryAdd(target.GetType(), target);
        Debug.Assert(success, "Facade重复绑定Proxy");
    }

    // public T GetCtrl<T>() where T:ModuleBase<object>
    // {
    //     object target;
    //     m_Ctrls.TryGetValue(typeof(T), out target);
    //     return target as T;
    // }

    // public T GetProxy<T>() where T:Proxy<T>,new()
    // {
    //     object target;
    //     m_Proxys.TryGetValue(typeof(T), out target);
    //     return target as T;
    // }

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