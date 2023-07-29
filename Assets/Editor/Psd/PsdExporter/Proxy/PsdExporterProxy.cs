using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ShanShuo.EditorSdk.Frame;

namespace ShanShuo.PsdExporter
{
    public class PsdExporterProxy : Proxy
    {
        public const string NAME = "PsdExporterProxy";

        public PsdExporterProxy() : base(NAME)
        {

        }

        public static PsdExporterProxy Instance
        {
            get
            {
                return (PsdExporterProxy)PsdExporterFacade.Instance.GetProxy(NAME);
            }
        }

        public override void OnInitComplete()
        {
            loadSetting();
        }

        public PsdParse selectPsd;
        public PsdExporterSetting setting;

        void loadSetting()
        {
            string settingFile = Application.dataPath + "/Editor/UI/PsdExporter/Src/Setting/setting.json";
            setting = new PsdExporterSetting();
            setting.ParseSetting(settingFile);
        }


    }
}


