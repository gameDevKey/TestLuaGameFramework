package com.unity3d.notchadaptation;

import android.content.pm.PackageManager;
import android.graphics.Point;

public class OppoAdapter extends DeviceAdapter {

    @Override
    public boolean isSupportNotch() {
        PackageManager pm = AdapterManager.getActivity().getPackageManager();
        return pm.hasSystemFeature("com.oppo.feature.screen.heteromorphism");
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
        if (off == statusBarHeigth || off == statusBarHeigth + 1 || off == statusBarHeigth - 1)
        {
            return true;
        }
        return false;
    }

    @Override
    public int getNotchWidth() {
        if (!isSupportNotch()) {
            return 0;
        }
        return 324;
    }

    @Override
    public int getNotchHeigth() {
        if (!isSupportNotch()) {
            return 0;
        }
        return 80;
    }
}
