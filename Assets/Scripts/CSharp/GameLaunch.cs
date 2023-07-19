using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.AddressableAssets.ResourceLocators;
using UnityEngine.ResourceManagement.AsyncOperations;

public class GameLaunch : MonoSingleton<GameLaunch>
{
    public enum OpType
    {
        Unknown,
        AddressablesInit,
        CatalogCheckUpdate,
        CatalogUpdate,
    }
    public Action<OpType, float> onProcess;

    protected override void Awake()
    {
        base.Awake();
        StartCoroutine(InitAddressables());
    }

    IEnumerator HandleOp(OpType e, AsyncOperationHandle handle)
    {
        Debug.Log($"[{e}]开始.");
        var start = DateTime.Now;
        onProcess?.Invoke(e, 0);
        while (!handle.IsDone)
        {
            onProcess?.Invoke(e, handle.PercentComplete);
            yield return null;
        }
        onProcess?.Invoke(e, 1);
        var spendTime = (DateTime.Now - start).Milliseconds;
        Debug.Log($"[{e}]结束, 用时{spendTime}ms.");
        if (handle.Status != AsyncOperationStatus.Succeeded)
        {
            Debug.LogError($"[{e}]处理失败.");
        }
    }

    IEnumerator InitAddressables()
    {
        AsyncOperationHandle<IResourceLocator> handle = Addressables.InitializeAsync();
        yield return HandleOp(OpType.AddressablesInit, handle);
        yield return CheckCatalogUpdate();
    }

    IEnumerator CheckCatalogUpdate()
    {
        AsyncOperationHandle<List<string>> handle = Addressables.CheckForCatalogUpdates(false);
        yield return HandleOp(OpType.CatalogCheckUpdate, handle);
        if (handle.Status == AsyncOperationStatus.Succeeded)
        {
            List<string> catalogs = handle.Result;
            yield return CatalogUpdate(catalogs);
        }
    }

    IEnumerator CatalogUpdate(List<string> catalogs)
    {
        var suc = true;
        if (catalogs != null && catalogs.Count > 0)
        {
            AsyncOperationHandle<List<IResourceLocator>> handle = Addressables.UpdateCatalogs(catalogs, false);
            yield return HandleOp(OpType.CatalogUpdate, handle);
            suc = handle.Status == AsyncOperationStatus.Succeeded;
        }
        if (suc) yield return LoadAssets();
    }

    IEnumerator LoadAssets()
    {
        //TODO
        yield break;
    }
}
