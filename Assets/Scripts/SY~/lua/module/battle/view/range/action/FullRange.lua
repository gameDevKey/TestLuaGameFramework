FullRange = BaseClass("FullRange",RangeBase)
FullRange.prefabFile = "mixed/range/aabb_rect.prefab"

function FullRange:__init()
    self.rangeType = RangeDefine.RangeType.full
    self.texPath = nil
    self.poolKey = nil
end

function FullRange:__delete()
    if self.rangeObj then
        PoolManager.Instance:Push(PoolType.object,self.poolKey,self.rangeObj)
        self.rangeObj = nil
    end
end

function FullRange:OnCreate()
    self.poolKey = string.format("full_range_%s",tostring(self.range.tex))

    self.rangeObj = PoolManager.Instance:Pop(PoolType.object,self.poolKey)
    if self.rangeObj then
        self.rangeObj.transform:SetParent(self.transform)
        self.rangeObj.transform:Reset()

        self.rangeMat = self.rangeObj:GetComponentInChildren(Renderer).material

        BaseUtils.ChangeLayers(self.rangeObj,GDefine.Layer.layer6)

        self:RangeLoaded()
    else
        local assetList = {}
        table.insert(assetList,{file = FullRange.prefabFile,type = AssetType.Prefab })
        if self.range.tex then
            self.texPath = string.format("mixed/range/tex/%s.png",self.range.tex)
            table.insert(assetList,{file = self.texPath,type = AssetType.Object })
        end
        self.assetLoader = AssetBatchLoader.New()
        self.assetLoader:Load(assetList,self:ToFunc("AssetLoaded"))
    end
end

function FullRange:AssetLoaded()
    self.rangeObj = self.assetLoader:GetAsset(FullRange.prefabFile)
    self.rangeObj.transform:SetParent(self.transform)
    self.rangeObj.transform:Reset()

    self.rangeMat = self.rangeObj:GetComponentInChildren(Renderer).material

    local assetReleaser = self.rangeObj:GetComponent(AssetReleaser)

    if self.texPath then
        self.rangeMat.mainTexture =  self.assetLoader:GetAsset(self.texPath)
        assetReleaser:Add(self.texPath)
        AssetLoaderProxy.Instance:AddReference(self.texPath)
    end

    BaseUtils.ChangeLayers(self.rangeObj,GDefine.Layer.layer6)

    self:RangeLoaded()

    self:RemoveAssetLoader()
end

function FullRange:OnRange()
    self.transform:SetLocalScale(100,1,100)
end

function FullRange:OnTransform()
    self.transform:SetLocalPosition(0,self.offsetY,0)
    self.transform:SetLocalEulerAngles(0,0,0)
end