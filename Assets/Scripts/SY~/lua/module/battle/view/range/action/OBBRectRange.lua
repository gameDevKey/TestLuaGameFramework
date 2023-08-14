OBBRectRange = BaseClass("OBBRectRange",RangeBase)
OBBRectRange.prefabFile = "mixed/range/obb_rect.prefab"

function OBBRectRange:__init()
    self.rangeType = RangeDefine.RangeType.obb
    self.texPath = nil
    self.poolKey = nil
end

function OBBRectRange:__delete()
    if self.rangeObj then
        PoolManager.Instance:Push(PoolType.object,self.poolKey,self.rangeObj)
        self.rangeObj = nil
    end
end

function OBBRectRange:OnCreate()
    self.poolKey = string.format("obb_range_%s",tostring(self.range.tex))

    self.rangeObj = PoolManager.Instance:Pop(PoolType.object,self.poolKey)
    if self.rangeObj then
        self.rangeObj.transform:SetParent(self.transform)
        self.rangeObj.transform:Reset()

        self.rangeMat = self.rangeObj:GetComponentInChildren(Renderer).material

        BaseUtils.ChangeLayers(self.rangeObj,GDefine.Layer.layer6)

        self:RangeLoaded()
    else
        local assetList = {}
        table.insert(assetList,{file = OBBRectRange.prefabFile,type = AssetType.Prefab })
        if self.range.tex then
            self.texPath = string.format("mixed/range/tex/%s.png",self.range.tex)
            table.insert(assetList,{file = self.texPath,type = AssetType.Object })
        end
        --
        self.assetLoader = AssetBatchLoader.New()
        self.assetLoader:Load(assetList,self:ToFunc("AssetLoaded"))
    end
end

function OBBRectRange:AssetLoaded()
    self.rangeObj = self.assetLoader:GetAsset(OBBRectRange.prefabFile)
    self.rangeObj.transform:SetParent(self.transform)
    self.rangeObj.transform:Reset()

    self.rangeMat = self.rangeObj:GetComponentInChildren(Renderer).material

    local assetReleaser = self.rangeObj:GetComponent(AssetReleaser)

    if self.texPath then
        self.rangeMat.mainTexture = self.assetLoader:GetAsset(self.texPath)
        assetReleaser:Add(self.texPath)
        AssetLoaderProxy.Instance:AddReference(self.texPath)
    end

    BaseUtils.ChangeLayers(self.rangeObj,GDefine.Layer.layer6)

    self:RangeLoaded()

    self:RemoveAssetLoader()
end

function OBBRectRange:OnRange()
    self.transform:SetLocalScale(self.range.width * 0.001,1,self.range.height * 0.001)
end

function OBBRectRange:OnTransform()
    if self.range.offset and self.range.offset ~= 0 then
        local newPos = Vector3(self.dir.x,0,self.dir.z)
        newPos = newPos * (self.range.offset * 0.001)
        self.transform:SetLocalPosition(self.pos.x + newPos.x,self.pos.y + self.offsetY,self.pos.z + newPos.z)
    else
        self.transform:SetLocalPosition(self.pos.x,self.pos.y + self.offsetY,self.pos.z)
    end
    self.transform.forward = self.dir
end