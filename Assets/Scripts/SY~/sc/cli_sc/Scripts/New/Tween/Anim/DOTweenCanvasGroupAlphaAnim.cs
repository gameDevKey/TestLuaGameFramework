using DG.Tweening;
using DG.Tweening.Core.Easing;
using System;
using UnityEngine;
using UnityEngine.UI;

public class DOTweenCanvasGroupAlphaAnim : DOTweenAnimBase
{
    CanvasGroup canvasGroup;
    float toValue;

    public void Init(CanvasGroup canvasGroup, float toValue, float duration)
    {
        base.Init(duration);
        this.canvasGroup = canvasGroup;
        this.toValue = toValue;
    }

    protected override void OnUpdate(float deltaTime)
    {
        var progress = GetProgress();
        canvasGroup.alpha = Mathf.Lerp(canvasGroup.alpha, toValue, progress);
    }
}
