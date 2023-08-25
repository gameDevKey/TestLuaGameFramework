using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.U2D;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;
using IResourceLocation = UnityEngine.ResourceManagement.ResourceLocations.IResourceLocation;
using XLua;
using Object = UnityEngine.Object;

// Asset要避免重复请求加载，在结果返回之前，若Asset已经标记为加载中
// 则后续的加载回调都先缓存起来，加载结束后统一回调

[LuaCallCSharp]
public class GameAssetLoader : MonoSingleton<GameAssetLoader>
{
    public static bool Log = true;
    Dictionary<string, bool> loadLock = null;
    Dictionary<Type, Dictionary<string, Object>> assetCache = null;
    Dictionary<string, List<Action<Object>>> waitCalls;
    Dictionary<Sprite, SpriteAtlas> sprite2Atlas;

    protected override void Awake()
    {
        base.Awake();
        Init();
    }

    public void Init()
    {
        if (assetCache == null) assetCache = new Dictionary<Type, Dictionary<string, Object>>();
        else assetCache.Clear();

        if (loadLock == null) loadLock = new Dictionary<string, bool>();
        else loadLock.Clear();

        if (waitCalls == null) waitCalls = new Dictionary<string, List<Action<Object>>>();
        else waitCalls.Clear();

        if (sprite2Atlas == null) sprite2Atlas = new Dictionary<Sprite, SpriteAtlas>();
        else sprite2Atlas.Clear();
    }

    #region 获取资源的接口

    public Object GetAsset<T>(string key)
    {
        Dictionary<string, Object> dict;
        assetCache.TryGetValue(typeof(T), out dict);
        Object obj;
        dict.TryGetValue(key, out obj);
        return obj;
    }

    public bool ExistAsset<T>(string key)
    {
        var tpe = typeof(T);
        return assetCache.ContainsKey(tpe) && assetCache[tpe].ContainsKey(key);
    }

    // WaitForCompletion 竟然也会出现未结束前多次调用的情况..
    // public Object GetOrLoadAsset<T>(string key)
    // {
    //     if (!ExistAsset<T>(key))
    //     {
    //         if (Log) Debug.Log($"加载{key}({typeof(T)})开始.");
    //         var start = DateTime.Now;
    //         var op = Addressables.LoadAssetAsync<Object>(key);
    //         op.WaitForCompletion();
    //         AddAsset(key, op.Result);
    //         if (Log) Debug.Log($"加载{key}({typeof(T)})结束, 用时{(DateTime.Now - start).Milliseconds}ms.");
    //     }
    //     return GetAsset<T>(key);
    // }

    public IEnumerator GetOrLoadAssetAsync<T>(string key, Action<Object> callback)
    {
        if (ExistAsset<T>(key))
        {
            callback.Invoke(GetAsset<T>(key));
            yield break;
        }

        var loadKey = GetLoadKey<T>(key);
        //回调缓存
        if (!waitCalls.ContainsKey(key))
            waitCalls.TryAdd(key, new List<Action<Object>>());
        waitCalls[key].Add(callback);
        //资源标记为加载(防止加载未结束前多次调用)
        if (loadLock.TryAdd(loadKey, true))
        {
            //开始加载资源
            if (Log) Debug.Log($"加载{key}({typeof(T)})开始.");
            var start = DateTime.Now;
            var op = Addressables.LoadAssetAsync<Object>(key);
            op.Completed += op =>
            {
                //加载资源结束
                AddAsset(key, op.Result);
                foreach (var call in waitCalls[key])
                {
                    call.Invoke(op.Result);
                }
                waitCalls[key].Clear();
                loadLock[key] = false;
                if (Log) Debug.Log($"加载{key}({typeof(T)})结束, 用时{(DateTime.Now - start).Milliseconds}ms.");
            };
            yield return op;
        }

    }

    // public byte[] LoadBytes(string path)
    // {
    //     var text = GetOrLoadAsset<TextAsset>(path) as TextAsset;
    //     return text.bytes;
    // }

    // public string LoadText(string path)
    // {
    //     var text = GetOrLoadAsset<TextAsset>(path) as TextAsset;
    //     return text.text;
    // }

    public void GetTextAsync(string path, LuaFunction func)
    {
        StartCoroutine(GetOrLoadAssetAsync<TextAsset>(path, (obj) =>
        {
            func.Call((obj as TextAsset)?.text, path);
        }));
    }

    // public GameObject LoadGameObject(string path)
    // {
    //     return GetOrLoadAsset<GameObject>(path) as GameObject;
    // }

    public void GetGameObjectAsync(string path, Action<GameObject, string> func)
    {
        StartCoroutine(GetOrLoadAssetAsync<GameObject>(path, (obj) =>
        {
            func.Invoke(obj as GameObject, path);
        }));
    }

    public void GetGameObjectAsync(string path, LuaFunction func)
    {
        StartCoroutine(GetOrLoadAssetAsync<GameObject>(path, (obj) =>
        {
            func.Call(obj as GameObject, path);
        }));
    }

    public SpriteAtlas GetAtlasBySpriteKey(string spriteKey)
    {
        var sprite = GetAsset<Sprite>(spriteKey);
        if (sprite == null) return null;
        return GetAtlasBySprite(sprite as Sprite);
    }

    public SpriteAtlas GetAtlasBySprite(Sprite sprite)
    {
        if (sprite == null) return null;
        sprite2Atlas.TryGetValue(sprite, out var atlas);
        return atlas;
    }

    #endregion


    #region 加载到内存的接口

    //加载SpriteAtlas到内存中(获取Sprite前先加载SpriteAtlas)
    public IEnumerator LoadAtlasByLabelAsync(string label)
    {
        yield return LoadObjectByLabelAsync<SpriteAtlas>(label, (location, obj) =>
        {
            Sprite[] sp = new Sprite[obj.spriteCount];
            obj.GetSprites(sp);
            for (int i = 0; i < sp.Length; i++)
            {
                string key = sp[i].name.Replace("(Clone)", "");
                //if (!ExistAsset<Sprite>(key))
                AddAsset(key, sp[i]);
                sprite2Atlas.Add(sp[i], obj);
                if (Log) Debug.Log($"加载label为{label}的图集{location.PrimaryKey}的Sprite:{key}");
            }
        });
    }

    //加载任意类型的Object到内存中
    public IEnumerator LoadObjectByLabelAsync<T>(string label, Action<IResourceLocation, T> callback = null) where T : Object
    {
        if (Log) Debug.Log($"开始加载label为{label}的{typeof(T)}");
        float st = Time.realtimeSinceStartup;
        var locations = Addressables.LoadResourceLocationsAsync(label);
        yield return locations;
        var ops = new List<AsyncOperationHandle>(locations.Result.Count);
        foreach (var location in locations.Result)
        {
            var handle = Addressables.LoadAssetAsync<T>(location);
            handle.Completed += op =>
            {
                AddAsset(location.PrimaryKey, op.Result);
                callback?.Invoke(location, op.Result);
            };
            ops.Add(handle);
        }
        yield return Addressables.ResourceManager.CreateGenericGroupOperation(ops, true);
        if (Log) Debug.Log($"结束加载label为{label}的{typeof(T)},用时{Time.realtimeSinceStartup - st}s");
    }

    #endregion


    #region 私有函数
    string GetLoadKey<T>(string key)
    {
        return typeof(T).Name + key;
    }

    void AddAsset(string key, Object obj)
    {
        var tpe = obj.GetType();
        if (!assetCache.ContainsKey(tpe))
        {
            assetCache.Add(tpe, new Dictionary<string, Object>());
        }
        if (!assetCache[tpe].TryAdd(key, obj))
        {
            Debug.LogError($"资源重复添加:Key={key} Type={tpe}");
        }
    }

    #endregion

}
