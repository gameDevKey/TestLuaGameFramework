using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class AndroidBuildTool : BuildToolBase
{
    private int bundleVersionCode;

    protected override void BuildAll()
    {
        BuildUtils.HandleLua();
        UpdateBundleVersionCode();
        base.UpdateVersion(true);
        base.BuildAll();
    }

    protected override void BuildDelta()
    {
        BuildUtils.HandleLua();
        UpdateBundleVersionCode();
        base.UpdateVersion(false);
        base.BuildDelta();
    }

    void OnEnable()
    {
        base.Init(BuildConfig.ANDROID_DATA_OBJ_NAME);
        this.titleContent = new GUIContent("安卓平台");
        bundleVersionCode = PlayerSettings.Android.bundleVersionCode;
    }

    void OnGUI()
    {
        DrawVersion();
        DrawVerticalSpace();
        DrawBundleVersionCode();
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

    void DrawBundleVersionCode()
    {
        DrawTextField("Bundle Version Code", bundleVersionCode.ToString(), null, false);
    }

    void UpdateBundleVersionCode(int value = 1)
    {
        bundleVersionCode += value;
        PlayerSettings.Android.bundleVersionCode = bundleVersionCode;
    }
}