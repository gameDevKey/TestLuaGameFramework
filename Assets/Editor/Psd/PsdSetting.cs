using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PsdSetting : ScriptableObject
{
    public static string SettingPath = "Assets/Editor/Psd/PsdSettingData.asset";
    public string UIRootName = "Canvas";
    public Vector2 CanvasSize = new Vector2(1080, 1920);
    public string OutputPath = "GameAssets/UI/Texture";
}
