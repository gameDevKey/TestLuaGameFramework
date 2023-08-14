AssetLoaderProxy = SingleClass("AssetLoaderProxy")

function AssetLoaderProxy:__Init()
    local _ = AssetLoaderDefine
    self.assetLoader = AssetLoader.Instance

    if GDefine.platform == GDefine.PlatformType.WebGLPlayer 
        or GDefine.platform == GDefine.PlatformType.IPhonePlayer then
        self.assetLoader:SetDefaultReleaseTime(10)
    else
        self.assetLoader:SetDefaultReleaseTime(30)
	end

    
    for i,v in ipairs(AssetLoaderDefine.releaseTimes) do
        self:SetReleaseTime(v.file,v.time)
    end

    self:SetMaxLoadNum(5)

    self.debugRefs = {}
end

function AssetLoaderProxy:SetMaxLoadNum(num)
    self.assetLoader:SetMaxLoadNum(num)
end

function AssetLoaderProxy:HasAsset(file)
    return self.assetLoader:HasAsset(file)
end

function AssetLoaderProxy:LoadAsset(file,callback,assetType,loadMode,priority)
    self.assetLoader:LoadAsset(file,callback,assetType,loadMode,priority)
end

function AssetLoaderProxy:AddMultipleReleaser(object)
    return object:AddComponent("AssetMultipleReleaser")
end

function AssetLoaderProxy:AddSingleReleaser(object)
    return object:AddComponent("AssetSingleReleaser")
end

function AssetLoaderProxy:GetObject(file,t)
    return self.assetLoader:GetObject(file,t)
end

function AssetLoaderProxy:CloneObject(gameObject)
    local object = GameObject.Instantiate(gameObject)
    local releasers = gameObject:GetComponentsInChildren(AssetReleaser, true)
    for i = 0, releasers.Length-1 do releasers[i]:Clone() end
    return object
end

function AssetLoaderProxy:CloneObjectByParent(gameObject,parent,instantiateInWorldSpace)
    local object = GameObject.Instantiate(gameObject,parent,instantiateInWorldSpace)
    local releaser = gameObject:GetComponentsInChildren(AssetReleaser, true)
    for i = 0, releaser.Length - 1 do releaser[i]:Clone() end
    return object
end


function AssetLoaderProxy:AddReference(file)
    if not file or file == "" then
        assert(false,"添加资源引用异常,路径为空")
    end
    self.assetLoader:AddReference(file)
    self:DebugRemove(file)
end

function AssetLoaderProxy:SubReference(file)
    if not file or file == "" then
        assert(false,"减少资源引用异常,路径为空")
    end
    
    self.assetLoader:SubReference(file)
end

function AssetLoaderProxy:SetReleaseTime(file,time)
    self.assetLoader:SetReleaseTime(file,time)
end

function AssetLoaderProxy:SetEnableUnload(flag)
    self.assetLoader:SetEnableUnload(file)
end

function AssetLoaderProxy:Update(deltaTime)
    self:CheckDebugReference()
end

function AssetLoaderProxy:CheckDebugReference()
    if not IS_EDITOR then
        return
    end

    local curFrame = GDefine.frameCount
    
    local removesFrames = {}
    local removeFiles = {}

    for file,v in pairs(self.debugRefs) do
        local count = 0
        for frame,data in pairs(v) do
            count = count + 1
            if frame ~= curFrame then
                table.insert(removesFrames,{file = file,frame = frame})
                local error = string.format("获取了资源之后,没有调用添加引用接口,检查以下获取堆栈[%s]",file)
                for i,traceback in ipairs(data.tracebacks) do
                    error = error .. "\n" .. traceback
                end
                LogError(error)
            end
        end

        if count <= 0 then
            table.insert(removeFiles,file)
        end
    end

    for _,file in ipairs(removeFiles) do
        self.debugRefs[file] = nil
    end

    for _,v in ipairs(removesFrames) do
        if self.debugRefs[v.file] then
            self.debugRefs[v.file][v.frame] = nil
        end
    end
end


function AssetLoaderProxy:DebugReference(file)
    if not IS_EDITOR then
        return
    end

    local curFrame = GDefine.frameCount

    if not self.debugRefs[file] then
        self.debugRefs[file] = {}
    end

    if not self.debugRefs[file][curFrame] then
        self.debugRefs[file][curFrame] = {}
        self.debugRefs[file][curFrame].count = 0
        self.debugRefs[file][curFrame].tracebacks = {}
    end

    self.debugRefs[file][curFrame].count = self.debugRefs[file][curFrame].count + 1
    table.insert(self.debugRefs[file][curFrame].tracebacks,debug.traceback())
end

function AssetLoaderProxy:DebugRemove(file)
    if not IS_EDITOR then
        return
    end

    local curFrame = GDefine.frameCount

    if not self.debugRefs[file] then
        return
    end

    if not self.debugRefs[file][curFrame] then
        return
    end

    local newCount = self.debugRefs[file][curFrame].count - 1
    self.debugRefs[file][curFrame].count = newCount
    if newCount <= 0 then
        self.debugRefs[file][curFrame] = nil
    end
end

