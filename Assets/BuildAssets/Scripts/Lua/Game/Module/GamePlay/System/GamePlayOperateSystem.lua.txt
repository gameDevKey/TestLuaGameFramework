GamePlayOperateSystem = Class("GamePlayOperateSystem",ECSLSystem)

function GamePlayOperateSystem:OnInitComplete()
    self:AddListeners()
    self.targetPosOffset = Vector3.zero
end

function GamePlayOperateSystem:AddListeners()
    self.world.GameEventSystem:AddListener(EventConfig.Type.MoveInput,
        CallObject.New(self:ToFunc("OnUserInput")),nil,false)
end

function GamePlayOperateSystem:OnUserInput(h,v)
    local mainRole = self.world.GamePlayEntranceSystem.mainRole
    if not mainRole then
        return
    end
    local speed = mainRole.AttrComponent:GetAttr(AttrConfig.Type.MoveSpeed)
    self.targetPosOffset.x = h * self.world.deltaTime * speed
    self.targetPosOffset.y = v * self.world.deltaTime * speed
    local targetPos = mainRole.TransformComponent:GetPosVec3() + self.targetPosOffset
    mainRole.TransformComponent:SetPosVec3(targetPos)
    -- mainRole.MoveComponent:To(MoveConfig.Type.Linear,{
    --     targetPos = targetPos,
    --     speed = 10,
    -- })
end

return GamePlayOperateSystem