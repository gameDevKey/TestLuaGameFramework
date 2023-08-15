using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class ProjectSetting : ScriptableObject
{
    public static readonly string SettingPath = "Assets/Editor/ProjectSettingData.asset";

    [Header("UI设置")]
    public string UIRootName = "Canvas";
    public Vector2 CanvasSize = new Vector2(720, 1280);
    public string UITextureDir = "GameAssets/UI/Texture/";
    public string CommonTextureDir = "GameAssets/UI/CommonTexture/";

    [Header("字体设置")]
    public string FontDir = "GameAssets/Font/";
    public Font DefaultFont;

    private void OnEnable()
    {
        if (DefaultFont == null)
        {
            DefaultFont = Resources.GetBuiltinResource<Font>("Arial.ttf");
        }
    }

    public static ProjectSetting GetData()
    {
        string path = ProjectSetting.SettingPath;
        var setting = AssetDatabase.LoadAssetAtPath<ProjectSetting>(path);
        if (setting == null)
        {
            setting = ScriptableObject.CreateInstance<ProjectSetting>();
            AssetDatabase.CreateAsset(setting, path);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            Debug.Log("创建ProjectSetting:" + path);
        }
        else
        {
            Debug.Log("读取ProjectSetting:" + path);
        }
        return setting;
    }
}
