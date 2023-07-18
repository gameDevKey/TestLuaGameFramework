FightFSMLayer = Class("FightFSMLayer",FSMState)

function FightFSMLayer:OnInit()
    self:AddState(StateConfig.FSMState.Fight)
end

function FightFSMLayer:OnDelete()
    
end

function FightFSMLayer:CanTransition(data) return true end

function FightFSMLayer:OnEnter(data)
    self:ChangeState(StateConfig.FSMState.Fight)
end

function FightFSMLayer:OnExit(data) end

function FightFSMLayer:OnTick(deltaTime) end

return FightFSMLayer