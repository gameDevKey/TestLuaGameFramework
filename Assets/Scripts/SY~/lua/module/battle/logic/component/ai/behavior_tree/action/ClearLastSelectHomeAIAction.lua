ClearLastSelectHomeAIAction = BaseClass("ClearLastSelectHomeAIAction",BTAction)

function ClearLastSelectHomeAIAction:__Init()

end

function ClearLastSelectHomeAIAction:__Delete()

end

function ClearLastSelectHomeAIAction:OnStart()

end

function ClearLastSelectHomeAIAction:OnUpdate(deltaTime)
    local lastEntityUid = self.owner.entity.KvDataComponent:GetData(BattleDefine.EntityKvType.last_select_target)

    if lastEntityUid then
        local lastEntity = self.owner.world.EntitySystem:GetEntity(lastEntityUid)
        if not lastEntity then
            self.owner.entity.KvDataComponent:SetData(BattleDefine.EntityKvType.last_select_target,nil)
        elseif lastEntity.TagComponent:IsTag(BattleDefine.EntityTag.home) then
            self.owner.entity.KvDataComponent:SetData(BattleDefine.EntityKvType.last_select_target,nil)
        end
    end

    return BTTaskStatus.Success
end