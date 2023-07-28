using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditor.AddressableAssets.Settings;
using UnityEditor.AddressableAssets.Build;
using UnityEditor.AddressableAssets;

public class DefaultBuildTool : BuildToolBase
{
    protected override void BuildAll()
    {
        BuildUtils.HandleLua();
        base.UpdateVersion(true);
        base.BuildAll();
    }

    protected override void BuildDelta()
    {
        BuildUtils.HandleLua();
        base.UpdateVersion(false);
        base.BuildDelta();
    }

    void OnEnable()
    {
        base.Init(BuildConfig.DEFAULT_DATA_OBJ_NAME);
        this.titleContent = new GUIContent("默认平台");
    }

    void OnGUI()
    {
        DrawVersion();
        DrawVerticalSpace();
        DrawDataObjectArea();
        DrawVerticalSpace();
        DrawBuildSelectList("包体类型");
        DrawVerticalSpace();
        DrawBuildPathClear();
        DrawVerticalSpace();
        DrawButton("Lua导出",()=>BuildUtils.HandleLua());
        DrawVerticalSpace();
        DrawButton("重建AA分组",()=>{
            AddressableGroupSetter.InitGroups();
            Debug.Log("重建AA分组结束");
        });
        DrawVerticalSpace();
        DrawBuildExecButton("执行");
    }
}