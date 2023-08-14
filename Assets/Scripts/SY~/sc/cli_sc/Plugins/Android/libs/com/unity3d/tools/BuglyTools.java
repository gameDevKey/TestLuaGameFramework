package com.unity3d.tools;

import com.tencent.bugly.crashreport.CrashReport;
import com.unity3d.player.UnityPlayer;
import android.content.Context;

public class BuglyTools
{
    // private Context context;

    public static void InitBugly(Context context,String appId)
    {
        // CrashReport.initCrashReport(getApplicationContext(), appId, false);
        CrashReport.initCrashReport(context, appId, false);
    }
}
