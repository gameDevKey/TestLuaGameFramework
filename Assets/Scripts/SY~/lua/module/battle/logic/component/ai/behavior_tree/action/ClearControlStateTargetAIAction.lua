ClearControlStateTargetAIAction = BaseClass("ClearControlStateTargetAIAction",BTAction)

function ClearControlStateTargetAIAction:__Init()

end

function ClearControlStateTargetAIAction:__Delete()

end

function ClearControlStateTargetAIAction:OnStart()

end

function ClearControlStateTargetAIAction:OnUpdate(deltaTime)
    local lastEntityUid = self.owner.entity.KvDataComponent:GetData(BattleDefine.EntityKvType.last_select_target)

    if lastEntityUid and self.owner.world.PluginSystem.EntityStateCheck:IsControlState(self.owner.entity) then
        self.owner.entity.KvDataComponent:SetData(BattleDefine.EntityKvType.last_select_target,nil)
    end

    return BTTaskStatus.Success
end