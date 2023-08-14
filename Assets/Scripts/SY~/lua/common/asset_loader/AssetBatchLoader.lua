AssetBatchLoader = BaseClass("AssetBatchLoader")

function AssetBatchLoader:__Init()
    self.delFlag = false
    self.loadAssets = {}
    self.assetIndexs = {}
    self.assetFlagFiles = {}
    self.isLoading = false
    self.loadedCallback = nil
    self.isCancel = false
    self.loadBeginTime = 0.0
    self.loadNum = 0
    self.loadCompleteNum = 0
    --self.debug = debug.traceback()
    self.onAssetComplete = nil
    self.args = nil
end

function AssetBatchLoader:__Delete()
    if not self.delFlag then
        assert(false, "切勿直接调用Delete删除资源加载器,需要改用Destroy")
    end

    for _, data in ipairs(self.loadAssets) do
        AssetLoaderProxy.Instance:SubReference(data.file)
    end
end

function AssetBatchLoader:Load(assetList,onComplete,args)
    if self.isLoading then 
        return 
    end

    if not onComplete then
        assert(false, "非法资源加载回调")
    end

    self.isLoading = true
    self.args = args
    self.onComplete = onComplete

    for i,v in ipairs(assetList) do
        if not self.assetIndexs[v.file] then
            if not v.file or v.file == "" then
                assert(false,"资源路径为空")
            end
            
            if not v.type then
                assert(false, string.format("资源类型为空[%s]",v.file))
            end

            self.assetIndexs[v.file] = i
            if v.flag then 
                self.assetFlagFiles[v.flag] = v.file 
            end

            local loadInfo = {}
            loadInfo.asset = nil
            loadInfo.file = v.file
            loadInfo.type = v.type
            loadInfo.loadMode = v.loadMode or AssetLoadMode.FAsyncASync
            loadInfo.priority = v.priority or AssetPriority.Low
            table.insert(self.loadAssets,loadInfo)
        end
    end

    self.loadNum = #self.loadAssets

    for i,v in ipairs(self.loadAssets) do
        AssetLoaderProxy.Instance:LoadAsset(v.file,self:ToFunc("OnAssetLoaded"),v.type,v.loadMode,v.priority)
    end

    if self.loadNum <= 0 then
        self.isLoading = false
        self:LoadComplete()
    end
end

function AssetBatchLoader:GetAsset(file,parent,instantiateInWorldSpace)
    if self.isLoading then 
        LogErrorf("资源正在加载中[%s]",file)
        return 
    end

    local index = self.assetIndexs[file]
    if not index then 
        LogErrorf("资源不存在[%s]",file)
        return
    end

    local assetData = self.loadAssets[index]
    local assetObj = assetData.asset
    assetData.asset = nil

    if not assetObj then 
        LogErrorf("资源已被取出[%s]",file) 
        return
    end

    if assetData.type == AssetType.Prefab then
        return self:CreateObject(assetObj,file,parent,instantiateInWorldSpace),assetData.type
    else
        AssetLoaderProxy.Instance:DebugReference(file)
        return assetObj,assetData.type
    end
end

function AssetBatchLoader:GetAssetByIndex(index,parent,instantiateInWorldSpace)
    local assetData = self.loadAssets[index]
    if not assetData then
        LogErrorf("不存在index索引资源[%s]",tostring(index))
        return
    end
    return self:GetAsset(assetData.file,parent,instantiateInWorldSpace),assetData.file
end

function AssetBatchLoader:GetAssetByFlag(flag,parent,instantiateInWorldSpace)
    local file = self.assetFlagFiles[flag]
    if not file then
        LogErrorf("不存在flag索引资源[%s]",flag)
        return
    end
    return self:GetAsset(file,parent,instantiateInWorldSpace),file
end

function AssetBatchLoader:GetFile(index)
    return self.loadAssets[index].file
end

function AssetBatchLoader:HasFile(file)
    return self.assetIndexs[file] ~= nil
end

function AssetBatchLoader:CreateObject(asset,file,parent,instantiateInWorldSpace)
    local object = nil

    if not instantiateInWorldSpace then
        object = GameObject.Instantiate(asset,parent)
    else
        object = GameObject.Instantiate(asset,parent,instantiateInWorldSpace)
    end

    self:CheckAssetReleaser(object,file)

    local releaser = object:AddComponent(AssetReleaser)
    releaser:Add(file)
    AssetLoaderProxy.Instance:AddReference(file)
    return object
end

function AssetBatchLoader:CheckAssetReleaser(object,file)
    if not IS_EDITOR then
        return
    end

    local releasers = object:GetComponentsInChildren(AssetReleaser, true)
    if releasers.Length > 0 then
        assert(false,string.format("预设禁止手动添加AssetReleaser脚本[%s]",file))
    end
end

function AssetBatchLoader:OnAssetLoaded(asset,file)
    local index = self.assetIndexs[file]

    self.loadAssets[index].asset = asset

    self.loadCompleteNum = self.loadCompleteNum + 1

    if not self.isCancel and self.onAssetComplete then
        self.onAssetComplete(file)
    end

    if self.loadCompleteNum < self.loadNum then 
        return
    end

    self.isLoading = false
    if self.isCancel then
        self:Destroy()
    else
        self:LoadComplete()
    end
end

function AssetBatchLoader:LoadComplete()
    self.onComplete(self.args)
end

function AssetBatchLoader:Destroy()
    if self.isLoading then 
        self.isCancel = true
    else
        self.delFlag = true
        self:Delete()
    end
end

function AssetBatchLoader:IsComplete()
    return self.loadCompleteNum >= self.loadNum
end

function AssetBatchLoader:GetProgress()
    if self.loadNum == 0 then
        return 1
    else
        return self.loadCompleteNum / self.loadNum
    end
end