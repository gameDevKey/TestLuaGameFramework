using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.U2D;
using UnityEngine.AddressableAssets;
using UnityEngine.AddressableAssets.ResourceLocators;
using UnityEngine.ResourceManagement.AsyncOperations;
using IResourceLocation = UnityEngine.ResourceManagement.ResourceLocations.IResourceLocation;


public class GameAssetLoader : MonoSingleton<GameAssetLoader>
{
    public static bool Log = true;
    static Dictionary<Type, Dictionary<string, UnityEngine.Object>> assetCache = null;

    #region 静态函数
    public static void LoadObjectByLabelSync<T>(string label, Action<T> callback) where T : UnityEngine.Object
    {
        if (Log) Debug.Log($"开始加载label:{label}的{typeof(T)}");
        float st = Time.realtimeSinceStartup;
        var handles = Addressables.LoadAssetsAsync<T>(label, callback);
        handles.WaitForCompletion();
        if (Log) Debug.Log($"结束加载label:{label}的{typeof(T)},用时{Time.realtimeSinceStartup - st}s");
    }

    public static IEnumerator LoadObjectByLabelAsync<T>(string label, Action<IResourceLocation, AsyncOperationHandle<T>> callback) where T : UnityEngine.Object
    {
        if (Log) Debug.Log($"开始加载label:{label}的{typeof(T)}");
        float st = Time.realtimeSinceStartup;
        var locations = Addressables.LoadResourceLocationsAsync(label);
        yield return locations;
        var ops = new List<AsyncOperationHandle>(locations.Result.Count);
        foreach (var location in locations.Result)
        {
            var handle = Addressables.LoadAssetAsync<T>(location);
            handle.Completed += op => { callback.Invoke(location, op); };
            ops.Add(handle);
        }
        yield return Addressables.ResourceManager.CreateGenericGroupOperation(ops, true);
        if (Log) Debug.Log($"结束加载label:{label}的{typeof(T)},用时{Time.realtimeSinceStartup - st}s");
    }
    #endregion 静态函数

    public void Init()
    {
        if (assetCache == null)
        {
            assetCache = new Dictionary<Type, Dictionary<string, UnityEngine.Object>>();
        }
        else
        {
            assetCache.Clear();
        }
    }

    public void AddAsset(string key, UnityEngine.Object obj)
    {
        var tpe = obj.GetType();
        if (!assetCache.ContainsKey(tpe))
        {
            assetCache.Add(tpe, new Dictionary<string, UnityEngine.Object>());
        }
        if (!assetCache[tpe].TryAdd(key, obj))
        {
            Debug.LogError($"资源重复添加:Key={key} Type={tpe}");
        }
    }

    public UnityEngine.Object GetAsset<T>(string key)
    {
        Dictionary<string, UnityEngine.Object> dict;
        assetCache.TryGetValue(typeof(T), out dict);
        UnityEngine.Object obj;
        dict.TryGetValue(key, out obj);
        return obj;
    }

    public bool ExistAsset<T>(string key)
    {
        var tpe = typeof(T);
        return assetCache.ContainsKey(tpe) && assetCache[tpe].ContainsKey(key);
    }

    public UnityEngine.Object GetOrLoadAsset<T>(string key)
    {
        if (!ExistAsset<T>(key))
        {
            var op = Addressables.LoadAssetAsync<UnityEngine.Object>(key);
            op.WaitForCompletion();
            AddAsset(key, op.Result);
        }
        return GetAsset<T>(key);
    }

    public byte[] LoadBytes(string path)
    {
        var text = GetOrLoadAsset<UnityEngine.TextAsset>(path) as UnityEngine.TextAsset;
        return text.bytes;
    }

    public string LoadText(string path)
    {
        var text = GetOrLoadAsset<UnityEngine.TextAsset>(path) as UnityEngine.TextAsset;
        return text.text;
    }

    public UnityEngine.GameObject LoadGameObject(string path)
    {
        return GetOrLoadAsset<UnityEngine.GameObject>(path) as UnityEngine.GameObject;
    }

    public void LoadAtlasByLabel(string label)
    {
        GameAssetLoader.LoadObjectByLabelSync<SpriteAtlas>(label,(obj)=>{
            Sprite[] sp = new Sprite[obj.spriteCount];
            obj.GetSprites(sp);
            for (int i = 0; i < sp.Length; i++)
            {
                string key = sp[i].name.ToLower().Replace("(clone)","");
                if(!ExistAsset<Sprite>(key)) AddAsset(key, sp[i]);
            }
        });
    }
}
