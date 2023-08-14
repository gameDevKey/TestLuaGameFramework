using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using XLua;

[LuaCallCSharp]
public class ButtonDownEvent : UnityEvent { }

[LuaCallCSharp]
public class ButtonUpEvent : UnityEvent { }

[LuaCallCSharp]
public class ButtonHoldEvent : UnityEvent { }

[LuaCallCSharp]
public class CustomButton : Button, IPointerDownHandler, IPointerUpHandler
{




    private ButtonDownEvent m_OnDown = new ButtonDownEvent();
    private ButtonUpEvent m_OnUp = new ButtonUpEvent();
    private ButtonHoldEvent m_Hold = new ButtonHoldEvent();


    private bool isdown = false;
//    private bool m_holdtrigger = false;
    private float m_stamp = 0;
	private float m_rate = 0.6f;
	private WaitForSeconds ws = new WaitForSeconds(0.6f);



    /// <summary>
    /// 按下事件
    /// </summary>
    public ButtonDownEvent onDown
    {
        get { return m_OnDown; }
        set { m_OnDown = value; }
    }
    /// <summary>
    /// 弹起事件
    /// </summary>
    public ButtonUpEvent onUp
    {
        get { return m_OnUp; }
        set { m_OnUp = value; }
    }

    /// <summary>
    /// 长按回调
    /// </summary>
    public ButtonHoldEvent onHold
    {
        get { return m_Hold; }
        set { m_Hold = value; }
    }

	/// <summary>
	/// 长按回调
	/// </summary>
	public float rate
	{
		get { return m_rate; }
		set { m_rate = value; ws = new WaitForSeconds(m_rate); }
	}
//    public override void OnPointerClick(PointerEventData eventData)
//    {
//        if (eventData.button != PointerEventData.InputButton.Left || (m_holdtrigger && onHold.GetPersistentEventCount() > 0))
//        { return; }
//        onClick.Invoke();
//    }

    public override void OnPointerDown(PointerEventData eventData)
    {
        if (eventData.button != PointerEventData.InputButton.Left)
            return;
        isdown = true;
//        m_holdtrigger = false;
        float currstamp = Time.time;
        m_stamp = currstamp;
        m_OnDown.Invoke();
        StartCoroutine("begindown", currstamp);
		DoStateTransition(SelectionState.Pressed, false);
        if (IsInteractable() && EventSystem.current != null)
            EventSystem.current.SetSelectedGameObject(gameObject, eventData);
    }

    public override void OnPointerUp(PointerEventData eventData)
    {
        isdown = false;
        m_OnUp.Invoke();
		StopAllCoroutines ();
		DoStateTransition(SelectionState.Normal, false);
    }



    IEnumerator begindown(float laststamp)
    {
        yield return ws;
        if (laststamp == m_stamp && isdown)
        {
//            m_holdtrigger = true;
            m_stamp = 0;
            m_Hold.Invoke();
        }
    }
}
