AssetLoader = Class("AssetLoader")

function AssetLoader:OnInit()
    self.toLoads = {}
    self.results = {}
    self.isDone = false
end

function AssetLoader:OnDelete()
    if self.finishCallback then
        self.finishCallback:Delete()
        self.finishCallback = nil
    end
end

function AssetLoader:LoadAsset(fn,caller)
    self.finishCallback = CallObject.New(fn,caller)

    if self:IsDone() then
        self:LoadDone()
        return
    end

    --测试----
    if TEST_ENV then
        self:TestLoadFunc()
    end
end

function AssetLoader:TestLoadFunc()
    for _, data in ipairs(self.toLoads) do
        self.results[data.path] = UnityUtil.LoadResources(data.path)
        if data.callObject then
            data.callObject:Invoke(self.results[data.path],data.path)
        end
    end
    self:LoadDone()
end

function AssetLoader:LoadDone()
    self.isDone = true
    self.toLoads = {}
    if self.finishCallback then
        self.finishCallback:Invoke(self.results)
    end
end

function AssetLoader:AddAsset(path, callObject)
    self.isDone = false
    table.insert(self.toLoads, {
        path = path,
        callObject = callObject
    })
end

function AssetLoader:IsDone()
    return self.isDone
end

return AssetLoader