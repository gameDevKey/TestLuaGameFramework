AssetLoaderDefine = StaticClass("AssetLoaderDefine")

-- 资源类型
AssetType =
{
    Prefab = typeof(GameObject),
    Object = typeof(Object),
    Sprite = typeof(Sprite),
    AudioClip = typeof(AudioClip),
}

-- 资源加载类型
-- 加载类型
AssetLoadMode =
{
    BothAsync = 1, --全异步
    BothSync = 2, --全同步
    PureSync = 3, --全同步，不受加载数量限制
    FSyncAAsync = 4, --读取文件同步，读取资源异步
    FAsyncASync = 5, --读取文件异步，读取资源同步
}

AssetPriority = 
{
    Low = 0,
    Medium = 500,
    High = 1000,
}


AssetLoaderDefine.DefaultReleaseTime = 30

AssetLoaderDefine.releaseTimes = 
{
    {file = AssetPath.font1,time = 0},
    {file = AssetPath.font2,time = 0},
    {file = AssetPath.commonAtlas,time = 0},
    {file = AssetPath.shader,time = 0},
}

AssetLoaderDefine.UITextureStartsWith = "ui/texture"