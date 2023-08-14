using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

using UnityEngine;
using UnityEditor;

using EditorTools.AssetBundle;

public static class SubpackageTool {

    public static string output = "../release";
    public static string platform = "pc";

    [MenuItem ("Warbird/小包分离资源")]
    public static void SplitFile () {
        platform = AssetPathHelper.GetBuildTarget(EditorUserBuildSettings.activeBuildTarget);
        SubpackageBuilder builder = new SubpackageBuilder (output, platform);
        builder.Split ();
    }

    // 命令行
    public static void SplitFileCmd () {
        platform = CommandLineReader.GetCustomArgument("BuildTarget");
        SubpackageBuilder builder = new SubpackageBuilder (output, platform);
        builder.Split ();
    }
}
