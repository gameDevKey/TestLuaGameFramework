using DG.Tweening;
using DG.Tweening.Core.Easing;
using System;
using UnityEngine;

public class DOTweenMoveAnchorAnim : DOTweenAnimBase
{
    RectTransform transform;
    Vector2 toValue;
    Vector2 curValue;

    public void Init(RectTransform transform, Vector2 toValue, float duration)
    {
        base.Init(duration);
        this.transform = transform;
        this.toValue = toValue;
        curValue = new Vector2();
    }

    protected override void OnUpdate(float deltaTime)
    {
        var progress = GetProgress();
        var cur = transform.anchoredPosition;
        curValue.x = Mathf.Lerp(cur.x, toValue.x, progress);
        curValue.y = Mathf.Lerp(cur.y, toValue.y, progress);
        transform.anchoredPosition = curValue;
    }
}
