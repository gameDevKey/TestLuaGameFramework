using DG.Tweening;
using DG.Tweening.Core.Easing;
using System;
using UnityEngine;

public class DOTweenMoveAnchor3DAnim : DOTweenAnimBase
{
    RectTransform transform;
    Vector3 toValue;
    Vector3 curValue;

    public void Init(RectTransform transform, Vector3 toValue, float duration)
    {
        base.Init(duration);
        this.transform = transform;
        this.toValue = toValue;
        curValue = new Vector2();
    }

    protected override void OnUpdate(float deltaTime)
    {
        var progress = GetProgress();
        var cur = transform.anchoredPosition3D;
        curValue.x = Mathf.Lerp(cur.x, toValue.x, progress);
        curValue.y = Mathf.Lerp(cur.y, toValue.y, progress);
        curValue.z = Mathf.Lerp(cur.z, toValue.z, progress);
        transform.anchoredPosition3D = curValue;
    }
}
