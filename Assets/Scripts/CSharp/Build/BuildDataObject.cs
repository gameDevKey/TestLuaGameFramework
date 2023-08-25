using UnityEngine;
using UnityEditor;

public class BuildDataObject : ScriptableObject
{
    [Header("Lua源文件路径")]
    public string LUA_SOURCE_PATH = BuildConfig.LUA_OUTPUT_PATH;
    [Header("Lua输出路径")]
    public string LUA_OUTPUT_PATH = BuildConfig.LUA_OUTPUT_PATH;
    [Header("UI预设路径")]
    public string UI_PREFAB_PATH = BuildConfig.UI_PREFAB_PATH;
    [Header("Game预设路径")]
    public string GAME_PREFAB_PATH = BuildConfig.GAME_PREFAB_PATH;
    [Header("Config预设路径")]
    public string[] CONFIG_PREFAB_PATHS = BuildConfig.CONFIG_PREFAB_PATHS;
    [Header("构建模式")]
    public BuildConfig.EBuildMode BuildMode;
}