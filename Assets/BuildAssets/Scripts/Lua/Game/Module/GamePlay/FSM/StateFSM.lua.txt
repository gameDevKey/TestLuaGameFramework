---分层有限状态机
StateFSM = Class("StateFSM",FSM)

function StateFSM:OnInit()
    self:AddState(StateConfig.FSMLayer.Move)
    self:AddState(StateConfig.FSMLayer.Fight)

    self:ChangeState(StateConfig.FSMLayer.Move)
end

function StateFSM:OnDelete()
end

function StateFSM:CanTransition(data) return true end

function StateFSM:OnEnter(data)
    self:ChangeState(StateConfig.FSMLayer.Move)
end

function StateFSM:OnExit(data) end

function StateFSM:OnTick(deltaTime) end

return StateFSM