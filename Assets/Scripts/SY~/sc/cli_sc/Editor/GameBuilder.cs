using UnityEngine;
using UnityEditor;

using System;
using System.Collections.Generic;
using System.IO;

public sealed class GameBuilder {

    private static string [] scenes = {
        "Assets/Scenes/Launcher.unity",
        "Assets/Scenes/Main.unity",
        "Assets/Scenes/Normal.unity",
        "Assets/Scenes/SceneJumper.unity",
    };

    public static void Make(){
        string buildTarget = CommandLineReader.GetCustomArgument("BuildTarget");
        string filename = CommandLineReader.GetCustomArgument("Filename");
        switch(buildTarget){
            case "mac":
                BuildPipeline.BuildPlayer(scenes, filename, BuildTarget.StandaloneOSXIntel64, BuildOptions.None);
                break;

            case "ios":
                BuildPipeline.BuildPlayer(scenes, filename, BuildTarget.iOS, BuildOptions.None);
                break;

            case "apk":
                // BuildOptions buildSetting = BuildOptions.Development | BuildOptions.ConnectWithProfiler;
                BuildOptions buildSetting = BuildOptions.None;
                BuildPipeline.BuildPlayer(scenes, filename, BuildTarget.Android, buildSetting);
                break;

            case "x86":
                BuildPipeline.BuildPlayer(scenes, filename, BuildTarget.StandaloneWindows, BuildOptions.None);
                break;

            case "amd64":
                BuildPipeline.BuildPlayer(scenes, filename, BuildTarget.StandaloneWindows64, BuildOptions.None);
                break;

            default:
                Console.WriteLine(String.Format("不支持的编译目标{0}", buildTarget));
                break;
        }
    }

    public static void BuildWindowPlayer () {
        Directory.CreateDirectory ("../x86");
        BuildPipeline.BuildPlayer (scenes, "../x86/wb.exe", BuildTarget.StandaloneWindows, BuildOptions.None);
    }

    public static void BuildWindow64Player () {
        Directory.CreateDirectory ("../amd64");
        BuildPipeline.BuildPlayer (scenes, "../amd64/wb.exe", BuildTarget.StandaloneWindows64, BuildOptions.None);
    }

    public static void BuildMacOSXPlayer () {
        Directory.CreateDirectory ("../mac");
        BuildPipeline.BuildPlayer (scenes, "../mac/wb.app", BuildTarget.StandaloneOSXIntel64, BuildOptions.None);
    }

    public static void BuildIOSPlayer () {
        Directory.CreateDirectory ("../ios");
        BuildPipeline.BuildPlayer (scenes, "../ios/wb.ipa", BuildTarget.iOS, BuildOptions.None);
    }

    public static void BuildAndroidPlayer () {
        Directory.CreateDirectory ("../android");
        BuildPipeline.BuildPlayer (scenes, "../android/wb.apk", BuildTarget.Android, BuildOptions.None);
    }
}
