using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

public class UITrigger : MonoBehaviour
{
    public bool isTriggerEnter = false;
    public bool isTriggerExit = false;

    LuaFunction triggerEnterFunc;
    LuaFunction triggerExitFunc;

    public string group = string.Empty;

    public LuaTable args = null;

    LuaTable owner = null;

    void OnTriggerEnter2D(Collider2D collider)
    {
        if (isTriggerEnter && owner != null)
        {
            UITriggerTarget target = collider.GetComponent<UITriggerTarget>();
            if(target != null && group.Equals(target.group))
            {
                triggerEnterFunc.Call(args, target.args);
            }
        }
    }

    void OnTriggerExit2D(Collider2D collider)
    {
        if (isTriggerEnter && owner != null)
        {
            UITriggerTarget target = collider.GetComponent<UITriggerTarget>();
            if (target != null && group.Equals(target.group))
            {
                triggerExitFunc.Call(args, target.args);
            }
        }
    }

    public void SetOwner(LuaTable owner,string enterFunc,string exitFunc)
    {
        this.owner = owner;
        if (!enterFunc.Equals(string.Empty))
        {
            triggerEnterFunc = owner.Get<LuaFunction>(enterFunc);
        }
        if (!exitFunc.Equals(string.Empty))
        {
            triggerExitFunc = owner.Get<LuaFunction>(exitFunc);
        }
    }

    void OnDestroy()
    {
        if (triggerEnterFunc != null)
        {
            triggerEnterFunc = null;
        }
        if (triggerExitFunc != null)
        {
            triggerExitFunc = null;
        }
    }
}
