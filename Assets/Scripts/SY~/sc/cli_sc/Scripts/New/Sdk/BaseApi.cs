using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseApi
{
    public static bool IsIpv6()
    {
#if UNITY_IOS
        return IosBaseApi.IsIpv6();
#else
        return false;
#endif
    }

    private static AndroidJavaObject GetAndroidDeviceInstance()
    {
        AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
        AndroidJavaObject androidJavaObject = androidJavaClass.GetStatic<AndroidJavaObject>("currentActivity");

        AndroidJavaClass adapter = new AndroidJavaClass("com.unity3d.BaseApi.DeviceInfo");
        AndroidJavaObject instance = adapter.CallStatic<AndroidJavaObject>("Instance");
        instance.Call("Init", androidJavaObject);
        return instance;
    }

    public static int GetTotalMemory()
    {
#if UNITY_ANDROID
        AndroidJavaObject jo = GetAndroidDeviceInstance();
        return (int)(jo.Call<long>("getTotalMemory") / 1024);
#else
        return 0;
#endif
    }

    public static int GetCPUMaxFreqKHz()
    {
#if UNITY_ANDROID
        AndroidJavaObject jo = GetAndroidDeviceInstance();
        return jo.CallStatic<int>("getCPUMaxFreqKHz");
#else
        return 0;
#endif
    }

    public static string GetHardWare()
    {
#if UNITY_ANDROID
        AndroidJavaObject jo = GetAndroidDeviceInstance();
        return jo.CallStatic<string>("getHardWare");
#else
        return "";
#endif
    }

    public static string GetSystemModel()
    {
#if UNITY_ANDROID
        AndroidJavaObject jo = GetAndroidDeviceInstance();
        return jo.CallStatic<string>("getSystemModel");
#else
        return "";
#endif
    }

    public static string GetDeviceBrand()
    {
#if UNITY_ANDROID
        AndroidJavaObject jo = GetAndroidDeviceInstance();
        return jo.CallStatic<string>("getDeviceBrand");
#else
        return "";
#endif
    }

    public static string GetSystemVersion()
    {
#if UNITY_ANDROID
        AndroidJavaObject jo = GetAndroidDeviceInstance();
        return jo.CallStatic<string>("getSystemVersion");
#else
        return "";
#endif
    }


    public static bool IsEmulator()
    {
#if UNITY_ANDROID
        AndroidJavaObject jo = GetAndroidDeviceInstance();
        return jo.Call<bool>("isEmulator");
#else
        return false;
#endif
    }
}
