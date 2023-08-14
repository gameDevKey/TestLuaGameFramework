package com.unity3d.notchadaptation;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.os.Build;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.DisplayCutout;
import android.view.View;
import android.view.WindowInsets;
import android.view.WindowManager;

import java.lang.reflect.Method;

public class DeviceUtility {

    public static int getOrientation()
    {
        return AdapterManager.getActivity().getResources().getConfiguration().orientation;
    }


    public static Point getScreenSize()
    {
        Point screenSize = null;
        try
        {
            screenSize = new Point();
            WindowManager windowManager = (WindowManager) AdapterManager.getActivity().getSystemService(Context.WINDOW_SERVICE);
            Display defaultDisplay = windowManager.getDefaultDisplay();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                defaultDisplay.getRealSize(screenSize);
            }else
            {
                try {
                    Method mGetRawW = Display.class.getMethod("getRawWidth");
                    Method mGetRawH = Display.class.getMethod("getRawHeight");
                    screenSize.set((Integer) mGetRawW.invoke(defaultDisplay), (Integer) mGetRawH.invoke(defaultDisplay));
                }catch (Exception e)
                {
                    screenSize.set(defaultDisplay.getWidth(), defaultDisplay.getHeight());
                    e.printStackTrace();
                }
            }
        }catch (Exception e)
        {
            e.printStackTrace();
        }
        return screenSize;
    }

    public static Point getScreenShotSize()
    {
        View view = AdapterManager.getActivity().getWindow().getDecorView();
        view.setDrawingCacheEnabled(true);
        view.buildDrawingCache();
        Bitmap bmp = view.getDrawingCache();
        Point screenSize = new Point();
        if(bmp != null)
        {
            screenSize.set(bmp.getWidth(), bmp.getHeight());
        }
        return screenSize;
    }

    public static Point getScreenDisplaySize() {
        DisplayMetrics dm = AdapterManager.getActivity().getResources().getDisplayMetrics();
        Point screenSize = new Point();
        screenSize.set(dm.widthPixels, dm.heightPixels);
        return screenSize;
    }

    public static int getStatusBarHeight()
    {
        Resources resources = AdapterManager.getActivity().getResources();
        int id = resources.getIdentifier("status_bar_height", "dimen","android");

        if(id > 0)
        {
            return resources.getDimensionPixelSize(id);
        }

        return 0;
    }

    public static int getNavigationBarHeight()
    {
        Resources resources = AdapterManager.getActivity().getResources();

        int id = resources.getIdentifier("config_showNavigationBar", "bool", "android");
        if(id > 0)
        {
            id = resources.getIdentifier("navigation_bar_height", "dimen", "android");
            return resources.getDimensionPixelSize(id);
        }
        return 0;
    }

    @SuppressLint("NewApi")
    public static DisplayCutout getCutOut() {
        WindowInsets windowInsets = AdapterManager.getActivity().getWindow().getDecorView().getRootWindowInsets();
        return windowInsets.getDisplayCutout();
    }
}
