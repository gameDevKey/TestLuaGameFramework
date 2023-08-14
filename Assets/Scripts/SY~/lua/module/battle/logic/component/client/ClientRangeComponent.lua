ClientRangeComponent = BaseClass("ClientRangeComponent",SECBClientComponent)

function ClientRangeComponent:__Init()
    self.rangeInfos = {}
end

function ClientRangeComponent:__Delete()
    for k, v in pairs(self.rangeInfos) do
        v.range:Delete()
    end
end

function ClientRangeComponent:OnCreate()
    
end

function ClientRangeComponent:OnInit()
    self.CollistionComponent = self.clientEntity.entity.CollistionComponent

    if DEBUG_COLLISTION_RANGE then
        self:ActiveCollistionRange(true)
    end

    if DEBUG_ATK_RANGE then
        self:ActiveAtkRange(true)
    end
end

function ClientRangeComponent:ActiveCollistionRange(flag)
    if flag then
        local collistionRange = {}
        collistionRange.type = BattleDefine.RangeType.circle
        collistionRange.radius = self.CollistionComponent:GetRadius()
        collistionRange.tex = 2003
        if not self.rangeInfos["collistion_range"] then
            self.rangeInfos["collistion_range"] = {}
            self.rangeInfos["collistion_range"].range = RangeBase.Create(BattleDefine.RangeType.circle)
            self.rangeInfos["collistion_range"].range:SetOffsetY(0.02)
            self.rangeInfos["collistion_range"].range:SetRange(collistionRange)
            self.rangeInfos["collistion_range"].range:CreateRange()
        end

        self.rangeInfos["collistion_range"].range:SetParent(self.clientEntity.ClientTransformComponent.transform)
        self.rangeInfos["collistion_range"].range:SetRange(collistionRange)
        self.rangeInfos["collistion_range"].range:SetTransform(Vector3(0,0,0),Vector3(0,0,1))
        self.rangeInfos["collistion_range"].range:SetActive(true)
    else
        if self.rangeInfos["collistion_range"] then
            self.rangeInfos["collistion_range"].range:SetActive(false)
        end
    end
end

function ClientRangeComponent:ActiveAtkRange(flag)
    if flag then
        local atkRange = {}
        for k,v in pairs(self.clientEntity.entity.ObjectDataComponent.unitConf.atk_range) do
            atkRange[k] = v
        end
        self:SetDebugRnageTex(atkRange)
    
        if not self.rangeInfos["atk_range"] then
            self.rangeInfos["atk_range"] = {}
            self.rangeInfos["atk_range"].range = RangeBase.Create(atkRange.type)
            self.rangeInfos["atk_range"].range:SetOffsetY(0.03)
            self.rangeInfos["atk_range"].range:SetRange(atkRange)
            self.rangeInfos["atk_range"].range:CreateRange()
        end

        self.rangeInfos["atk_range"].range:SetParent(self.clientEntity.ClientTransformComponent.transform)
        self.rangeInfos["atk_range"].range:SetRange(atkRange)
        self.rangeInfos["atk_range"].range:SetTransform(Vector3(0,0,0),Vector3(0,0,1))
        self.rangeInfos["atk_range"].range:SetActive(true)
    else
        if self.rangeInfos["atk_range"] then
            self.rangeInfos["atk_range"].range:SetActive(false)
        end
    end
end

function ClientRangeComponent:AddSkillAtkRange(skill,transInfo)
    local key = "skill_atk_range_" .. skill.uid .. "_" .. skill.relUid
    

    local atkRange = skill:GetAtkRange()
    local tempAtkRange = {}
    for k,v in pairs(atkRange) do
        tempAtkRange[k] = v
    end
    self:SetDebugRnageTex(tempAtkRange)

    self.rangeInfos[key] = {}
    self.rangeInfos[key].range = RangeBase.Create(tempAtkRange.type)
    self.rangeInfos[key].range:SetOffsetY(0.04)
    self.rangeInfos[key].range:SetRange(tempAtkRange)
    self.rangeInfos[key].range:CreateRange()

    self.rangeInfos[key].range:SetParent(BattleDefine.nodeObjs["mixed"])
    self.rangeInfos[key].range:SetTransform(Vector3(transInfo.posX * FPFloat.PrecisionFactor,0,transInfo.posZ* FPFloat.PrecisionFactor)
        ,Vector3(transInfo.dirX * FPFloat.PrecisionFactor,0,transInfo.dirZ * FPFloat.PrecisionFactor))
    
    self.rangeInfos[key].range:SetActive(true)
    
    self.rangeInfos[key].timer = TimerManager.Instance:AddTimer(1,1,self:ToFunc("RangeTimer"),key)
end

function ClientRangeComponent:RangeTimer(args,isDone,runNum,uid)
    if self.rangeInfos[uid] then
        self.rangeInfos[uid].timer = nil
        self.rangeInfos[uid].range:Delete()
        self.rangeInfos[uid] = nil
    end
end

function ClientRangeComponent:SetDebugRnageTex(range)
    if range.type == RangeDefine.RangeType.circle then
        range.tex = 1001
    elseif range.type == RangeDefine.RangeType.full then
        range.tex = 2006
    elseif range.type == RangeDefine.RangeType.aabb 
        or range.type == RangeDefine.RangeType.obb then
        range.tex = 2006
    end
end