ChangeHitResultIdBuffBehavior = BaseClass("ChangeHitResultIdBuffBehavior",BuffBehavior)

function ChangeHitResultIdBuffBehavior:__Init()
end

function ChangeHitResultIdBuffBehavior:__Delete()

end

function ChangeHitResultIdBuffBehavior:OnInit()
    local eventParam = {}
    eventParam.entityUid = self.entity.uid
    eventParam.skillId = self.actionParam.skillId
    self:AddEvent(BattleEvent.change_hit_result_id,self:ToFunc("OnEvent"),eventParam)
end

function ChangeHitResultIdBuffBehavior:OnEvent(args)
    local targetEntity = self.world.EntitySystem:GetEntity(args.targetEntityUids[1])

    local changeInfos = nil
    for i,v in ipairs(self.actionParam.changes) do
        local targetCondId = v.targetCondId
        local targetArgs = self.world.BattleMixedSystem:GetTargetArgs(targetCondId)
        local isTargetType = self.world.BattleSearchSystem:IsTargetType(self.entity,targetEntity,targetArgs)
        if isTargetType then
            changeInfos = v
            break
        end
    end

    if not changeInfos then
        return nil
    end

    return changeInfos[args.hitResultId]
end

function ChangeHitResultIdBuffBehavior:OnDestroy()

end