using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DOTweenAnimEx
{
    public static DOTweenScaleAnim CreateScaleAnim(Transform transform, Vector3 toValue, float duration)
    {
        var anim = DOTweenAnimFactory.CreateAnim<DOTweenScaleAnim>();
        anim.Init(transform, toValue, duration);
        return anim;
    }

    public static DOTweenMoveAnchorAnim CreateMoveAnchorAnim(RectTransform transform, Vector2 toValue, float duration)
    {
        var anim = DOTweenAnimFactory.CreateAnim<DOTweenMoveAnchorAnim>();
        anim.Init(transform, toValue, duration);
        return anim;
    }

    public static DOTweenMoveAnchor3DAnim CreateMoveAnchor3DAnim(RectTransform transform, Vector3 toValue, float duration)
    {
        var anim = DOTweenAnimFactory.CreateAnim<DOTweenMoveAnchor3DAnim>();
        anim.Init(transform, toValue, duration);
        return anim;
    }

    public static DOTweenColorAnim CreateColorAnim(UnityEngine.UI.Graphic graphic, Color toValue, float duration)
    {
        var anim = DOTweenAnimFactory.CreateAnim<DOTweenColorAnim>();
        anim.Init(graphic, toValue, duration);
        return anim;
    }

    public static DOTweenCanvasGroupAlphaAnim CreateCanvasGroupAlphaAnim(UnityEngine.CanvasGroup canvasGroup, float toValue, float duration)
    {
        var anim = DOTweenAnimFactory.CreateAnim<DOTweenCanvasGroupAlphaAnim>();
        anim.Init(canvasGroup, toValue, duration);
        return anim;
    }

    public static DOTweenDelayAnim CreateDelayAnim(float duration)
    {
        var anim = DOTweenAnimFactory.CreateAnim<DOTweenDelayAnim>();
        anim.Init(duration);
        return anim;
    }
}
