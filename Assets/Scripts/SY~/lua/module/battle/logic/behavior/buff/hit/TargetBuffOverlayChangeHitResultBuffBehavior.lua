TargetBuffOverlayChangeHitResultBuffBehavior = BaseClass("TargetBuffOverlayChangeHitResultBuffBehavior",BuffBehavior)

function TargetBuffOverlayChangeHitResultBuffBehavior:__Init()

end

function TargetBuffOverlayChangeHitResultBuffBehavior:__Delete()

end

function TargetBuffOverlayChangeHitResultBuffBehavior:OnInit()
    local eventParam = {}
    eventParam.entityUid = self.entity.uid
    eventParam.skillId = self.actionParam.skillId
    eventParam.hitUid = 0
    self:AddEvent(BattleEvent.change_hit_result_val,self:ToFunc("OnEvent"),eventParam)
end

function TargetBuffOverlayChangeHitResultBuffBehavior:OnEvent(args)
    local entityUid = self.actionParam.from == 1 and self.entity or args.targetEntityUids[1]
    local entity = self.world.EntitySystem:GetEntity(entityUid)
    local buff = entity.BuffComponent:GetBuffById(self.actionParam.buffId)
    if not buff then
        return 0
    end

    local overlayNum = buff:GetOverlay()

    local value = self.world.PluginSystem.CalcAttr:CalcVal(args.curCalcResultVal,self.actionParam,nil,overlayNum)

    self.buff:AddExecNum()

    return value
end

function TargetBuffOverlayChangeHitResultBuffBehavior:OnDestroy()

end