using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class DOTweenEx
{
    static Vector3 vector3 = new Vector3();

    public static Tweener ToValueInt(int fromValue, int toValue, float time, System.Action<int> cb)
    {
        Tweener tween = DOTween.To(() => fromValue, v => cb(v), toValue, time);
        return tween;
    }

    public static Tweener ToValueUInt(uint fromValue, uint toValue, float time, System.Action<uint> cb)
    {
        Tweener tween = DOTween.To(() => fromValue, v => cb(v), toValue, time);
        return tween;
    }

    public static Tweener ToValueDouble(double fromValue, double toValue, float time, System.Action<double> cb)
    {
        Tweener tween = DOTween.To(() => fromValue, v => cb(v), toValue, time);
        return tween;
    }

    public static Tweener ToValueFloat(float fromValue, float toValue, float time, System.Action<float> cb)
    {
        Tweener tween = DOTween.To(() => fromValue, v => cb(v), toValue, time);
        return tween;
    }

    public static Tweener ToValueLong(long fromValue, long toValue,float time, System.Action<long> cb)
    {
        Tweener tween = DOTween.To(() => fromValue, v => cb(v), toValue, time);
        return tween;
    }

    public static Tweener ToValueULong(ulong fromValue, ulong toValue, float time, System.Action<ulong> cb)
    {
        Tweener tween = DOTween.To(() => fromValue, v => cb(v), toValue, time);
        return tween;
    }

    public static Tweener ToValue(Quaternion fromValue, Vector3 toValue, float time,System.Action<Quaternion> cb)
    {
        Tweener tween = DOTween.To(() => fromValue, v => cb(v), toValue, time);
        return tween;
    }

    public static Tweener ToValue(string fromValue, string toValue, float time, System.Action<string> cb)
    {
        Tweener tween = DOTween.To(() => fromValue, v => cb(v), toValue, time);
        return tween;
    }

    public static Tweener ToValue(Vector2 fromValue, Vector2 toValue, float time, System.Action<Vector2> cb)
    {
        Tweener tween = DOTween.To(() => fromValue, v => cb(v), toValue, time);
        return tween;
    }

    public static Tweener ToValue(Vector3 fromValue, Vector3 toValue, float time, System.Action<Vector3> cb)
    {
        Tweener tween = DOTween.To(() => fromValue, v => cb(v), toValue, time);
        return tween;
    }

    public static Tweener ToValue(Vector4 fromValue, Vector4 toValue, float time, System.Action<Vector4> cb)
    {
        Tweener tween = DOTween.To(() => fromValue, v => cb(v), toValue, time);
        return tween;
    }

    public static Tweener ToValue(Color fromValue, Color toValue, float time, System.Action<Color> cb)
    {
        Tweener tween = DOTween.To(() => fromValue, v => cb(v), toValue, time);
        return tween;
    }

    public static Tweener ToValue(Rect fromValue, Rect toValue, float time, System.Action<Rect> cb)
    {
        Tweener tween = DOTween.To(() => fromValue, v => cb(v), toValue, time);
        return tween;
    }

    public static Tweener ToValue(RectOffset fromValue, RectOffset toValue, float time, System.Action<RectOffset> cb)
    {
        Tweener tween = DOTween.To(() => fromValue, v => cb(v), toValue, time);
        return tween;
    }

    public static Tweener ToAlpha(Color fromValue, float toValue, float time, System.Action<Color> cb)
    {
        Tweener tween = DOTween.ToAlpha(() => fromValue, v=> cb(v), toValue, time);
        return tween;
    }

    public static Tweener ToArray(Vector3 fromValue, Vector3[] toValue, float[] time, System.Action<Vector3> cb)
    {
        Tweener tween = DOTween.ToArray(() => fromValue, v => cb(v), toValue, time);
        return tween;
    }
    public static Tweener ToAxis(Vector3 fromValue, float toValue, float time, System.Action<Vector3> cb, AxisConstraint axisConstraint = AxisConstraint.X)
    {
        Tweener tween = DOTween.ToAxis(() => fromValue, v => cb(v), toValue, time,axisConstraint);
        return tween;
    }

    public static Tweener Delay(float time)
    {
        Tweener tween = DOTween.To(() => 0, v => {}, 1, time);
        return tween;
    }

    public static Tweener DOLocalRotateX( Transform transform,float toX, float time)
    {
        Tweener tween = DOTween.To(() => transform.localEulerAngles.x, v => {
            vector3.Set(v, transform.localEulerAngles.y, transform.localEulerAngles.z);
            transform.localEulerAngles = vector3;
        }, toX, time);
        return tween;
    }

    public static Tweener DOLocalRotateY(Transform transform, float toY, float time)
    {
        Tweener tween = DOTween.To(() => transform.localEulerAngles.y, v => {
            vector3.Set(transform.localEulerAngles.x, v, transform.localEulerAngles.z);
            transform.localEulerAngles = vector3;
        }, toY, time);
        return tween;
    }

    public static Tweener DOLocalRotateZ(Transform transform, float toZ, float time)
    {
        Tweener tween = DOTween.To(() => transform.localEulerAngles.z, v => {
            vector3.Set(transform.localEulerAngles.x, transform.localEulerAngles.y, v);
            transform.localEulerAngles = vector3;
        }, toZ, time);
        return tween;
    }


    public static Tweener DORotateX(Transform transform, float toX, float time)
    {
        Tweener tween = DOTween.To(() => transform.eulerAngles.x, v => {
            vector3.Set(v, transform.eulerAngles.y, transform.eulerAngles.z);
            transform.eulerAngles = vector3;
        }, toX, time);
        return tween;
    }

    public static Tweener DORotateY(Transform transform, float toY, float time)
    {
        Tweener tween = DOTween.To(() => transform.eulerAngles.y, v => {
            vector3.Set(transform.eulerAngles.x, v, transform.eulerAngles.z);
            transform.eulerAngles = vector3;
        }, toY, time);
        return tween;
    }

    public static Tweener DORotateZ(Transform transform, float toZ, float time)
    {
        Tweener tween = DOTween.To(() => transform.eulerAngles.z, v => {
            vector3.Set(transform.eulerAngles.x, transform.eulerAngles.y, v);
            transform.eulerAngles = vector3;
        }, toZ, time);
        return tween;
    }
}