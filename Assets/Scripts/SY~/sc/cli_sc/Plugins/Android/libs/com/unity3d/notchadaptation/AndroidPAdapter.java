package com.unity3d.notchadaptation;

import android.annotation.SuppressLint;
import android.content.res.Configuration;
import android.view.DisplayCutout;

public class AndroidPAdapter extends DeviceAdapter {

    @SuppressLint("NewApi")
    @Override
    public boolean isSupportNotch() {
        try
        {
            DisplayCutout cutout = DeviceUtility.getCutOut();
            if(cutout != null)
            {
                return cutout.getBoundingRects().size() > 0;
            }
        }catch (Exception e)
        {
            e.printStackTrace();
        }
        return false;
    }

    @SuppressLint("NewApi")
    @Override
    public boolean isHideNotch() {
        int orientation = DeviceUtility.getOrientation();
        DisplayCutout cutout = DeviceUtility.getCutOut();
        if(cutout != null) {
            if (orientation == Configuration.ORIENTATION_PORTRAIT) {
                int top = cutout.getSafeInsetTop();
                int bottom = cutout.getSafeInsetBottom();
                return top > 0 || bottom > 0 ? false : true;
            }

            int left = cutout.getSafeInsetLeft();
            int right = cutout.getSafeInsetRight();
            System.out.println(left);
            System.out.println(right);
            return left > 0 || right > 0 ? false : true;
        }
        return false;
    }

    @SuppressLint("NewApi")
    public int getNotchHeigth() {

        DisplayCutout cutout = DeviceUtility.getCutOut();
        if(cutout != null)
        {
            int orientation = DeviceUtility.getOrientation();
            if(orientation == Configuration.ORIENTATION_PORTRAIT)
            {
                int top = cutout.getSafeInsetTop();
                int bottom = cutout.getSafeInsetBottom();
                return top > bottom ? top : bottom;
            }

            int left = cutout.getSafeInsetLeft();
            int right = cutout.getSafeInsetRight();
            return left > right ? left : right;
        }
        return 0;
    }
}
