using DG.Tweening;
using DG.Tweening.Core.Easing;
using System;
using UnityEngine;
using UnityEngine.UI;

public class DOTweenColorAnim : DOTweenAnimBase
{
    UnityEngine.UI.Graphic graphic;
    Color toValue;
    Color curValue;

    public void Init(UnityEngine.UI.Graphic graphic, Color toValue, float duration)
    {
        base.Init(duration);
        this.graphic = graphic;
        this.toValue = toValue;
        curValue = new Color();
    }

    protected override void OnUpdate(float deltaTime)
    {
        var progress = GetProgress();
        var cur = graphic.color;
        curValue.r = Mathf.Lerp(cur.r, toValue.r, progress);
        curValue.g = Mathf.Lerp(cur.g, toValue.g, progress);
        curValue.b = Mathf.Lerp(cur.b, toValue.b, progress);
        curValue.a = Mathf.Lerp(cur.a, toValue.a, progress);
        graphic.color = curValue;
    }
}
