SECBEventTrigger = BaseClass("SECBEventTrigger",SECBBase)
--事件触发器，可拥有多个触发器

function SECBEventTrigger:__Init()

end

function SECBEventTrigger:__Delete()

end

function SECBEventTrigger:OnRegister()
end

function SECBEventTrigger:AddHandler(event,callBack)
    self.world.EventTriggerSystem:AddHandler(event,callBack)
end

function SECBEventTrigger:CheckNum(args,isMust,fieldName,checkVal)
    if not args then
        return true
    end

    if not args[fieldName] then
        return not isMust
    end

    if args[fieldName] == 0 then
        return true
    end

    return args[fieldName] == checkVal
end

function SECBEventTrigger:CheckStr(args,isMust,fieldName,checkVal)
    if not args then
        return true
    end

    if not args[fieldName] then
        return not isMust
    end

    if args[fieldName] == "" then
        return true
    end

    return args[fieldName] == checkVal
end

function SECBEventTrigger:CheckHasDict(args,isMust,fieldName,checkVal)
    if not args then
        return true
    end

    if not args[fieldName] then
        return not isMust
    end

    if args[fieldName] == "" then
        return true
    end

    return args[fieldName] == checkVal
end

function SECBEventTrigger:CheckItemInList(args,isMust,fieldName,checkVal)
    if not args then
        return true
    end

    if not args[fieldName] then
        return not isMust
    end

    if next(args[fieldName]) == nil then
        return true
    end

    local flag = false
    for k, v in pairs(args[fieldName]) do
        if v == checkVal then
            flag = true
        end
    end

    return flag
end

function SECBEventTrigger:CheckEntity(args,fromEntityUid,checkEntityUid)
    if not args then
        return true
    end

    if args.beHitUnit and args.beHitUnit == 1 and not self:CheckNum(args,false,"entityUid",checkEntityUid) then
        return false
    end

    local entity = self.world.EntitySystem:GetEntity(args.entityUid)
    local isTarget = false
    if not args.targetCondId then
        isTarget = true
    else
        isTarget = self.world.BattleSearchSystem:IsTargetTypeByTargetId(entity,checkEntityUid,args.targetCondId)
    end

    local isFrom = false
    if not args.fromCondId then
        isFrom = true
    else
        isFrom = self.world.BattleSearchSystem:IsTargetTypeByTargetId(entity,fromEntityUid,args.fromCondId)
    end

    local isInRange = false
    if not args.radius then
        isInRange = true
    else
        local checkEntity = self.world.EntitySystem:GetEntity(checkEntityUid)
        local pos = entity.TransformComponent:GetPos()
        local transInfo = {posX = pos.x,posZ = pos.z}
        local range = {type = BattleDefine.RangeType.circle, appendModel = true, radius = args.radius}
        isInRange = self.world.BattleSearchSystem:InRangeEntity(entity,checkEntity,transInfo,range)
    end

    return (isTarget and isFrom and isInRange)
end