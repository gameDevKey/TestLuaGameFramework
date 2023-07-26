using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.AddressableAssets.ResourceLocators;
using UnityEngine.ResourceManagement.AsyncOperations;
using UnityEngine.SceneManagement;

public class GameLaunch : MonoSingleton<GameLaunch>
{
    public enum OpType
    {
        Unknown,
        AddressablesInit,
        CatalogCheckUpdate,
        CatalogUpdate,
        DownloadLua,
    }
    public Action<OpType, float> onProcess;
    public static bool Log = true;

    protected override void Awake()
    {
        base.Awake();
        // StartCoroutine(InitAddressables());

        if (Log) Debug.Log($"AddressablesInit开始.");
        var start = DateTime.Now;
        Addressables.InitializeAsync().Completed += (op) => {
            if (Log) Debug.Log($"AddressablesInit结束, 用时{(DateTime.Now - start).Milliseconds}ms.");
            StartCoroutine(CheckCatalogUpdate());
        };
    }

    IEnumerator HandleOp(OpType e, AsyncOperationHandle handle)
    {
        if (Log) Debug.Log($"[{e}]开始.");
        var start = DateTime.Now;
        onProcess?.Invoke(e, 0);
        while (!handle.IsDone)
        {
            onProcess?.Invoke(e, handle.PercentComplete);
            yield return null;
        }

        onProcess?.Invoke(e, 1);
        if (Log) Debug.Log($"[{e}]结束, 用时{(DateTime.Now - start).Milliseconds}ms.");
        if (handle.Status != AsyncOperationStatus.Succeeded)
        {
            if (Log) Debug.LogError($"[{e}]处理失败.");
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
        var handle = Addressables.DownloadDependenciesAsync("Lua");
        yield return HandleOp(OpType.DownloadLua,handle);
        yield return GameAssetLoader.Instance.LoadObjectByLabelAsync<TextAsset>("Lua");
        yield return Finish();
    }

    IEnumerator Finish()
    {
        // yield return SceneManager.LoadSceneAsync("Main");
        yield return null;
    }
}
