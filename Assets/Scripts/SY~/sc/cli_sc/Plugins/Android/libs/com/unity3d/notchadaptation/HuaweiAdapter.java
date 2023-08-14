package com.unity3d.notchadaptation;

import android.graphics.Point;
import android.provider.Settings;
import android.util.Log;

import java.lang.reflect.Method;

public class HuaweiAdapter extends DeviceAdapter {

    private String TAG = "Huawei";

    @Override
    public boolean isSupportNotch()
    {
        try {
            ClassLoader cl = AdapterManager.getActivity().getClassLoader();
            Class<?> HwNotchSizeUtil = cl.loadClass("com.huawei.android.util.HwNotchSizeUtil");
            Method get = HwNotchSizeUtil.getMethod("hasNotchInScreen");
            return (Boolean) get.invoke(HwNotchSizeUtil);
        } catch (ClassNotFoundException e) {
            Log.e(TAG, "isFeatureSupport ClassNotFoundException");
        } catch (NoSuchMethodException e) {
            Log.e(TAG, "isFeatureSupport NoSuchMethodException");
        } catch (Exception e) {
            Log.e(TAG, "isFeatureSupport Exception");
        }
        return false;
    }

    @Override
    public boolean isHideNotch()
    {
        boolean isHide = Settings.Secure.getInt(AdapterManager.getActivity().getContentResolver(), "display_notch_status", 0) == 1;
        if (!isHide) {
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
            return false;
        }
        return true;
    }

    @Override
    public int getNotchWidth() {

        if(!isSupportNotch())
            return 0;

        return getNotchSize()[0];
    }

    @Override
    public int getNotchHeigth() {
        if (!isSupportNotch()) {
            return 0;
        }

        return getNotchSize()[1];
    }

    @Override
    public int getBottomDangerHeigth() {
        if (!isSupportNotch() || isHideNotch()) {
            return 0;
        }
        int statusBarHeight = DeviceUtility.getStatusBarHeight();
        return statusBarHeight * 24 / 32;
    }

    private int[] getNotchSize() {

        int[] ret = new int[] { 0, 0 };
        try {
            ClassLoader cl = AdapterManager.getActivity().getClassLoader();
            Class<?> HwNotchSizeUtil = cl.loadClass("com.huawei.android.util.HwNotchSizeUtil");
            Method get = HwNotchSizeUtil.getMethod("getNotchSize");
            ret = (int[]) get.invoke(HwNotchSizeUtil);
        } catch (ClassNotFoundException e) {
            Log.e(TAG, "getNotcSize ClassNotFoundException");
        } catch (NoSuchMethodException e) {
            Log.e(TAG, "getNotcSize NoSuchMethodException");
        } catch (Exception e) {
            Log.e(TAG, "getNotcSize Exception");
        }
        return ret;
    }
}
