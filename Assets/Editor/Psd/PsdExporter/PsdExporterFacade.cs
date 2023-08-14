using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PsdExporterFacade : Facade
{
    public static PsdExporterFacade Instance => Singleton<PsdExporterFacade>.Instance;

    protected override void OnInit()
    {
        BindCtrl<PsdGenCtrl>();
        BindProxy<PsdExporterProxy>();
        base.OnInit();
    }
}


