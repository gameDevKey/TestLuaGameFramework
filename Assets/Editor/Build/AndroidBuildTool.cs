using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class AndroidBuildTool : BuildToolBase
{
    protected override void BuildAll()
    {
        BuildUtils.HandleLua();
    }

    protected override void BuildDelta()
    {

    }

    void OnEnable()
    {
        Init(BuildConfig.ANDROID_DATA_OBJ_NAME);
        this.titleContent = new GUIContent("安卓平台");
    }

    void OnGUI()
    {
        DrawDataObjectArea();
        DrawButton("确定", BuildAll, "构建全量包");
    }
}