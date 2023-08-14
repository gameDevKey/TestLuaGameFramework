PveFloorEntityAIAction = BaseClass("PveFloorEntityAIAction",BTAction)

function PveFloorEntityAIAction:__Init()
    self.moveComplete = false
end

function PveFloorEntityAIAction:__Delete()

end

function PveFloorEntityAIAction:OnStart()

end

function PveFloorEntityAIAction:OnUpdate(deltaTime)
    local selfPos = self.owner.entity.TransformComponent:GetPos()

    local entitys = self.owner:GetCacheData("search_entitys")
    if #entitys > 0 then
        local entityUid = entitys[1]

        local targetEntity = self.owner.world.EntitySystem:GetEntity(entityUid)
        local targetPos = targetEntity.TransformComponent:GetPos()

        if not self.owner.entity.MoveComponent:IsSameMovePos(targetPos.x,selfPos.y,targetPos.z) then
            self.owner.entity.MoveComponent:MoveToPos(targetPos.x,selfPos.y,targetPos.z,{})
        end

        return BTTaskStatus.Failure
    else
        if self.moveComplete then
            return BTTaskStatus.Success
        end

        local camp = self.owner.entity.CampComponent:GetCamp()
        local initTargetPos = self.owner.world.BattleMixedSystem:GetInitTargetPos(camp)

        if camp == BattleDefine.Camp.attack then
            if selfPos.z >= initTargetPos.z then
                self.moveComplete = true
                return BTTaskStatus.Success
            end
        elseif camp == BattleDefine.Camp.defence then
            if selfPos.z <= initTargetPos.z then
                self.moveComplete = true
                return BTTaskStatus.Success
            end
        end

        if not self.owner.entity.MoveComponent:IsSameMovePos(selfPos.x,selfPos.y,initTargetPos.z) then
            self.owner.entity.MoveComponent:MoveToPos(selfPos.x,selfPos.y,initTargetPos.z,{onComplete = self:ToFunc("MoveToTargetFinish")})
        end

        return BTTaskStatus.Failure
    end
end

function PveFloorEntityAIAction:MoveToTargetFinish()
    self.moveComplete = true
end