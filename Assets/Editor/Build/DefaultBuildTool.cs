using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class DefaultBuildTool : BuildToolBase
{
    public override void Build()
    {
        Debug.Log("默认平台打包");
        BuildUtils.HandleLua();
    }
}