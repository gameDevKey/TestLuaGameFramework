using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ToolsApi
{
    public static void InitBugly(string appId)
    {
#if UNITY_ANDROID
        AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
        AndroidJavaObject androidJavaObject = androidJavaClass.GetStatic<AndroidJavaObject>("currentActivity");

        AndroidJavaClass adapter = new AndroidJavaClass("com.unity3d.tools.BuglyTools");

        adapter.CallStatic("InitBugly",androidJavaObject,appId);
#endif
    }
}
