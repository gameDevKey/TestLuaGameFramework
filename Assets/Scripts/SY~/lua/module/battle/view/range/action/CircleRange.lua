CircleRange = BaseClass("CircleRange",RangeBase)
CircleRange.prefabFile = "mixed/range/circle.prefab"

function CircleRange:__Init()
    self.rangeType = RangeDefine.RangeType.circle
    self.texPath = nil
    self.poolKey = nil
end

function CircleRange:__Delete()
    if self.rangeObj then
        PoolManager.Instance:Push(PoolType.object,self.poolKey,self.rangeObj)
        self.rangeObj = nil
    end
end

function CircleRange:OnCreate()
    self.poolKey = string.format("circle_range_%s",self.range.tex)

    self.rangeObj = PoolManager.Instance:Pop(PoolType.object,self.poolKey)
    if self.rangeObj then
        self.rangeObj.transform:SetParent(self.transform)
        self.rangeObj.transform:Reset()

        self.rangeMat = self.rangeObj:GetComponentInChildren(Renderer).material

        BaseUtils.ChangeLayers(self.rangeObj,GDefine.Layer.layer6)

        self:RangeLoaded()
    else
        self.texPath = string.format("mixed/range/tex/%s.png",self.range.tex)
        local assetList = {}
        table.insert(assetList,{file = CircleRange.prefabFile,type = AssetType.Prefab })
        table.insert(assetList,{file = self.texPath,type = AssetType.Object })
        self.assetLoader = AssetBatchLoader.New()
        self.assetLoader:Load(assetList,self:ToFunc("AssetLoaded"))
    end
end

function CircleRange:AssetLoaded()
    self.rangeObj = self.assetLoader:GetAsset(CircleRange.prefabFile)
    self.rangeObj.transform:SetParent(self.transform)
    self.rangeObj.transform:Reset()

    self.rangeMat = self.rangeObj:GetComponentInChildren(Renderer).material

    local assetReleaser = self.rangeObj:GetComponent(AssetReleaser)

    self.rangeMat.mainTexture =  self.assetLoader:GetAsset(self.texPath)
    assetReleaser:Add(self.texPath)
    AssetLoaderProxy.Instance:AddReference(self.texPath)

    BaseUtils.ChangeLayers(self.rangeObj,GDefine.Layer.layer6)

    self:RangeLoaded()

    self:RemoveAssetLoader()
end

function CircleRange:OnRange()
    local radius = self.range.radius * 0.001 * 2
    self.transform:SetLocalScale(radius,1,radius)
end

function CircleRange:OnTransform()
    if self.range.offset and self.range.offset ~= 0 then
        local newPos = Vector3(self.dir.x,0,self.dir.z)
        newPos = newPos * (self.range.offset * 0.001)
        self.transform:SetLocalPosition(self.pos.x + newPos.x,self.pos.y + self.offsetY,self.pos.z + newPos.z)
    else
        self.transform:SetLocalPosition(self.pos.x,self.pos.y + self.offsetY,self.pos.z)
    end

    if self.range.dir == 1 then
        self.transform.forward = self.dir
    else
        self.transform:SetLocalEulerAngles(0,0,0)
    end
end