using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using SLua;

[CustomLuaClass]
public class MultiLangHandler : MonoBehaviour {

 	[SerializeField, Header("Langkey")]
    public string LangKey = "";
	public LuaTable LangArgs;
    public Func<string,LuaTable,string> langClickCb = null;

	void Awake() {
		MultiLangCtrl.onLanguageChanged += onLanguageChanged;
	}

	void OnDestroy() {
		MultiLangCtrl.onLanguageChanged -= onLanguageChanged;
	}

	void onLanguageChanged() {
		if (this.gameObject == null)
		{
			return;
		}
        Text text = this.gameObject.GetComponent<Text>();
        if (text != null) {
            var value = this.GetLangValue();
			if (value != null && value != "")
			{
				text.text = value;	
			}
            return;
        }
    }

	private string GetLangValue() {
		if (langClickCb != null) {
			return langClickCb(this.LangKey,this.LangArgs);
		}
		return "";
	}
}