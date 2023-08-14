using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class PsdExporter
{
    [MenuItem("工具库/UI/导出Psd预设")]
    public static void ExporterPrefab()
    {
        string psdFile = selectPsdFile();
        if (string.IsNullOrEmpty(psdFile))
        {
            return;
        }

        PsdExporterFacade.Instance.InitComplete();

        PsdParse psdParse = new PsdParse();
        psdParse.Parse(psdFile);

        psdParse.HasError();

        PsdExporterProxy.Instance.SelectPsd = psdParse;

        PsdGenCtrl.Instance.ExportPrefab(psdParse);

        AssetDatabase.Refresh();
    }


    [MenuItem("工具库/UI/导出Psd图片")]
    public static void ExporterTexture()
    {
        string psdFile = selectPsdFile();
        if (string.IsNullOrEmpty(psdFile))
        {
            return;
        }

        PsdExporterFacade.Instance.InitComplete();

        PsdParse psdParse = new PsdParse();
        psdParse.Parse(psdFile);

        psdParse.HasError();

        PsdExporterProxy.Instance.SelectPsd = psdParse;

        PsdGenCtrl.Instance.ExportTexture(psdParse);

        AssetDatabase.Refresh();
    }

    static string selectPsdFile()
    {
        string dir = EditorPrefs.GetString("psd_file", string.Empty);
        if (string.IsNullOrEmpty(dir))
        {
            dir = Application.dataPath;
        }
        string psdFile = EditorUtility.OpenFilePanel("选择一个psd文件", dir, "psd");
        if (!string.IsNullOrEmpty(psdFile))
        {
            EditorPrefs.SetString("psd_file", psdFile);
        }
        return psdFile;
    }
}
