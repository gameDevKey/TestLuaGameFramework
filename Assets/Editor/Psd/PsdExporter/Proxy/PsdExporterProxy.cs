using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class PsdExporterProxy : Proxy
{
    public static PsdExporterProxy Instance => PsdExporterFacade.Instance.GetProxy<PsdExporterProxy>() as PsdExporterProxy;

    public PsdParse SelectPsd;
    public PsdSetting Setting;

    public string OutputPath;
    public Transform UIRoot;
    public List<string> CommonTexPaths;
    public Dictionary<string, Font> Fonts;

    protected override void OnInit()
    {
        base.OnInit();
        CommonTexPaths = new List<string>();
        Fonts = new Dictionary<string, Font>();
    }

    protected override void OnInitComplete()
    {
        CreateOrLoadSetting();
        InitSetting();
    }

    private void CreateOrLoadSetting()
    {
        string path = PsdSetting.SettingPath;
        Setting = AssetDatabase.LoadAssetAtPath<PsdSetting>(path);
        if (Setting == null)
        {
            Setting = ScriptableObject.CreateInstance<PsdSetting>();
            AssetDatabase.CreateAsset(Setting, path);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            Debug.Log("创建PsdSetting:" + path);
        }
        else
        {
            Debug.Log("读取PsdSetting:" + path);
        }
    }

    private void InitSetting()
    {
        var uIRootObj = GameObject.Find(Setting.UIRootName);
        if (uIRootObj == null)
        {
            uIRootObj = new GameObject(Setting.UIRootName);
        }
        UIRoot = uIRootObj.transform;
        Debug.Log("Psd预设挂载点:" + UIRoot);
        OutputPath = Application.dataPath + "/" + Setting.OutputPath;
        Debug.Log("Psd输出路径:" + OutputPath);
    }
}



