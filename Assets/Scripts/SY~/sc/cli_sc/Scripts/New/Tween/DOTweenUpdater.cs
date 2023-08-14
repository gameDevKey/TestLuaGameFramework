using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using DG.Tweening.Core.Easing;

public class DOTweenUpdater : Singleton<DOTweenUpdater>
{
    List<DOTweenAnimBase> doTweenItems;

    protected override void Initialize()
    {
        doTweenItems = new List<DOTweenAnimBase>();
    }

    public void AddUpdateItem(DOTweenAnimBase item)
    {
        if (item == null) return;
        if (doTweenItems.Contains(item)) RemoveUpdateItem(item);

        doTweenItems.Add(item);
    }

    public bool RemoveUpdateItem(DOTweenAnimBase item)
    {
        return doTweenItems.Remove(item);
    }


    void Update()
    {
        for (int i = doTweenItems.Count-1; i >= 0 ; i--)
        {
            var curItem = doTweenItems[i];
            if (curItem.IsFinish())
            {
                doTweenItems.RemoveAt(i);
            }
            else
            {
                curItem.Update(Time.deltaTime);
            }
        }
    }

    void OnDestroy()
    {
        if (doTweenItems != null)
        {
            for (int i = doTweenItems.Count - 1; i >= 0; i--)
            {
                var curItem = doTweenItems[i];
                curItem.Kill();
            }
        }
        doTweenItems = null;
    }
}