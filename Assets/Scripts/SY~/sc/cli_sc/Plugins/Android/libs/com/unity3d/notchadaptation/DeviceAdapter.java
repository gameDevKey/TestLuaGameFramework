package com.unity3d.notchadaptation;

import android.os.Build;

public abstract class DeviceAdapter
{
    public static com.unity3d.notchadaptation.DeviceAdapter Create()
    {
        com.unity3d.notchadaptation.DeviceAdapter adapter = null;
        if(AdapterManager.isAndroidP()) {
            adapter = new AndroidPAdapter();
        }else {
            String company = Build.MANUFACTURER.toUpperCase();
            if (company.equalsIgnoreCase("HUAWEI")) {
            	adapter = new HuaweiAdapter();
            } else if (company.equalsIgnoreCase("XIAOMI")) {
            	adapter = new XiaomiAdapter();
            }else if (company.equalsIgnoreCase("VIVO")) {
            	adapter = new VivoAdapter();
            }else if (company.equalsIgnoreCase("OPPO")) {
            	adapter = new OppoAdapter();
            }else if (company.equalsIgnoreCase("ONEPLUS")) {
            	adapter = new OnePlusAdapter();
            }else if (company.equalsIgnoreCase("LENOVO")) {
            	adapter = new LenovoAdapter();
            }else if (company.equalsIgnoreCase("MEIZU")) {
            	adapter = new MeizuAdapter();
            }else if (company.equalsIgnoreCase("NUBIA")) {
            	adapter = new NubiaAdapter();
            }else if (company.equalsIgnoreCase("SAMSUNG")) {
            	adapter = new SamsungAdapter();
            }
        }
        return adapter;
    }

    public int getNotchWidth()
    {
        return 0;
    }

    public int getNotchHeigth()
    {
        return 0;
    }

    public int getBottomDangerHeigth() {
        return 0;
    }

    public boolean isHideNotch()
    {
        return false;
    }

    public boolean isSupportNotch() {
        return false;
    }
}