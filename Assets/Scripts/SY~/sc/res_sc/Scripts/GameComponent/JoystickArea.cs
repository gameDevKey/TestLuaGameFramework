using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;

using SLua;

[CustomLuaClass]
public class JoystickArea : Button, IInitializePotentialDragHandler, IBeginDragHandler, IDragHandler, IEndDragHandler, IPointerUpHandler {
	
	public Joystick com;
	public RectTransform comrect;
	public Canvas canvas;
	public RectTransform selfrect;
	private Vector2 localpos;
	// Use this for initialization
	protected override void Start () {
		if (com == null||comrect == null||selfrect == null) {
			GameObject go = GameObject.Find ("JoyStickBtn");
			if (go != null) {
				com = go.GetComponent<Joystick> ();
				comrect = go.GetComponent<RectTransform> ();
			}
		}
		if (selfrect != null)
			selfrect = comrect.parent.GetComponent<RectTransform> ();
			
	}
	public void OnInitializePotentialDrag(UnityEngine.EventSystems.PointerEventData eventData)
	{
		if (com == null || comrect == null || selfrect == null)
			return;
		RectTransformUtility.ScreenPointToLocalPointInRectangle (selfrect, eventData.position, eventData.pressEventCamera, out localpos);
		comrect.localPosition = localpos;
		com.OnInitializePotentialDrag (eventData);
	}

	public void OnBeginDrag (UnityEngine.EventSystems.PointerEventData eventData)
	{	
		if (com == null || comrect == null || selfrect == null)
			return;
		RectTransformUtility.ScreenPointToLocalPointInRectangle (selfrect, eventData.position, eventData.pressEventCamera, out localpos);
		comrect.localPosition = localpos;
		com.OnBeginDrag (eventData);
	}

	public void OnDrag (UnityEngine.EventSystems.PointerEventData eventData)
	{
		com.OnDrag (eventData);
	}

	public void OnEndDrag(UnityEngine.EventSystems.PointerEventData eventData)
	{
		com.OnEndDrag (eventData);
	}

	public override void OnPointerUp(UnityEngine.EventSystems.PointerEventData eventData)
	{
		com.OnEndDrag (eventData);
	}
}
