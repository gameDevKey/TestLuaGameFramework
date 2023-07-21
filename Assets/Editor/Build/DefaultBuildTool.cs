using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class DefaultBuildTool : BuildToolBase
{
    public override void Build()
    {
        BuildUtils.HandleLua();
    }

    void OnEnable()
    {
        Init(BuildConfig.DEFAULT_DATA_OBJ_NAME);
        this.name = "默认平台";
    }

    void OnGUI()
    {
        DrawDataObjectArea();
        DrawButton("确定", Build, "构建");
    }
}