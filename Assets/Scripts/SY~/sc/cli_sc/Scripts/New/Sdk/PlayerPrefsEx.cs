using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerPrefsEx
{
    public static void SetInt(string key, int value)
    {
        PlayerPrefs.SetInt(key, value);
    }

    public static int GetInt(string key, int defaultValue = 0)
    {
        return PlayerPrefs.GetInt(key, defaultValue);
    }

    public static void SetString(string key, string value)
    {
        PlayerPrefs.SetString(key, value);
    }

    public static string GetString(string key, string defaultValue = "")
    {
        return PlayerPrefs.GetString(key, defaultValue);
    }


    public static void SetFloat(string key, float value)
    {
        PlayerPrefs.SetFloat(key, value);
    }

    public static float GetFloat(string key, float defaultValue = 0)
    {
        return PlayerPrefs.GetFloat(key, defaultValue);
    }

    public static void DeleteAll()
    {
        PlayerPrefs.DeleteAll();
    }

    public static void DeleteKey(string key)
    {
        PlayerPrefs.DeleteKey(key);
    }

    public static void HasKey(string key)
    {
        PlayerPrefs.HasKey(key);
    }

    public static void Save()
    {
        PlayerPrefs.Save();
    }
}
