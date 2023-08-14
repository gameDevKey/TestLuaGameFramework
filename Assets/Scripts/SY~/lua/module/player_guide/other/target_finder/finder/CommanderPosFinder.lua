CommanderPosFinder = BaseClass("CommanderPosFinder",BaseTargetPosFinder)

function CommanderPosFinder:__Init()

end

function CommanderPosFinder:__Delete()

end

function CommanderPosFinder:OnInit()

end

function CommanderPosFinder:OnUpdate()
    if not RunWorld then
        return
    end

    local camp = RunWorld.BattleDataSystem:GetCampByFrom(self.posParams.from)
    local cammanderEntity = RunWorld.EntitySystem:GetCommanderByCamp(camp)
    local worldPos = cammanderEntity.clientEntity.ClientTransformComponent:GetPos()
    local screenPos = BaseUtils.WorldToUIPoint(BattleDefine.nodeObjs["main_camera"],Vector3(worldPos.x,worldPos.y,worldPos.z))

    local targetArgs = {}
    targetArgs.targetPos = screenPos

    self:FindPosFinish(targetArgs)
end