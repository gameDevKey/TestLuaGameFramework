using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PsdExporterFacade : Facade
{
    public const string NAME = "PsdExporterFacade";

    public static PsdExporterFacade Instance
    {
        get { return GetFacade(NAME) as PsdExporterFacade; }
    }

    public PsdExporterFacade() : base(NAME)
    {

    }

    protected override void OnInit()
    {
        base.OnInit();

        BindCtrl(new PsdGenCtrl());

        BindProxy(new PsdExporterProxy());
    }
}


