using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PsdExporterFacade : Facade
{
    protected override void OnInit()
    {
        BindCtrl(new PsdGenCtrl());
        BindProxy(new PsdExporterProxy());
        base.OnInit();
    }
}


