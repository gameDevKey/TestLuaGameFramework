using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using XLua;

[LuaCallCSharp]
public class ButtonEnterEvent : UnityEvent {
}
[LuaCallCSharp]
public class ButtonExsitDragEvent : UnityEvent {
}

[LuaCallCSharp]
public class CustomEnterExsitButton : CustomButton,IPointerEnterHandler,IPointerExitHandler, IBeginDragHandler, IDragHandler, IEndDragHandler {


    private ButtonEnterEvent m_OnEnter = new ButtonEnterEvent();
    private ButtonExsitDragEvent m_OnExsit = new ButtonExsitDragEvent();
    private ButtonBeginDragEvent m_OnBeginDrag = new ButtonBeginDragEvent();
    private ButtonDragEvent m_OnDrag = new ButtonDragEvent();
    private ButtonEndDragEvent m_OnEndDrag = new ButtonEndDragEvent();

    private Vector3 last_pos;
    private RectTransform m_rectts;
    private Camera m_Camera;
    public bool hardcoreModel = false; // 硬核模式，用于解决快速划过屏幕检测不到鼠标进入的问题
    protected override void Awake()
    {
        base.Awake();
        m_rectts = GetComponent<RectTransform>();
        m_Camera = Game.Logic.GameContext.GetInstance().UICamera;
    }

    void Update() {
        if (hardcoreModel)
        {
            if ((Input.touchCount > 0
                              || Input.GetMouseButton(0)))
            {
                Vector3 currpos;
#if UNITY_IPHONE || UNITY_IOS || UNITY_ANDROID
                Vector3 worldPos = m_Camera.ScreenToWorldPoint(Input.GetTouch(0).position);//屏幕坐标转换世界坐标
                currpos = transform.InverseTransformPoint(worldPos);//世界坐标转换位本地坐标
#else
                Vector3 worldPos = m_Camera.ScreenToWorldPoint(Input.mousePosition);//屏幕坐标转换世界坐标
                currpos = transform.InverseTransformPoint(worldPos);//世界坐标转换位本地坐标
#endif
                if (last_pos != Vector3.zero)
                {
                    if (LineIntersectRect(last_pos, currpos))
                    {
                        //Debug.Log(leftDown);
                        //Debug.Log(leftUp);
                        OnPointerEnter(null);
                        OnPointerExit(null);
                    }
                }
                last_pos = currpos;
            }
            else
                last_pos = Vector3.zero; 
        }
    }
    /// <summary>
    /// 开始拖动事件
    /// </summary>
    public ButtonEnterEvent onEnter {
        get {
            return m_OnEnter;
        }
        set {
            m_OnEnter = value;
        }
    }

    /// <summary>
    /// 拖动ing事件
    /// </summary>
    public ButtonExsitDragEvent onExsit {
        get {
            return m_OnExsit;
        }
        set {
            m_OnExsit = value;
        }
    }

    /// <summary>
    /// 开始拖动事件
    /// </summary>
    public ButtonBeginDragEvent onBeginDrag {
        get { return m_OnBeginDrag; }
        set { m_OnBeginDrag = value; }
    }

    /// <summary>
    /// 拖动ing事件
    /// </summary>
    public ButtonDragEvent onDrag {
        get { return m_OnDrag; }
        set { m_OnDrag = value; }
    }

    /// <summary>
    /// 拖动结束事件
    /// </summary>
    public ButtonEndDragEvent onEndDrag {
        get { return m_OnEndDrag; }
        set { m_OnEndDrag = value; }
    }

    public virtual void OnBeginDrag(PointerEventData eventData) {
        m_OnBeginDrag.Invoke(eventData);
    }

    public virtual void OnDrag(PointerEventData eventData) {
        m_OnDrag.Invoke(eventData);
    }

    public virtual void OnEndDrag(PointerEventData eventData) {
        m_OnEndDrag.Invoke(eventData);
    }

    public override void OnPointerEnter(PointerEventData eventData) {
        m_OnEnter.Invoke();
    }

    public override void OnPointerExit(PointerEventData eventData) {
        m_OnExsit.Invoke();
    }



    Vector3 leftDown
    {
        get
        {
            return new Vector2(m_rectts.rect.xMin, m_rectts.rect.yMin);
        }
    }
    Vector3 leftUp
    {
        get
        {
            return new Vector2(m_rectts.rect.xMin, m_rectts.rect.yMax);
        }
    }
    Vector3 RigtDown
    {
        get
        {
            return new Vector2(m_rectts.rect.xMax, m_rectts.rect.yMin);
        }
    }
    Vector3 RightUp
    {
        get
        {
            return new Vector2(m_rectts.rect.xMax, m_rectts.rect.yMax);
        }
    }

    // 线是否在矩形内
    bool LineInRect(Vector2 lineStart, Vector2 lineEnd, Rect rect)
    {
        return rect.Contains(lineStart) || rect.Contains(lineEnd);
    }

    // 线与矩形是否相交
    bool LineIntersectRect(Vector2 lineStart, Vector2 lineEnd)
    {
        if (LineIntersectLine(lineStart, lineEnd, leftDown, leftUp))
            return true;
        if (LineIntersectLine(lineStart, lineEnd, leftUp, RightUp))
            return true;
        if (LineIntersectLine(lineStart, lineEnd, RightUp, RigtDown))
            return true;
        if (LineIntersectLine(lineStart, lineEnd, RigtDown, leftDown))
            return true;

        return false;
    }

    // 线与线是否相交
    bool LineIntersectLine(Vector2 l1Start, Vector2 l1End, Vector2 l2Start, Vector2 l2End)
    {
        return QuickReject(l1Start, l1End, l2Start, l2End) && Straddle(l1Start, l1End, l2Start, l2End);
    }

    // 快速排序。  true=通过， false=不通过
    bool QuickReject(Vector2 l1Start, Vector2 l1End, Vector2 l2Start, Vector2 l2End)
    {
        float l1xMax = Mathf.Max(l1Start.x, l1End.x);
        float l1yMax = Mathf.Max(l1Start.y, l1End.y);
        float l1xMin = Mathf.Min(l1Start.x, l1End.x);
        float l1yMin = Mathf.Min(l1Start.y, l1End.y);

        float l2xMax = Mathf.Max(l2Start.x, l2End.x);
        float l2yMax = Mathf.Max(l2Start.y, l2End.y);
        float l2xMin = Mathf.Min(l2Start.x, l2End.x);
        float l2yMin = Mathf.Min(l2Start.y, l2End.y);

        if (l1xMax < l2xMin || l1yMax < l2yMin || l2xMax < l1xMin || l2yMax < l1yMin)
            return false;

        return true;
    }

    // 跨立实验
    bool Straddle(Vector3 l1Start, Vector3 l1End, Vector3 l2Start, Vector3 l2End)
    {
        float l1x1 = l1Start.x;
        float l1x2 = l1End.x;
        float l1y1 = l1Start.y;
        float l1y2 = l1End.y;
        float l2x1 = l2Start.x;
        float l2x2 = l2End.x;
        float l2y1 = l2Start.y;
        float l2y2 = l2End.y;

        if ((((l1x1 - l2x1) * (l2y2 - l2y1) - (l1y1 - l2y1) * (l2x2 - l2x1)) *
             ((l1x2 - l2x1) * (l2y2 - l2y1) - (l1y2 - l2y1) * (l2x2 - l2x1))) > 0 ||
            (((l2x1 - l1x1) * (l1y2 - l1y1) - (l2y1 - l1y1) * (l1x2 - l1x1)) *
             ((l2x2 - l1x1) * (l1y2 - l1y1) - (l2y2 - l1y1) * (l1x2 - l1x1))) > 0)
        {
            return false;
        }

        return true;
    }

}
