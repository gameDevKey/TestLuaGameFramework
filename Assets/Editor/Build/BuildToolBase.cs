using UnityEditor;
using UnityEngine;
using System.IO;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEditor.AddressableAssets.Settings;
using UnityEditor.AddressableAssets.Build;
using UnityEditor.AddressableAssets;

public abstract class BuildToolBase : EditorWindow
{
    protected BuildDataObject DataObject;
    protected string DataObjectPath;
    protected BuildVersion version;
    protected string buildPath;

    private const float labelWidth = 200;
    private int buildModeIndex = 0;
    private static string[] BuildMode2Name = new string[]{
        "全量包",
        "增量包",
    };

    protected virtual void BuildAll()
    {
        AddressableAssetSettings.CleanPlayerContent();
        AddressableAssetSettings.BuildPlayerContent();
    }

    protected virtual void BuildDelta()
    {
        var path = ContentUpdateScript.GetContentStateDataPath(true);
        if (!string.IsNullOrEmpty(path))
            ContentUpdateScript.BuildContentUpdate(AddressableAssetSettingsDefaultObject.Settings, path);
    }

    protected virtual void UpdateVersion(bool majorVersionUpdate)
    {
        if (version == null) return;
        if (majorVersionUpdate)
            version.UpdateMain();
        else
            version.UpdateSub();
        PlayerSettings.bundleVersion = version.Get();
    }

    protected void Init(string objName)
    {
        DirectoryInfo target = new DirectoryInfo(BuildConfig.BUILD_OBJ_DIR_PATH);
        if (!target.Exists) target.Create();
        DataObjectPath = BuildConfig.BUILD_OBJ_DIR_PATH + objName + ".asset";
        DataObject = GetDataObject();
        AfterGetDataObject();
    }

    void AfterGetDataObject()
    {
        if (DataObject != null && version == null)
            ParseVersionData();
    }

    void ParseVersionData()
    {
        version = new BuildVersion(PlayerSettings.bundleVersion, DataObject.BuildMode, 9);
    }

    BuildDataObject GetDataObject()
    {
        return AssetDatabase.LoadAssetAtPath<BuildDataObject>(DataObjectPath);
    }

    BuildDataObject CreateDataObject()
    {
        BuildDataObject instance = CreateInstance<BuildDataObject>();
        AssetDatabase.CreateAsset(instance, DataObjectPath);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        return instance;
    }

    protected void DrawDataObjectArea()
    {
        if (DataObject == null)
        {
            DrawButton("创建", () =>
            {
                DataObject = CreateDataObject();
                AfterGetDataObject();
            },
            "请创建数据集");
        }
        else
        {
            EditorGUILayout.BeginHorizontal();
            DrawLabel("数据集");
            EditorGUILayout.ObjectField(DataObject, typeof(BuildDataObject), false);
            DrawButton("刷新",()=>{
                ParseVersionData();
            });
            EditorGUILayout.EndHorizontal();
        }
    }

    protected void DrawButton(string btn, System.Action callback, string title = null)
    {
        EditorGUILayout.BeginHorizontal();
        if (!string.IsNullOrEmpty(title))
            DrawLabel(title);
        if (GUILayout.Button(btn))
        {
            callback();
        }
        EditorGUILayout.EndHorizontal();
    }

    protected string DrawTextField(string title, string input, string defaultInput = null, bool canEdit = true)
    {
        EditorGUILayout.BeginHorizontal();
        if (!string.IsNullOrEmpty(title))
            DrawLabel(title);
        if (!string.IsNullOrEmpty(defaultInput) && string.IsNullOrEmpty(input))
            input = defaultInput;
        if (canEdit)
            input = EditorGUILayout.TextField(input);
        else
            EditorGUILayout.LabelField(input);
        EditorGUILayout.EndHorizontal();
        return input;
    }

    protected void DrawLabel(string label)
    {
        GUILayout.Label(label, EditorStyles.boldLabel, GUILayout.Width(labelWidth));
    }

    protected void DrawBuildSelectList(string title = null)
    {
        EditorGUILayout.BeginHorizontal();
        if (!string.IsNullOrEmpty(title))
            DrawLabel(title);
        buildModeIndex = EditorGUILayout.Popup(buildModeIndex, BuildMode2Name);
        EditorGUILayout.EndHorizontal();
    }

    protected void DrawBuildExecButton(string btn, string title = null)
    {
        DrawButton(btn, () =>
        {
            if (EditorUtility.DisplayDialog("请确认以下构建内容", GetBuildDetail(), "构建", "取消"))
            {
                if (buildModeIndex == 0)
                {
                    BuildAll();
                }
                else
                {
                    BuildDelta();
                }
            }
        }, title);
    }

    string GetBuildDetail()
    {
        return
@$"包体: {BuildMode2Name[buildModeIndex]}
平台: {UnityEditor.EditorUserBuildSettings.activeBuildTarget}";
    }

    protected void DrawVerticalSpace()
    {
        EditorGUILayout.Space();
        EditorGUILayout.Space();
        EditorGUILayout.Space();
    }

    protected void DrawVersion()
    {
        if (version == null) return;
        DrawTextField("Version", version.Get(), null, false);
    }

    protected void DrawBuildPathClear()
    {
        buildPath = DrawTextField("输出路径", buildPath, "ServerData/" + UnityEditor.EditorUserBuildSettings.activeBuildTarget, false);
        DrawButton("清空", () =>
        {
            FileUtil.DeleteFileOrDirectory(buildPath);
            AssetDatabase.Refresh();
            Debug.Log("已清空:" + buildPath);
        });
    }
}