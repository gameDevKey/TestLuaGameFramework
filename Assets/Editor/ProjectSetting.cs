using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class ProjectSetting : ScriptableObject
{
    public static readonly string SettingPath = "Assets/Editor/ProjectSettingData.asset";

    [Header("UI����")]
    public string UIRootName = "Canvas";
    public Vector2 CanvasSize = new Vector2(720, 1280);
    public string UITextureDir = "GameAssets/UI/Texture/";
    public string CommonTextureDir = "GameAssets/UI/CommonTexture/";

    [Header("��������")]
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
            Debug.Log("����ProjectSetting:" + path);
        }
        else
        {
            Debug.Log("��ȡProjectSetting:" + path);
        }
        return setting;
    }
}
