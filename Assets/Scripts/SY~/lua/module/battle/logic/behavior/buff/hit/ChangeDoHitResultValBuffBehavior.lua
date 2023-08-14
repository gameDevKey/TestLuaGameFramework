ChangeDoHitResultValBuffBehavior = BaseClass("ChangeDoHitResultValBuffBehavior",BuffBehavior)

function ChangeDoHitResultValBuffBehavior:__Init()
end

function ChangeDoHitResultValBuffBehavior:__Delete()

end

function ChangeDoHitResultValBuffBehavior:OnInit()
    local eventParam = {}
    eventParam.entityUid = self.entity.uid
    eventParam.skillId = self.actionParam.skillId
    self:AddEvent(BattleEvent.change_do_hit_result_val,self:ToFunc("OnEvent"),eventParam)
end

function ChangeDoHitResultValBuffBehavior:OnEvent(args)
    if args.hitType ~= BattleDefine.ConfHitType[self.actionParam.hitType] then
        return 0
    end

    if self.actionParam.hitDisType ~= 0 and args.hitDisType ~= self.actionParam.hitDisType then
        return 0
    end

    self.buff:AddExecNum()

    local value = self.world.PluginSystem.CalcAttr:CalcVal(args.curCalcResultVal,self.actionParam,nil,self.buff.overlay)
    return value
end

function ChangeDoHitResultValBuffBehavior:OnDestroy()

end