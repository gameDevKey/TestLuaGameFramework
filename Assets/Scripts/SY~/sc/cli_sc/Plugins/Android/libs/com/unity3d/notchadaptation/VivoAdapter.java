package com.unity3d.notchadaptation;

import android.content.res.Configuration;
import android.graphics.Point;
import android.os.Build;
import android.util.Log;

import java.lang.reflect.Method;


public class VivoAdapter extends DeviceAdapter {

    private String TAG = "Vivo";

    @Override
    public boolean isSupportNotch() {
        try {
            Class<?> mClass = Class.forName("android.util.FtFeature");
            Method[] methods = mClass.getDeclaredMethods();
            Method method = null;
            for (Method m : methods) {
                if (m.getName().equalsIgnoreCase("isFeatureSupport")) {
                    method = m;
                    break;
                }
            }
            // 0x00000020表示是否有凹槽
            // 0x00000008表示是否有圆角
            return (Boolean) method.invoke(null, 0x00000020);
        } catch (ClassNotFoundException e) {
            Log.e(TAG, "getFeature ClassNotFoundException");
        } catch (Exception e) {
            Log.e(TAG, "getFeature Exception");
        }
        return false;
    }

    @Override
    public boolean isHideNotch() {
        Point pReal = DeviceUtility.getScreenSize();
        Point pShot = DeviceUtility.getScreenShotSize();
        int realSize = pReal.x > pReal.y ? pReal.x : pReal.y;
        int shotSize = pShot.x > pShot.y ? pShot.x : pShot.y;
        int statusBarHeigth = DeviceUtility.getStatusBarHeight();
        // 设备分辨率-截图分辨率=状态栏，则代表隐藏刘海
        int off = realSize - shotSize;
        if (off == statusBarHeigth || off == statusBarHeigth + 1 || off == statusBarHeigth - 1) {
            return true;
        }
        // 如果是横屏游戏
        if (DeviceUtility.getOrientation() == Configuration.ORIENTATION_LANDSCAPE) {
            // 如果设备是IQOO，设备分辨率-截图分辨率=73，则代表隐藏刘海
            String model = Build.MODEL;
            if (model.contains("V1824") && realSize - shotSize == 73) {
                return true;
            }
        }
        return false;
    }

    @Override
    public int getNotchWidth() {
        if (!isSupportNotch()) {
            return 0;
        }
        int statusBarHeight = DeviceUtility.getStatusBarHeight();
        return statusBarHeight * 100 / 32;
    }

    @Override
    public int getNotchHeigth() {
        if (!isSupportNotch()) {
            return 0;
        }
        int statusBarHeight = DeviceUtility.getStatusBarHeight();
        return statusBarHeight * 27 / 32;
    }

    @Override
    public int getBottomDangerHeigth() {
        if (!isSupportNotch())
        {
            return 0;
        }
        int statusBarHeight = DeviceUtility.getStatusBarHeight();
        return statusBarHeight * 24 / 32;
    };
}
