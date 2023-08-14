NewFloorEntityAIAction = BaseClass("NewFloorEntityAIAction",BTAction)

function NewFloorEntityAIAction:__Init()
    self.moveComplete = false
end

function NewFloorEntityAIAction:__Delete()

end

function NewFloorEntityAIAction:OnStart()

end

function NewFloorEntityAIAction:OnUpdate(deltaTime)
    local selfPos = self.owner.entity.TransformComponent:GetPos()

    local entitys = self.owner:GetCacheData("search_entitys")
    if #entitys > 0 then
        return self:TraceEntity(entitys[1])
    else
        return self:MoveToHomeTargetPos()
    end
end

function NewFloorEntityAIAction:TraceEntity(entityUid)
    local selfPos = self.owner.entity.TransformComponent:GetPos()
    local selfCamp = self.owner.entity.CampComponent:GetCamp()

    local targetEntity = self.owner.world.EntitySystem:GetEntity(entityUid)
    local targetPos = targetEntity.TransformComponent:GetPos()
    local targetCamp = targetEntity.CampComponent:GetCamp()

    local selfAreaCamp = self.owner.world.BattleTerrainSystem:GetAreaCamp(selfCamp,selfPos.z)
    local targetAreaCamp = self.owner.world.BattleTerrainSystem:GetAreaCamp(targetCamp,targetPos.z)

    local selfIsRoad,selfRoadIndex = self.owner.world.BattleTerrainSystem:InRoadArea(selfPos.x,selfPos.z)
    local targetIsRoad,targetRoadIndex = self.owner.world.BattleTerrainSystem:InRoadArea(targetPos.x,targetPos.z)

    local selfInRoadX,selfInRoadXIndex = self.owner.world.BattleTerrainSystem:InRoadX(selfPos.x)
    local targetInRoadX,targetInRoadXIndex = self.owner.world.BattleTerrainSystem:InRoadX(targetPos.x)

    if selfIsRoad and targetIsRoad and selfRoadIndex == targetRoadIndex then
        --在同一桥上
        self.owner.entity.MoveComponent:MoveToPos(targetPos.x,selfPos.y,targetPos.z,{})
    elseif selfAreaCamp and targetAreaCamp and selfAreaCamp == targetAreaCamp then
        --在同一区域
        self.owner.entity.MoveComponent:MoveToPos(targetPos.x,selfPos.y,targetPos.z,{})
    elseif selfInRoadX and targetInRoadX and selfInRoadXIndex == targetInRoadXIndex then
        --在同一桥的x范围内
        self.owner.entity.MoveComponent:MoveToPos(targetPos.x,selfPos.y,targetPos.z,{})
    else
        return self:MoveToHomeTargetPos()
    end

    return BTTaskStatus.Failure
end

function NewFloorEntityAIAction:MoveToHomeTargetPos()
    local selfPos = self.owner.entity.TransformComponent:GetPos()
    local selfCamp = self.owner.entity.CampComponent:GetCamp()

    local initTargetPos = self.owner.world.BattleMixedSystem:GetInitTargetPos(selfCamp)
    if selfCamp == BattleDefine.Camp.attack then
        if selfPos.z >= initTargetPos.z - FPFloat.Fix then
            self.moveComplete = true
            return BTTaskStatus.Success
        end
    elseif selfCamp == BattleDefine.Camp.defence then
        if selfPos.z <= initTargetPos.z + FPFloat.Fix then
            self.moveComplete = true
            return BTTaskStatus.Success
        end
    end

    local selfAreaCamp = self.owner.world.BattleTerrainSystem:GetAreaCamp(selfCamp,selfPos.z)

    --local targetPos = trackEntity.TransformComponent:GetPos()
    local targetCamp = self.owner.entity.CampComponent:GetEnemyCamp()
    --local targetAreaCamp = self.owner.world.BattleTerrainSystem:GetAreaCamp(targetCamp,targetPos.z)
    --

    if self.moveComplete and selfAreaCamp == targetCamp then
        return BTTaskStatus.Success
    elseif self.moveComplete and selfAreaCamp ~= targetCamp then
        self.moveComplete = false
    end

    local nodeX,nodeZ = self.owner.world.BattleTerrainSystem:GetMinRoadPos(selfCamp,selfPos.x,selfPos.z)

    if selfCamp == BattleDefine.Camp.attack then
        if selfPos.z >= nodeZ - FPFloat.Fix then
            nodeZ = self.owner.world.BattleTerrainSystem:GetCampRoadZ(targetCamp)
        end
        if selfPos.z >= nodeZ - FPFloat.Fix then
            nodeX = selfPos.x
            nodeZ = initTargetPos.z
        end
    elseif selfCamp == BattleDefine.Camp.defence then
        if selfPos.z <= nodeZ + FPFloat.Fix then
            nodeZ = self.owner.world.BattleTerrainSystem:GetCampRoadZ(targetCamp)
        end
        if selfPos.z <= nodeZ + FPFloat.Fix then
            nodeX = selfPos.x
            nodeZ = initTargetPos.z
        end
    end

    self.owner.entity.MoveComponent:MoveToPos(nodeX,selfPos.y,nodeZ,{onComplete = self:ToFunc("MoveToTargetFinish")})

    return BTTaskStatus.Failure
end

function NewFloorEntityAIAction:MoveToTargetFinish()
    --self.moveComplete = true
end