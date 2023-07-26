using UnityEditor;
using UnityEngine;
using System.IO;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.AddressableAssets.Settings;
using UnityEditor.AddressableAssets.Build;
using UnityEditor.AddressableAssets;

public abstract class BuildToolBase : EditorWindow
{

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

    private const float labelWidth = 200;
    private int buildModeIndex = 0;
    private static string[] BuildMode2Name = new string[]{
        "全量包",
        "增量包",
    };


    protected BuildDataObject DataObject;
    protected string DataObjectPath;

    protected void Init(string objName)
    {
        DirectoryInfo target = new DirectoryInfo(BuildConfig.BUILD_OBJ_DIR_PATH);
        if (!target.Exists) target.Create();
        DataObjectPath = BuildConfig.BUILD_OBJ_DIR_PATH + objName + ".asset";
        DataObject = GetDataObject();
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
            },
            "请创建数据集");
        }
        else
        {
            EditorGUILayout.BeginHorizontal();
            DrawLabel("数据集");
            EditorGUILayout.ObjectField(DataObject, typeof(BuildDataObject), false);
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
}