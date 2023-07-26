CacheUI = Class("CacheUI",CacheItemBase)

function CacheUI:OnInit()
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
        --加载UI完毕，实例化UI，初始化并赋值到界面
        if not self.gameObject then
            self.gameObject = UnityUtil.Instantiate(self.asset)
        end
        self.gameObject:SetActive(true)
        self.transform = self.gameObject.transform
        self.transform:SetParent(UIManager.Instance.uiRoot.transform)
        RectTransformExt.Reset(self.transform)
        local uiScript = self.data.args.ui
        if uiScript then
            uiScript:SetupViewAsset(self.gameObject)
            uiScript:Enter(self.data.args)
        end
        if self.data.callback then
            self.data.callback(self.data.args,self.gameObject)
        end
    else
        if not self.data.path then
            PrintError("UI加载前必须传入Prefab或者Path",self.data)
            return
        end
        AssetLoaderUtil.LoadGameObjectAsync(self.data.path, self:ToFunc("onAssetLoaded"))
    end
end

function CacheUI:onAssetLoaded(asset)
    if not asset then
        PrintError("UI加载失败",self.data)
        return
    end
    self.asset = asset
    self:OnUse()
end

function CacheUI:OnRecycle()
    if self.gameObject then
        self.gameObject.transform:SetParent(UIManager.Instance.cacheNode.transform)
    end
end

return CacheUI