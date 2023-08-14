package com.unity3d.notchadaptation;

import android.provider.Settings;
import android.util.Log;

import java.lang.reflect.Field;

public class MeizuAdapter extends DeviceAdapter
{
    private String TAG = "Meizu";

    @Override
    public boolean isSupportNotch() {
        boolean fringeDevice = false;
        try {
            Class<?> clazz = Class.forName("flyme.config.FlymeFeature");
            Field field = clazz.getDeclaredField("IS_FRINGE_DEVICE");
            fringeDevice = (Boolean) field.get(null);
        } catch (Exception e) {
            Log.e(TAG, "isSupportNotch:\n" + e.toString());
        }
        return fringeDevice;
    }

    @Override
    public boolean isHideNotch() {
        // 判断隐藏刘海开关(默认关)
        return Settings.Global.getInt(AdapterManager.getActivity().getContentResolver(), "mz_fringe_hide", 0) == 1;
    }

    @Override
    public int getNotchHeigth() {
        if (!isSupportNotch()) {
            return 0;
        }

        // 获取刘海高度（51px）
        int fringeHeight = 0;
        int fhid = AdapterManager.getActivity().getResources().getIdentifier("fringe_height", "dimen", "android");
        if (fhid > 0) {
            fringeHeight = AdapterManager.getActivity().getResources().getDimensionPixelSize(fhid);
        }
        return fringeHeight;
    }
}
