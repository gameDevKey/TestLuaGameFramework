using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UnityEditor;

public class BuildEditor
{
    [MenuItem("打包工具/打包")]
    public static void Build()
    {
        BuildToolBase tool = null;
#if UNITY_ANDROID
        tool = new AndroidBuildTool();
#elif UNITY_IOS

#else
        tool = new DefaultBuildTool();
#endif
        tool?.Build();
    }
}