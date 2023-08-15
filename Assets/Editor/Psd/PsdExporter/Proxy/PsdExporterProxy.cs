using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class PsdExporterProxy : Proxy
{
    public static PsdExporterProxy Instance => PsdExporterFacade.Instance.GetProxy<PsdExporterProxy>() as PsdExporterProxy;

    public PsdParse SelectPsd;
    public ProjectSetting Setting;

    public string RootPath;
    public string UITexPath;
    public string CommonTexPath;
    public Transform UIRoot;
    public Dictionary<string, Font> Fonts;

    protected override void OnInit()
    {
        base.OnInit();
        Fonts = new Dictionary<string, Font>();
    }

    protected override void OnInitComplete()
    {
        Setting = ProjectSetting.GetData();
        InitSetting();
    }

    private void InitSetting()
    {
        var uIRootObj = GameObject.Find(Setting.UIRootName);
        if (uIRootObj == null)
        {
            uIRootObj = new GameObject(Setting.UIRootName);
        }
        UIRoot = uIRootObj.transform;
        Debug.Log("[PsdExporter]预设挂载点:" + UIRoot);
        RootPath = Application.dataPath.Replace("Assets", "");
        UITexPath = Application.dataPath + "/" + Setting.UITextureDir;
        Debug.Log("[PsdExporter]纹理路径:" + UITexPath);
        CommonTexPath = Application.dataPath + "/" + Setting.CommonTextureDir;
        Debug.Log("[PsdExporter]公共纹理路径:" + CommonTexPath);
        var fontPath = "Assets/" + Setting.FontDir;
        var fonts = EditorUtil.FindAssets<Font>("t:font", fontPath);
        Debug.Log("[PsdExporter]加载字体:" + fontPath + ",个数:" + fonts.Count);
        foreach (var font in fonts)
        {
            var f = font as Font;
            if (f != null)
            {
                Fonts.ForceAdd(f.name, f);
                Debug.Log("[PsdExporter]加载字体:" + f.name);
            }
        }
    }

    public Font GetFont(string name)
    {
        return Fonts.TryGetValue(name, out var font) ? font : null;
    }

    public string GetAssetPath(string fullPath)
    {
        return fullPath.Replace(RootPath, "");
    }
}



