package com.unity3d.notchadaptation;

import android.annotation.SuppressLint;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.text.TextUtils;
import android.util.Log;
import android.view.DisplayCutout;

public class SamsungAdapter extends DeviceAdapter
{
    private String TAG = "Samsung";

    @Override
    public boolean isSupportNotch() {
        try {
            final Resources res = AdapterManager.getActivity().getResources();
            final int resId = res.getIdentifier("config_mainBuiltInDisplayCutout", "string", "android");
            final String spec = resId > 0 ? res.getString(resId) : null;
            return spec != null && !TextUtils.isEmpty(spec);
        } catch (Exception e) {
            Log.e(TAG, "getFeature Exception");
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
            return left > 0 || right > 0 ? false : true;
        }
        return false;
    }

    @SuppressLint("NewApi")
    @Override
    public int getNotchHeigth() {
        if (!isSupportNotch()) {
            return 0;
        }

        int orientation = DeviceUtility.getOrientation();
        DisplayCutout cutout = DeviceUtility.getCutOut();
        if(cutout != null) {

            if (orientation == Configuration.ORIENTATION_PORTRAIT) {
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
