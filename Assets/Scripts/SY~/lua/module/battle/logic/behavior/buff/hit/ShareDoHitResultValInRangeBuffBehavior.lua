ShareDoHitResultValInRangeBuffBehavior = BaseClass("ShareDoHitResultValInRangeBuffBehavior",BuffBehavior)

function ShareDoHitResultValInRangeBuffBehavior:__Init()
end

function ShareDoHitResultValInRangeBuffBehavior:__Delete()

end

function ShareDoHitResultValInRangeBuffBehavior:OnInit()
    local eventParam = {}
    eventParam.entityUid = 0
    self:AddEvent(BattleEvent.share_do_hit_result_val_in_range,self:ToFunc("OnEvent"),eventParam)
end

function ShareDoHitResultValInRangeBuffBehavior:OnEvent(args)
    if args.hitType ~= BattleDefine.ConfHitType[self.actionParam.hitType] then
        return
    end

    local targetEntity = self.world.EntitySystem:GetEntity(args.targetEntityUids[1])
    local targetArgs = self.world.BattleMixedSystem:GetTargetArgs(self.actionParam.targetCondId)
    local isTargetType = self.world.BattleSearchSystem:IsTargetType(self.entity,targetEntity,targetArgs)
    if not isTargetType then
        return
    end


    -- 检测是否在范围内
    local selfEntityPos = self.entity.TransformComponent:GetPos()
    local selfEntityForward = self.entity.TransformComponent:GetForward()
    local transInfo = {}
    transInfo.posX = selfEntityPos.x
    transInfo.posZ = selfEntityPos.z
    transInfo.dirX = selfEntityForward.x
    transInfo.dirZ = selfEntityForward.z
    local range = {type = BattleDefine.RangeType.circle, appendModel = true, radius = self.actionParam.radius}
    if not self.world.BattleSearchSystem:InRangeEntity(self.entity, targetEntity,transInfo,range) then
        return
    end

    -- 被分担角色最小受伤数值保护
    local limitVal = self.world.PluginSystem.CalcAttr:CalValByRatio(args.srcCalcResultVal,self.actionParam.limit)

    if args.curCalcResultVal <= limitVal then
        return
    end

    local toSharedVal = self.world.PluginSystem.CalcAttr:CalcVal(args.srcCalcResultVal,self.actionParam)
    local value = args.curCalcResultVal + toSharedVal

    if value < limitVal then
        toSharedVal = limitVal - args.curCalcResultVal
    end

    -- 分担的伤害命中自己
    local hitFrom = BattleDefine.HitFrom.other
    local fromEntityUid = args.fromEntityUid
    local hitEntityUid = self.entity.uid
    local hitResultId = 0
    local hitArgs = {calcVal = FPMath.Abs(toSharedVal),HitType = BattleDefine.ConfHitType[self.actionParam.hitType]}
    self.world.BattleHitSystem:HitResult(hitFrom,fromEntityUid,hitEntityUid,hitResultId,hitArgs)

    self.buff:AddExecNum()

    return toSharedVal
end

function ShareDoHitResultValInRangeBuffBehavior:OnDestroy()
end