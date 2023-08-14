using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SLua;

[CustomLuaClass]
public class MultiLangCtrl {

 	public delegate void OnLanguageChanged();
    public static OnLanguageChanged onLanguageChanged = null;

    public static MultiLangCtrl _Instance;

    public static MultiLangCtrl Instance
    {
        get
        {
            if (_Instance == null)
            {
                _Instance = new MultiLangCtrl();
            }
            return _Instance;
        }
    }
    public void SetupLanguage() {
        if (onLanguageChanged != null) {
            onLanguageChanged();
        }
    }
}

