CheckCondPlugin = BaseClass("CheckCondPlugin",SECBPlugin)
CheckCondPlugin.NAME = "CheckCond"

function CheckCondPlugin:__Init()
    self.condInfo =
    {
        ["几率"] = {fn = "Prob",needEntity = false},
        ["满血"] = {fn = "MaxHp",needEntity = true},
        ["未满血"] = {fn = "NotMaxHp",needEntity = true},
        ["存在Buff"] = {fn = "ExistBuff",needEntity = true},
        ["不存在Buff"] = {fn = "NotExistBuff",needEntity = true},
        ["主堡"] = {fn = "HomeEntity",needEntity = true},
        ["非主堡"] = {fn = "NotHomeEntity",needEntity = true},
        ["生命类型"] = {fn = "LifeType",needEntity = true},
        ["非生命类型"] = {fn = "NotLifeType",needEntity = true},
        ["范围内存在单位"] = {fn = "RangeExistUnit",needEntity = true},
        ["范围内不存在单位"] = {fn = "NotRangeExistUnit",needEntity = true},
        ["朝向基本一致"] = {fn ="BasicallySameForward",needEntity = true},
        ["属性值"] = {fn ="CheckAttrVal",needEntity = true},
    }
end

function CheckCondPlugin:__Delete()
    
end

function CheckCondPlugin:IsCond(entityUid,conds,args)
    local entity = self.world.EntitySystem:GetEntity(entityUid)
    for _,v in ipairs(conds) do
        local flag = false
        for _,param in ipairs(v) do
            local condInfo = self.condInfo[param.type]
            if not condInfo then
                assert(false,string.format("未知的条件类型[%s][proxy:nil]",tostring(param.type)))
            elseif (not condInfo.needEntity or entity ~= nil) 
                and self[condInfo.fn](self,entity,param,args) then
                flag = true
                break
            end
        end

        if not flag then
            return false
        end
    end
    return true
end

function CheckCondPlugin:Prob(entity,param)
    if param.prob >= BattleDefine.AttrRatio then
        return true
    elseif param.prob <= 0 then
        return false
    else
        local probVal = param.prob
        local value = self.world.BattleRandomSystem:Random(1,BattleDefine.AttrRatio)
        return value <= probVal
    end
end

function CheckCondPlugin:CanRelSkill(entity,param)
end

function CheckCondPlugin:MaxHp(entity,param)
	local maxHp = entity.AttrComponent:GetValue(GDefine.Attr.max_hp)
	local hp = entity.AttrComponent:GetValue(BattleDefine.Attr.hp)
	return hp >= maxHp
end

function CheckCondPlugin:NotMaxHp(entity,param)
	return not self:MaxHp(entity,param)
end

function CheckCondPlugin:ExistBuff(entity,param)
    if param.buffId ~= 0 then
        local buff = entity.BuffComponent:GetBuffById(param.buffId)
        if not buff then
            return false
        end
        return self:CheckBuff(buff,param)
    end

    for iter in entity.BuffComponent.buffList:Items() do
        local buff = entity.BuffComponent:GetBuffByUid(iter.value)
        if self:CheckBuff(buff,param) then
            return true
        end
    end

    return false
end

function CheckCondPlugin:CheckBuff(buff,param)
    if param.buffId > 0 and buff.conf.id ~= param.buffId then
        return false
    elseif param.buffId == -1 then
        return true
    end

    if param.kind ~= 0 and buff.conf.kind ~= param.kind then
        return false
    end

    if param.resultType ~= 0 and buff.conf.result_type ~= param.resultType then
        return false
    end

    if param.tag ~= 0 and buff.conf.tag ~= param.tag then
        return false
    end

    if param.overlay ~= 0 and param.overlayOp then
        if param.overlayOp == '<' and buff.overlay >= param.overlay then
            return false
        elseif param.overlayOp == '<=' and buff.overlay > param.overlay then
            return false
        elseif param.overlayOp == '=' and buff.overlay ~= param.overlay then
            return false
        elseif param.overlayOp == '>' and buff.overlay <= param.overlay then
            return false
        elseif param.overlayOp == '>=' and buff.overlay < param.overlay then
            return false
        end
    end

    return true
end

function CheckCondPlugin:NotExistBuff(entity,param)
    return not self:ExistBuff(entity,param)
end

function CheckCondPlugin:HomeEntity(entity,param)
    return entity.TagComponent.mainTag == BattleDefine.EntityTag.home
end

function CheckCondPlugin:NotHomeEntity(entity,param)
    return not self:HomeEntity(entity,param)
end

function CheckCondPlugin:LifeType(entity,param)
    return entity.ObjectDataComponent:GetLifeType() == param.lifeType
end

function CheckCondPlugin:NotLifeType(entity,param)
    return not self:LifeType(entity,param)
end


function CheckCondPlugin:RangeExistUnit(entity,param)
    local findParam = {}
    findParam.entity = entity
    findParam.camp = entity.CampComponent:GetCamp()
    findParam.notFilterAndCull = true
    findParam.isLock = true
    findParam.targetArgs = self.world.BattleMixedSystem:GetTargetArgs(param.targetCondId)

    local pos = entity.TransformComponent:GetPos()
    findParam.transInfo = {posX = pos.x,posZ = pos.z}

    local entitys,_ = self.world.BattleSearchSystem:SearchByRange(findParam,{type = BattleDefine.RangeType.circle,radius = param.radius})
    return #entitys >= param.num
end

function CheckCondPlugin:NotRangeExistUnit(entity,param)
    return not self:RangeExistUnit(entity,param)
end

function CheckCondPlugin:BasicallySameForward(entity,param,args)
    local fromEntity = self.world.EntitySystem:GetEntity(args.fromEntityUid)
    local targetEntity = self.world.EntitySystem:GetEntity(args.targetEntityUids[1])

    if not fromEntity or not targetEntity then
        return false
    end

    local fromForward = fromEntity.TransformComponent:GetForward()
    local targetForward = targetEntity.TransformComponent:GetForward()
    local d = FPVector3.Dot(fromForward,targetForward)
    local flag = false
    if d >= 800 and d <= 1000 then
        flag = true
    end
    return flag
end


function CheckCondPlugin:CheckAttrVal(entity,param)
    local attrType = BattleUtils.GetConfAttr(param.attr)

    local curVal = entity.AttrComponent:GetValue(attrType)

    local maxVal = curVal
    if attrType == BattleDefine.Attr.hp then
        maxVal = entity.AttrComponent:GetValue(GDefine.Attr.max_hp)
    end

    local checkVal = self.world.PluginSystem.CalcAttr:CalcVal(maxVal,param)

    if param.op == '<' and curVal >= checkVal then
        return false
    elseif param.op == '<=' and curVal > checkVal then
        return false
    elseif param.op == '=' and curVal ~= checkVal then
        return false
    elseif param.op == '>' and curVal <= checkVal then
        return false
    elseif param.op == '>=' and curVal < checkVal then
        return false
    end
    return true
end