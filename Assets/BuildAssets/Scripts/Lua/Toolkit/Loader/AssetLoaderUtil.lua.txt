AssetLoaderUtil = StaticClass("AssetLoaderUtil")

function AssetLoaderUtil.LoadGameObjectAsync(path,func)
    CS.GameAssetLoader.Instance:LoadGameObjectAsync(path,func)
end

function AssetLoaderUtil.LoadTextAsync(path,func)
    CS.GameAssetLoader.Instance:LoadTextAsync(path,func)
end

return AssetLoaderUtil