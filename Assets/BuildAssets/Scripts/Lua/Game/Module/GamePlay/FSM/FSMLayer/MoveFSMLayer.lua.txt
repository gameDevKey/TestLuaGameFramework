MoveFSMLayer = Class("MoveFSMLayer",FSMState)

function MoveFSMLayer:OnInit()
    self:AddState(StateConfig.FSMState.Idle)
    self:AddState(StateConfig.FSMState.Move)
    self:AddState(StateConfig.FSMState.Run)
end

function MoveFSMLayer:OnDelete()
    
end

function MoveFSMLayer:CanTransition(data) return true end

function MoveFSMLayer:OnEnter(data)
    self:ChangeState(StateConfig.FSMState.Idle)
end

function MoveFSMLayer:OnExit(data) end

function MoveFSMLayer:OnTick(deltaTime)
end

return MoveFSMLayer