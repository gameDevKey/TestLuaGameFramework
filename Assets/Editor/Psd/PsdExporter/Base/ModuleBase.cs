using System;

public class ModuleBase
{
    public Facade Facade;

    public ModuleBase()
    {
        Init();
    }

    public void Init()
    {
        OnInit();
    }

    public void InitComplete()
    {
        OnInitComplete();
    }

    public void SetFacade(Facade facade)
    {
        Facade = facade;
    }

    protected virtual void OnInit() { }
    protected virtual void OnInitComplete() { }
}
