
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class CustomUnityUtils
{
    private static Vector3 vector3 = new Vector3();
    private static Vector2 vector2 = new Vector2();
    private static Quaternion quaternion = new Quaternion();
    private static Color color = new Color();
    private static System.Diagnostics.Stopwatch watch = new System.Diagnostics.Stopwatch();

    public static void SetPosition(Transform transform, float x, float y, float z)
    {
        setVector3(x, y, z);
        transform.position = vector3;
    }

    public static void SetLocalPosition(Transform transform, float x, float y, float z)
    {
        setVector3(x, y, z);
        transform.localPosition = vector3;
    }

    public static void SetLocalScale(Transform transform, float x, float y, float z)
    {
        setVector3(x, y, z);
        transform.localScale = vector3;
    }

    public static void SetEulerAngles(Transform transform, float x, float y, float z)
    {
        setVector3(x, y, z);
        transform.eulerAngles = vector3;
    }

    public static void SetLocalEulerAngles(Transform transform, float x, float y, float z)
    {
        setVector3(x, y, z);
        transform.localEulerAngles = vector3;
    }

    public static void SetAnchoredPosition(RectTransform transform, float x, float y)
    {
        setVector2(x, y);
        transform.anchoredPosition = vector2;
    }

    public static void SetPivot(RectTransform transform, float x, float y)
    {
        setVector2(x, y);
        transform.pivot = vector2;
    }
    public static void SetSizeDelata(RectTransform transform, float x, float y)
    {
        setVector2(x, y);
        transform.sizeDelta = vector2;
    }

    public static void SetAnchorMin(RectTransform transform, float x, float y)
    {
        setVector2(x, y);
        transform.anchorMin = vector2;
    }

    public static void SetAnchorMax(RectTransform transform, float x, float y)
    {
        setVector2(x, y);
        transform.anchorMax = vector2;
    }

    public static void SetAnchorMinAndMax(RectTransform transform, float x1, float y1, float x2, float y2)
    {
        SetAnchorMin(transform, x1, y1);
        SetAnchorMax(transform, x2, y2);
    }

    public static void SetImageColor(Image image, float r, float g, float b, float a)
    {
        setColor(r, g, b, a);
        image.color = color;
    }

    public static void SetTextColor(Text text, float r, float g, float b, float a)
    {
        setColor(r, g, b, a);
        text.color = color;
    }

    private static void setVector2(float x, float y)
    {
        vector2.x = x;
        vector2.y = y;
    }

    private static void setVector3(float x, float y, float z)
    {
        vector3.x = x;
        vector3.y = y;
        vector3.z = z;
    }

    private static void setColor(float r,float g,float b,float a) 
    {
        color.r = r;
        color.g = g;
        color.b = b;
        color.a = a;
    }

    public static void SetActive(GameObject gameObject, bool active)
    {
        gameObject.SetActive(active);
    }

    public static void PointerDownHandler(GameObject clickObj, PointerEventData pointerEventData)
    {
        ExecuteEvents.Execute<IPointerDownHandler>(clickObj, pointerEventData, ExecuteEvents.pointerDownHandler);
    }

    public static void PointerUpHandler(GameObject clickObj, PointerEventData pointerEventData)
    {
        ExecuteEvents.Execute<IPointerUpHandler>(clickObj, pointerEventData, ExecuteEvents.pointerUpHandler);
    }

    public static void PointerClickHandler(GameObject clickObj, PointerEventData pointerEventData)
    {
        ExecuteEvents.Execute<IPointerClickHandler>(clickObj, pointerEventData, ExecuteEvents.pointerClickHandler);
    }



    public static int GetMillisecond()
    {
        return DateTime.Now.Millisecond;
    }

    public static void WatchStart()
    {
        watch.Reset();
        watch.Start();
    }

    public static double WatchStop()
    {
        watch.Stop();
        return watch.Elapsed.TotalMilliseconds;
    }

    public static bool IsPointerOverGameObjectV1(Vector2 screenPosition)
    {
        //实例化点击事件  
        PointerEventData eventDataCurrentPosition = new PointerEventData(UnityEngine.EventSystems.EventSystem.current);
        //将点击位置的屏幕坐标赋值给点击事件  
        eventDataCurrentPosition.position = screenPosition;

        List<RaycastResult> results = new List<RaycastResult>();
        //向点击处发射射线  
        EventSystem.current.RaycastAll(eventDataCurrentPosition, results);
        int uiLayer = LayerMask.NameToLayer("UI");
        int topUiLayer = LayerMask.NameToLayer("TopUI");
        for (int i = 0; i < results.Count; ++i)
        {
            if (results[i].gameObject.layer == uiLayer || results[i].gameObject.layer == topUiLayer) return true;
        }
        return false;
    }

    public static bool IsMatch(string str, string pattern)
    {
        return Regex.IsMatch(str, @pattern);
    }

    public static string ObjectToTextAsset(UnityEngine.Object assetObj)
    {
        TextAsset ta = assetObj as TextAsset;
        return ta.text;
    }

    public static void SetRotation(Transform transform, float x, float y, float z, float w)
    {
        quaternion.x = x;
        quaternion.y = y;
        quaternion.z = z;
        quaternion.w = w;
        transform.rotation = quaternion;
    }

    public static Vector3[] GetWorldCorners(RectTransform transform, Vector3[] coords)
    {
        transform.GetWorldCorners(coords);
        return coords;
    }

    public static Component AddComponent(GameObject obj,Type component)
    {
        return obj.AddComponent(component);
    }

    public static UnityEngine.Object Instantiate(UnityEngine.Object original)
    {
        return GameObject.Instantiate(original);
    }

    public static UnityEngine.Object Instantiate(UnityEngine.Object original, Transform parent)
    {
        return GameObject.Instantiate(original, parent);
    }

    public static UnityEngine.Object Instantiate(UnityEngine.Object original, Transform parent, bool instantiateInWorldSpace)
    {
        return GameObject.Instantiate(original, parent, instantiateInWorldSpace);
    }

    public static UnityEngine.Object Instantiate(UnityEngine.Object original, Vector3 position, Quaternion rotation)
    {
        return GameObject.Instantiate(original, position, rotation);
    }

    public static UnityEngine.Object Instantiate(UnityEngine.Object original, Vector3 position, Quaternion rotation, Transform parent)
    {
        return GameObject.Instantiate(original, position, rotation, parent);
    }
}
