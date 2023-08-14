package com.unity3d.notchadaptation;

import android.app.Activity;
import android.os.Build;
import android.view.ViewTreeObserver;

import com.unity3d.player.UnityPlayer;

public class AdapterManager
{
    private static IEventListener listener;

    public static void initDisplayCutoutMode()
    {
        ViewTreeObserver vto = getActivity().getWindow().getDecorView().getViewTreeObserver();
        vto.addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {

            @Override
            public void onGlobalLayout() { UpdateDisplayCutOut(); }
        });
    }

    private static void UpdateDisplayCutOut()
    {
        listener.OnLayoutChange();
    }

    public  static void SetEventListener(IEventListener ulistener){ listener = ulistener;}
    public static Activity getActivity() { return UnityPlayer.currentActivity; }
    public static boolean isAndroidP() { return  Build.VERSION.SDK_INT >= Build.VERSION_CODES.P; }
    public static DeviceAdapter getAdapter() { return DeviceAdapter.Create(); }
}
