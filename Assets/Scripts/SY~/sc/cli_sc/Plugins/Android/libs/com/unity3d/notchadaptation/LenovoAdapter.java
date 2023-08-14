package com.unity3d.notchadaptation;

import android.graphics.Point;

public class LenovoAdapter extends DeviceAdapter {

    @Override
    public boolean isSupportNotch() {
        boolean result = false;
        int resourceId = AdapterManager.getActivity().getResources().getIdentifier("config_screen_has_notch", "bool", "android");
        if (resourceId > 0) {
            result = AdapterManager.getActivity().getResources().getBoolean(resourceId);
        }
        return result;
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
        return false;
    }

    @Override
    public int getNotchHeigth() {
        if (!isSupportNotch() || isHideNotch()) {
            return 0;
        }

        int result = 0;
        int resourceId = AdapterManager.getActivity().getResources().getIdentifier("notch_h", "integer", "android");
        if (resourceId > 0) {
            result = AdapterManager.getActivity().getResources().getInteger(resourceId);
        }
        return result;
    }

    @Override
    public int getNotchWidth() {
        if (!isSupportNotch() || isHideNotch()) {
            return 0;
        }

        int result = 0;
        int resourceId = AdapterManager.getActivity().getResources().getIdentifier("notch_w", "integer", "android");
        if (resourceId > 0) {
            result = AdapterManager.getActivity().getResources().getInteger(resourceId);
        }
        return result;
    }
}
