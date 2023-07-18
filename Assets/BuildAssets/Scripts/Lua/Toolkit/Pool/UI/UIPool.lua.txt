UIPool = Class("UIPool",ComplexPoolBase)

function UIPool:OnInit()
    self.assetLoader = AssetLoader.New()
end

function UIPool:OnDelete()
    if self.assetLoader then
        self.assetLoader:Delete()
        self.assetLoader = nil
    end
end

function UIPool:LoadAsset(path,fn,caller)
    self.assetLoader:AddAsset(path)
    self.assetLoader:LoadAsset(fn,caller)
end

function UIPool:OnBeforeGet(obj)
end

function UIPool:OnAfterGet(obj)
end

function UIPool:OnBeforeRecycle(obj)
end

function UIPool:OnAfterRecycle(obj)
end

return UIPool