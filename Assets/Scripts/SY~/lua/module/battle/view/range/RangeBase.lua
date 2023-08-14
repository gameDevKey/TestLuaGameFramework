RangeBase = BaseClass("RangeBase")

function RangeBase:__Init()
    self.gameObject = BaseUtils.GetEmptyObject()
    self.transform = self.gameObject.transform

    self.rangeType = nil
    self.pos = nil
    self.angle = nil
    self.flag = true
    self.rangeInfo = nil

    self.rangeObj = nil
    self.rangeMat = nil

    self.assetLoader = nil

    self.color = nil
    self.intensity = nil

    self.offsetY = 0
end

function RangeBase:__Delete()
    self:RemoveAssetLoader()

    if self.gameObject then
        PoolManager.Instance:Push(PoolType.object,PoolDefine.PoolKey.empty_object,self.gameObject)
        self.gameObject = nil
    end
end

function RangeBase:SetParent(parent)
    self.transform:SetParent(parent)
end

function RangeBase:SetOffsetY(offsetY)
    self.offsetY = offsetY
end

function RangeBase:SetActive(flag)
    if self.flag ~= flag then 
        self.flag = flag
        self.gameObject:SetActive(flag)
    end
end

function RangeBase:SetRange(range)
    self.range = range
    self:OnRange()
end

function RangeBase:CreateRange()
    self:OnCreate()
end

function RangeBase:SetTransform(pos,dir)
    self.pos = pos
    self.dir = dir
    self:OnTransform()
end

function RangeBase:OnTransform()
    self.transform:SetLocalPosition(self.pos.x,self.pos.y,self.pos.z)
    if self.dir.x ~= 0 or self.dir.y ~= 0 or self.dir.z ~= 0 then
        self.transform.forward = self.dir
    end
end

function RangeBase:OnCreate()
end

function RangeBase:OnRange()
end

function RangeBase:RemoveAssetLoader()
    if self.assetLoader then 
        self.assetLoader:Destroy()
        self.assetLoader = nil 
    end
end

function RangeBase:SetColor(color,intensity)
    self.color = color
    self.intensity = intensity
    if self.rangeMat then 
        self.rangeMat:SetFloat("_Intensity",self.intensity or 1.0)
        self.rangeMat:EnableKeyword("_COLORENABLED_ON")
        self.rangeMat:SetColor("_Color",ColorUtils.HexToColor(self.color))
    end
end

function RangeBase:RangeLoaded()
    self.rangeObj.transform:SetLocalPosition(0,self.offsetY,0)
    if self.color then
        self:SetColor(self.color,self.intensity)
    else
        self:ResetColor()
    end
end

function RangeBase:ResetColor()
    self.color = nil
    self.intensity = nil
    if self.rangeMat then
        self.rangeMat:SetFloat("_Intensity",1.0)
        self.rangeMat:DisableKeyword("_COLORENABLED_ON")
    end
end

function RangeBase.Create(rangeType)
    local range = nil
    if rangeType == BattleDefine.RangeType.circle then
        range = CircleRange.New()
    elseif rangeType == BattleDefine.RangeType.aabb then
        range = AABBRectRange.New()
    elseif rangeType == BattleDefine.RangeType.obb then
        range = OBBRectRange.New()
    elseif rangeType == BattleDefine.RangeType.full then
        range = FullRange.New()
    end
    return range
end