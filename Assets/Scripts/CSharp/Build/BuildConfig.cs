using UnityEditor;
using UnityEngine;
using System;

public static class BuildConfig
{
    public const string LUA_SOURCE_PATH = "Assets/Scripts/Lua";
    public const string LUA_OUTPUT_PATH = "Assets/BuildAssets/Scripts/Lua";
    public const string UI_PREFAB_PATH = "Assets/GameAssets/Prefab/UI";
    public const string GAME_PREFAB_PATH = "Assets/GameAssets/Prefab/Game";
    public const string BUILD_OBJ_DIR_PATH = "Assets/BuildAssets/BuildDataObject/";
    public const string BUILD_MODE_SAVE_KEY = "BuildConfig.EBuildMode";
    public const string DEFAULT_DATA_OBJ_NAME = "DefaultBuildData";
    public const string ANDROID_DATA_OBJ_NAME = "AndroidBuildData";

    public enum EBuildMode
    {
        Unknown,
        Dev,
        Build
    }
}
