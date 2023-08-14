using DG.Tweening;
using DG.Tweening.Core.Easing;
using System;
using System.Diagnostics;

public abstract class DOTweenAnimBase
{
    bool isFinish;
    bool isStart;
    float curTime;
    float duration;
    Ease ease;
    Action onComplete;

    public void Init(float duration)
    {
        this.duration = duration;
        isFinish = false;
        isStart = false;
        curTime = 0;
        ease = Ease.Unset;
        onComplete = null;
    }

    public void SetEase(Ease ease)
    {
        this.ease = ease;
    }

    public void SetComplete(Action onComplete)
    {
        this.onComplete = onComplete;
    }

    public bool IsFinish()
    {
        return isFinish;
    }

    public float GetCurrentTime()
    {
        return curTime;
    }

    public bool Play()
    {
        if (!isStart)
        {
            isStart = true;
            return true;
        }
        return false;
    }

    public bool Stop()
    {
        if (isStart)
        {
            isStart = false;
            return true;
        }
        return false;
    }

    public void Kill()
    {
        Finish(false);
    }

    public void Update(float deltaTime)
    {
        if (isStart && !isFinish)
        {
            curTime += deltaTime;
            OnUpdate(deltaTime);
            if (curTime >= duration)
            {
                Finish(true);
            }
        }
    }

    public float GetProgress()
    {
        if(duration <= 0) return 1;
        var cur = curTime > duration ? duration : curTime;
        return EaseManager.Evaluate(ease, null, cur, duration, 0, 0);
    }

    protected void Finish(bool callComplete)
    {
        if (!isFinish)
        {
            isFinish = true;
            Stop();
            if(callComplete && onComplete != null)
                onComplete.Invoke();
        }
    }

    protected virtual void OnUpdate(float deltaTime) { }
}
