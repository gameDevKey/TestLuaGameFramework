using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;

using XLua;

[LuaCallCSharp]
public class JoyStickDragEvent : UnityEvent{}
[LuaCallCSharp]
public class JoyStickDownEvent : UnityEvent<PointerEventData>{}

[LuaCallCSharp]
public class Joystick : ScrollRect, IPointerClickHandler , IPointerDownHandler, IPointerUpHandler{

	/// <summary>
	/// 摇杆的回调频率，数值越小效果越好
	/// </summary>
	public float updatetime = 0.1f;
	/// <summary>
	/// 是否锁定位置
	/// </summary>
	public bool donotmove = false;

    private float lastTime;
    public float mRadius=0f;
	protected Vector3 startPos;
	protected bool draging;
	protected Vector2 dir;
	private JoyStickDragEvent m_OnStickDrag = new JoyStickDragEvent();
	private JoyStickDragEvent m_OnBeginDrag = new JoyStickDragEvent();
	private JoyStickDragEvent m_OnEndDrag = new JoyStickDragEvent();
	private JoyStickDragEvent m_OnClick = new JoyStickDragEvent();
	private JoyStickDownEvent m_OnDown = new JoyStickDownEvent();
	private JoyStickDownEvent m_OnUp = new JoyStickDownEvent();
	private bool fireing;
	private Vector2 selfsize = Vector2.zero;
	private Vector2 parentsize = Vector2.zero;

	protected override void Start()
	{
		base.Start();
        //计算摇杆块的半径
        if (this.content != null)
            mRadius = (this.content.parent as RectTransform).sizeDelta.x * 0.5f;
        else
		    mRadius = (transform as RectTransform).sizeDelta.x * 0.5f;
		selfsize = (transform as RectTransform).sizeDelta;
		parentsize = transform.parent.GetComponent<RectTransform> ().sizeDelta;
		startPos = transform.localPosition;
		fireing = false;
		draging = false;
	}

	public JoyStickDragEvent onStickDrag
	{
		get{return m_OnStickDrag;}
		set{m_OnStickDrag = value;}
	}

	public JoyStickDragEvent onBeginDrag
	{
		get{return m_OnBeginDrag;}
		set{m_OnBeginDrag = value;}
	}

	public JoyStickDragEvent onEndDrag
	{
		get{return m_OnEndDrag;}
		set{m_OnEndDrag = value;}
	}

	public JoyStickDragEvent onClick
	{
		get{return m_OnClick;}
		set{m_OnClick = value;}
	}

	/// <summary>
	/// 按下事件
	/// </summary>
	public JoyStickDownEvent onDown
	{
		get { return m_OnDown; }
		set { m_OnDown = value; }
	}
	/// <summary>
	/// 弹起事件
	/// </summary>
	public JoyStickDownEvent onUp
	{
		get { return m_OnUp; }
		set { m_OnUp = value; }
	}

	public override void OnInitializePotentialDrag(UnityEngine.EventSystems.PointerEventData eventData)
	{
		//draging = true;
		base.OnInitializePotentialDrag (eventData);
	}

	public override void OnDrag (UnityEngine.EventSystems.PointerEventData eventData)
	{
		draging = true;
		base.OnDrag (eventData);
		var contentPostion = this.content.anchoredPosition;
		if (contentPostion.magnitude - mRadius>0.0001f){
			if (!donotmove) {
				Vector3 targetpos = transform.localPosition + (Vector3)contentPostion.normalized*(contentPostion.magnitude - mRadius);
				float tx = Mathf.Clamp (targetpos.x, selfsize.x/2, (parentsize.x-selfsize.x/2));
				float ty = Mathf.Clamp (targetpos.y, selfsize.x/2, (parentsize.y-selfsize.y/2));
				transform.localPosition = new Vector3 (tx, ty, 0);
			}
			//transform.localPosition += (Vector3)contentPostion.normalized*(contentPostion.magnitude - mRadius);
			contentPostion = contentPostion.normalized * mRadius ;
			SetContentAnchoredPosition(contentPostion);
		}
	}

	public override void OnEndDrag(UnityEngine.EventSystems.PointerEventData eventData)
	{
		if(draging){
			base.OnEndDrag (eventData);
			transform.localPosition = startPos;
			draging = false;
			fireing = false;
			SetContentAnchoredPosition(Vector2.zero);
			m_OnEndDrag.Invoke ();
		}

	}

    public void Update()
    {
        if (draging)
        {
            if (Time.realtimeSinceStartup - lastTime > updatetime)
            {
                m_OnStickDrag.Invoke();
                fireing = true;
                lastTime = Time.realtimeSinceStartup;
            }
        }
        else
        {
            fireing = false;
        }
    }

    public void OnPointerClick(PointerEventData eventData)
	{
		m_OnClick.Invoke ();
	}

	public void OnPointerDown(PointerEventData eventData)
	{
		if (eventData.button != PointerEventData.InputButton.Left)
			return;
		m_OnDown.Invoke(eventData);
	}

	public void OnPointerUp(PointerEventData eventData)
	{
		m_OnUp.Invoke(eventData);
		transform.localPosition = startPos;
		draging = false;
		fireing = false;
		SetContentAnchoredPosition(Vector2.zero);
	}

	public void SetStartPos(Vector3 position)
	{
		this.startPos = position;
	}

}
