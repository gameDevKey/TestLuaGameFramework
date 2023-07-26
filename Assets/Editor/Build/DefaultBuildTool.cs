using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditor.AddressableAssets.Settings;
using UnityEditor.AddressableAssets.Build;
using UnityEditor.AddressableAssets;

public class DefaultBuildTool : BuildToolBase
{
    private string buildPath;

    protected override void BuildAll()
    {
        BuildUtils.HandleLua();
        base.BuildAll();
    }

    protected override void BuildDelta()
    {
        BuildUtils.HandleLua();
        base.BuildDelta();
    }

    void OnEnable()
    {
        Init(BuildConfig.DEFAULT_DATA_OBJ_NAME);
        this.titleContent = new GUIContent("默认平台");
    }

    void OnGUI()
    {
        DrawDataObjectArea();
        DrawVerticalSpace();
        DrawBuildSelectList("包体类型");
        DrawVerticalSpace();
        buildPath = DrawTextField("输出路径",buildPath,"ServerData/"+UnityEditor.EditorUserBuildSettings.activeBuildTarget,false);
        DrawButton("清空",()=>{
            FileUtil.DeleteFileOrDirectory(buildPath);
            AssetDatabase.Refresh();
            Debug.Log("已清空:"+buildPath);
        });
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