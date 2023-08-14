PreloadManager = SingleClass("PreloadManager")

function PreloadManager:__Init()
    self.assetLoader = nil
    self.delayAssetLoader = nil
    self.preloadAssets = {}
    self.delayPreloadAssets = {}
    self.delayLoaded = false
    self.preloadObjs = {}
    self.onComplete = nil
    self:InitPreloadAssets()
end

function PreloadManager:__Delete()

end

function PreloadManager:InitPreloadAssets()
    table.insert(self.preloadAssets,{file = AssetPath.shader, type = AssetType.Object})
    table.insert(self.preloadAssets,{file = AssetPath.commonAtlas, type = AssetType.Object})
    table.insert(self.preloadAssets,{file = AssetPath.font1, type = AssetType.Object})
    table.insert(self.preloadAssets,{file = AssetPath.font2, type = AssetType.Object})
    table.insert(self.preloadAssets,{file = AssetPath.windowParent, type = AssetType.Object})
    table.insert(self.preloadAssets,{file = AssetPath.panelParent, type = AssetType.Object})
    table.insert(self.preloadAssets,{file = "ui/prefab/login/login_window.prefab", type = AssetType.Object})

    table.insert(self.delayPreloadAssets,{file = "ui/prefab/mainui/mainui_panel.prefab", type = AssetType.Object})
    table.insert(self.delayPreloadAssets,{file = AssetPath.playerGuide, type = AssetType.Object})
    table.insert(self.delayPreloadAssets,{file = AssetPath.unitFrozenMat, type = AssetType.Object})
    table.insert(self.delayPreloadAssets,{file = AssetPath.unitPetrifyingMat, type = AssetType.Object})
    table.insert(self.delayPreloadAssets,{file = AssetPath.unitFlashMat, type = AssetType.Object})
    table.insert(self.delayPreloadAssets,{file = AssetPath.unit_cubemap, type = AssetType.Object})
    table.insert(self.delayPreloadAssets,{file = AssetPath.volumeProfile, type = AssetType.Object})
    table.insert(self.delayPreloadAssets,{file = AssetPath.heroItem, type = AssetType.Object})
    table.insert(self.delayPreloadAssets,{file = AssetPath.propItem, type = AssetType.Object})
end

function PreloadManager:Load()
    self.assetLoader = AssetBatchLoader.New()
    self.assetLoader.onAssetComplete = self:ToFunc("OnAssetsComplete")
    self.assetLoader:Load(self.preloadAssets,self:ToFunc("OnComplete"))
    self:UpdateProgress()
end

function PreloadManager:DelayLoad()
    self.delayAssetLoader = AssetBatchLoader.New()
    self.delayAssetLoader:Load(self.delayPreloadAssets,self:ToFunc("DelayComplete"))
end

function PreloadManager:UpdateProgress()
    local progress = self.assetLoader:GetProgress()
    StartWindow.Instance:SetState(string.format("预加载资源:%s%s(不消耗流量)",math.ceil( progress * 100 ),"%"))
    StartWindow.Instance:SetProgress(progress)
end

function PreloadManager:OnAssetsComplete(file)
    self:UpdateProgress()
end

function PreloadManager:SetComplete(cb)
    self.onComplete = cb
end

function PreloadManager:OnComplete()
    self:UpdateProgress()
    if self.onComplete then
        self.onComplete()
    end

    self:DelayLoad()
end

function PreloadManager:DelayComplete()
    self.delayLoaded = true
    EventManager.Instance:SendEvent(EventDefine.delay_preload_complete)
end

function PreloadManager:IsDelayLoaded()
    return self.delayLoaded
end

function PreloadManager:GetAsset(file)
    if not self.preloadObjs[file] then
        local assetLoader = self.assetLoader:HasFile(file) and self.assetLoader or self.delayAssetLoader
        local obj,assetType = assetLoader:GetAsset(file)
        self.preloadObjs[file] = obj
        if assetType ~= AssetType.Prefab then
            AssetLoaderProxy.Instance:AddReference(file)
        end
    end
    return self.preloadObjs[file]
end