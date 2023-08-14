AttrComponent = BaseClass("AttrComponent",SECBComponent)

function AttrComponent:__Init()
    self.srcAttrs = nil
    self.attrs = {}
    self.attrChangeListeners = {}
    self.energyTime = 0
end

function AttrComponent:__Delete()
    
end

function AttrComponent:OnInit()
    self:InitAttr(self.entity.ObjectDataComponent.objectData.attr_list)
end

function AttrComponent:InitAttrByObjectData()

end

function AttrComponent:InitAttr(attrList)
    self.srcAttrs = attrList

    for i,v in ipairs(attrList) do
        self.attrs[v.attr_id] = v.attr_val
    end

    if not self.attrs[BattleDefine.Attr.hp] then
        self.attrs[BattleDefine.Attr.hp] = self.attrs[GDefine.Attr.max_hp]
    end

    if not self.attrs[BattleDefine.Attr.energy] and self.attrs[GDefine.Attr.max_energy] then
        self.attrs[BattleDefine.Attr.energy] = 0
    end

    for attrId,_ in pairs(self.attrs) do
        if not BattleDefine.NotAddAttr[attrId] then
            self.attrs[attrId * 1000000] = 0
        end
    end
end

function AttrComponent:UpdateSrcAttr(attrList)
    self.srcAttrs = attrList

    local lastMaxHp = self.attrs[GDefine.Attr.max_hp]

    for i,v in ipairs(attrList) do
        self:SetValue(v.attr_id,v.attr_val)
    end

    local hp = self.attrs[BattleDefine.Attr.hp] + (self.attrs[GDefine.Attr.max_hp] - lastMaxHp)
    self:SetValue(BattleDefine.Attr.hp, hp)
end

function AttrComponent:GetRefAttr()
    return self.attrs
end

function AttrComponent:AddValue(attrType,val)
    if attrType == BattleDefine.Attr.hp then
		local maxHp = self:GetValue(GDefine.Attr.max_hp)
		local curHp = self:GetValue(BattleDefine.Attr.hp)
        if curHp + val > maxHp then
            val = maxHp - curHp
        elseif curHp + val < 0 then
            val = -curHp
        end
    elseif attrType == BattleDefine.Attr.energy then
        local maxEnergy = self:GetValue(GDefine.Attr.max_energy)
		local curEnergy = self:GetValue(BattleDefine.Attr.energy)
        if curEnergy + val > maxEnergy then
            val = maxEnergy - curEnergy
        elseif curEnergy + val < 0 then
            val = -curEnergy
        end
        if val > 0 and self.entity.BuffComponent:HasBuffState(BattleDefine.BuffState.ban_energy_add) then
            return
        end
	end
    --
    local addAttrType = attrType * 1000000
	if self.attrs[addAttrType] then
		local attrValue = self:GetAddValue(attrType)
		attrValue = attrValue + val
		self:SetValue(addAttrType,attrValue)
	else
		local attrValue = self:GetBaseValue(attrType)
		attrValue = attrValue + val
		self:SetValue(attrType,attrValue)
	end
end

function AttrComponent:SetValue(attrType,val)
    self.attrs[attrType] = val
    self:ChangeAttr(attrType)
end

function AttrComponent:GetValue(attrType)
    local baseValue = self:GetBaseValue(attrType)
	local addValue = self:GetAddValue(attrType)
	local value = baseValue + addValue

	if attrType == GDefine.Attr.atk_speed and value < 3000 then
		value = 3000
	elseif attrType == GDefine.Attr.atk_speed and value > 50000 then
		value = 50000
    end

	return value
end

function AttrComponent:GetBaseValue(attrType)
    return self.attrs[attrType] or 0
end

function AttrComponent:GetAddValue(attrType)
    return self.attrs[attrType * 1000000] or 0
end

function AttrComponent.GetRefValue(attrs,attrType)
    local baseValue = AttrComponent.GetRefBaseValue(attrs,attrType)
	local addValue = AttrComponent.GetRefAddValue(attrs,attrType)
	local value = baseValue + addValue

	if attrType == GDefine.Attr.atk_speed and value < 3000 then
		value = 3000
	elseif attrType == GDefine.Attr.atk_speed and value > 50000 then
		value = 50000
    end

	return value
end

function AttrComponent.GetRefBaseValue(attrs,attrType)
    return attrs[attrType]
end

function AttrComponent.GetRefAddValue(attrs,attrType)
    return attrs[attrType * 1000000] or 0
end

function AttrComponent:GetHpRatio()
    local maxHp = self:GetValue(GDefine.Attr.max_hp)
	local hp = self:GetValue(BattleDefine.Attr.hp)
    return FPFloat.Div_ii(hp,maxHp)
end


function AttrComponent:OnUpdate()
    if self:GetValue(GDefine.Attr.max_energy) > 0 and self:GetValue(GDefine.Attr.energy_add_rate) > 0 then
        local maxEnergy = self:GetValue(GDefine.Attr.max_energy)
		local curEnergy = self:GetValue(BattleDefine.Attr.energy)
        local energyAddRate = FPMath.Divide(self:GetValue(GDefine.Attr.energy_add_rate),10)

        self.energyTime = self.energyTime + self.world.opts.frameDeltaTime
        if self.energyTime > 100 then
            local addNum = FPMath.Divide(self.energyTime - (self.energyTime % 100),100)
            local addRate = addNum * energyAddRate
            local addEnergy = FPMath.Divide(maxEnergy * addRate,BattleDefine.AttrRatio)

            if addEnergy > 0 then
                self.energyTime = self.energyTime - addNum * 100
                if curEnergy < maxEnergy then
                    self:AddValue(BattleDefine.Attr.energy,addEnergy)
                end
            end
        end
    end
end

function AttrComponent:AddChangeListener(attrType,func)
    if not self.attrChangeListeners[attrType] then
        self.attrChangeListeners[attrType] = {}
    end
    table.insert(self.attrChangeListeners[attrType],func)
end

function AttrComponent:ChangeAttr(attrType)
    if self.attrChangeListeners[attrType] then
        for i,func in ipairs(self.attrChangeListeners[attrType]) do
            func(attrType)
        end
    end
end