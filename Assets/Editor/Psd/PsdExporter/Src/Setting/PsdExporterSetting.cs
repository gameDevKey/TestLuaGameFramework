using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MiniJSON;
// using TMPro;
using UnityEditor;

public class PsdExporterSetting
{
    public int width;
    public int height;
    public string outPath;
    public Transform uiRoot;
    public List<string> commonTexPaths = new List<string>();
    public Dictionary<string, Font> fonts = new Dictionary<string, Font>();


    public static string projectPath = IOUtils.GetAbsPath(Application.dataPath + "/../");

    public void ParseSetting(string file)
    {
        string content = IOUtils.ReadAllText(file);

        Debug.Log("��ȡPsd��������:" + content);

        Dictionary<string, object> setting = Json.Deserialize(content) as Dictionary<string, object>;

        width = (int)setting["width"];
        height = (int)setting["height"];

        string uiRootName = (string)setting["ui_root"];
        var root = GameObject.Find(uiRootName);

        if (root == null)
        {
            Debug.LogError("���ڳ����д���һ����Ϊ[" + uiRootName + "]�Ľڵ�(��ô���Canvas����)");
            return;
        }

        uiRoot = root.transform;

        outPath = (string)setting["output_path"];
        outPath = IOUtils.GetAbsPath(Application.dataPath + "/" + outPath);

        List<object> texPaths = setting["common_tex_path"] as List<object>;
        foreach (var path in texPaths)
        {
            commonTexPaths.Add(IOUtils.GetAbsPath(Application.dataPath + "/" + path));
        }

        List<object> fontPaths = setting["font_path"] as List<object>;
        foreach (var v in fontPaths)
        {
            Font font = AssetDatabase.LoadAssetAtPath<Font>("Assets/" + v.ToString());
            fonts.Add(font.fontNames[1], font);
        }
    }

    public Font GetFont(string fontName)
    {
        if (fonts.ContainsKey(fontName))
        {
            return fonts[fontName];
        }
        return null;
    }
}

