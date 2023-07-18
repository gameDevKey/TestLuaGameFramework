CacheUI = Class("CacheUI",CacheItemBase)

function CacheUI:OnInit()
end

function CacheUI:onAssetLoaded(asset)
    self.asset = asset[self.data.path]
    self:OnUse()
end

function CacheUI:OnDelete()
    if self.gameObject then
        UnityUtil.DestroyGameObject(self.gameObject)
        self.gameObject = nil
    end
    self.asset = nil
end

--[[
    data = { callback, args, path/prefab }
]]--
function CacheUI:OnUse()
    self.asset = self.asset or self.data.prefab
    if self.asset then
        if not self.gameObject then
            self.gameObject = UnityUtil.Instantiate(self.asset)
        end
        self.gameObject:SetActive(true) --
        self.transform = self.gameObject.transform
        self.transform:SetParent(UIManager.Instance.uiRoot.transform)
        RectTransformExt.Reset(self.transform)
        if self.data.callback then
            self.data.callback(self.data.args,self.gameObject)
        end
    else
        self:GetPool():LoadAsset(self.data.path, self:ToFunc("onAssetLoaded"))
    end
end

function CacheUI:OnRecycle()
    if self.gameObject then
        self.gameObject.transform:SetParent(UIManager.Instance.cacheNode.transform)
    end
end

return CacheUI