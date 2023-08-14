MoveToHomeAIAction = BaseClass("MoveToHomeAIAction",BTAction)

function MoveToHomeAIAction:__Init()

end

function MoveToHomeAIAction:__Delete()

end

function MoveToHomeAIAction:OnStart()

end

function MoveToHomeAIAction:OnUpdate(deltaTime)
    local selfPos = self.owner.entity.TransformComponent:GetPos()

    local camp = self.owner.entity.CampComponent:GetCamp()

    local enemyHomeUid = self.owner.world.BattleMixedSystem:GetEnemyHomeUid(camp)
    local enemyHomeEntity = self.owner.world.EntitySystem:GetEntity(enemyHomeUid)

    local targetPos = enemyHomeEntity.TransformComponent:GetPos()

    self.owner.entity.MoveComponent:MoveToPos(targetPos.x,selfPos.y,targetPos.z,{})
end