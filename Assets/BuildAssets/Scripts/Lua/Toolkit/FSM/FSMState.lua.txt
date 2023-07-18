-- FSMState也可以当成FSM来用，即实现分层状态机
FSMState = Class("FSMState", FSM)

function FSMState:OnInit(stateId)
    self.stateId = stateId or self._className
end

function FSMState:OnDelete()
end

function FSMState:GetStateID()
    return self.stateId
end

function FSMState:SetOwnerFSM(fsm)
    self.ownerFSM = fsm
end

function FSMState:GetOwnerFSM()
    return self.ownerFSM
end

return FSMState
