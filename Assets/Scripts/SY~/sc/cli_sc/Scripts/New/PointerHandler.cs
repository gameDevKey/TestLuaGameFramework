using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using XLua;

public class PointerHandler : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IPointerClickHandler
{
    public bool isPointerDown = false;
    public bool isPointerUp = false;
    public bool isPointerClick = false;

    LuaFunction pointerDownFunc;
    LuaFunction pointerUpFunc;
    LuaFunction pointerClickFunc;

    public LuaTable args = null;

    LuaTable owner = null;

    public void OnPointerDown(PointerEventData eventData)
    {
        if(eventData.button != PointerEventData.InputButton.Left)
        {
            return;
        }

        if(isPointerDown && owner != null)
        {
            pointerDownFunc.Call(eventData, args);
        }
    }

    public void OnPointerUp(PointerEventData eventData)
    {
        if (eventData.button != PointerEventData.InputButton.Left)
        {
            return;
        }

        if (isPointerUp && owner != null)
        {
            pointerUpFunc.Call(eventData, args);
        }
    }

    public void OnPointerClick(PointerEventData eventData)
    {
        if (eventData.button != PointerEventData.InputButton.Left)
        {
            return;
        }

        if (isPointerClick && owner != null)
        {
            pointerClickFunc.Call(eventData, args);
        }
    }

    public void SetOwner(LuaTable owner,string downFunc,string upFunc, string clickFunc)
    {
        this.owner = owner;
        if(!downFunc.Equals(string.Empty))
        {
            pointerDownFunc = owner.Get<LuaFunction>(downFunc);
        }
        if (!upFunc.Equals(string.Empty))
        {
            pointerUpFunc = owner.Get<LuaFunction>(upFunc);
        }
        if (!clickFunc.Equals(string.Empty))
        {
            pointerClickFunc = owner.Get<LuaFunction>(clickFunc);
        }
    }

    void OnDestroy()
    {
        if(pointerDownFunc != null)
        {
            pointerDownFunc = null;
        }
        if (pointerUpFunc != null)
        {
            pointerUpFunc = null;
        }
        if (pointerClickFunc != null)
        {
            pointerClickFunc = null;
        }
    }
}
