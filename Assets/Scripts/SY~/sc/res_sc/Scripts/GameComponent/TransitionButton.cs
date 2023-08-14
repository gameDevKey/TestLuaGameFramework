using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using XLua;

/// <summary>
/// 按钮效果
/// </summary>
public class TransitionButton : MonoBehaviour, IPointerDownHandler, IPointerUpHandler 
{
    private Vector3 originScale = new Vector3(1, 1, 1);
    private bool isStart = false;

    // 是否缩放
    public bool scaleSetting = true;
    // 缩放比率
    public float scaleRate = 1.1f;

    // 是否有音效
    public bool soundSetting = true;
    // 音效ID
    public int soundId = 0;

    static LuaFunction soundFunc;

    public static void SetSoundFunc(LuaTable owner, string soundFunc)
    {
        TransitionButton.soundFunc = owner.Get<LuaFunction>(soundFunc);
    }

    void OnEnable () 
    {
        if (isStart) 
        {
            transform.localScale = originScale;
        }
    }

    void Start () 
    {
        if (scaleSetting) 
        {
			originScale = transform.localScale;
            isStart = true;
		}
    }

    public void OnPointerDown (PointerEventData eventData) 
    {
        if (scaleSetting)
        {
            transform.localScale = new Vector3(originScale.x * scaleRate, originScale.y * scaleRate, originScale.z);
        }

        if (soundSetting && soundFunc != null)
        {
            soundFunc.Call(soundId);
        }
    }

    public void OnPointerUp (PointerEventData eventData) 
    {
        if (scaleSetting)
        {
            transform.localScale = originScale;
        }
    }
}
