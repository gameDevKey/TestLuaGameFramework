FSM = Class("FSM", FSMBehavior)

function FSM:OnInit(fsmId)
    self.fsmId = fsmId or self._className
    self.tbState = {}
    self.curState = nil
    self.exitLink = {}
end

function FSM:OnDelete()
    for id, state in pairs(self.tbState) do
        state:Delete()
    end
    self.tbState = nil
    self.exitLink = nil
end

function FSM:GetId()
    return self.fsmId
end

function FSM:GetCurState()
    return self.curState
end

---状态是否注册
function FSM:ContainState(stateId)
    return self.tbState[stateId] ~= nil
end

---添加FSM状态
function FSM:AddState(stateId)
    local state = _G[stateId].New(stateId)
    local id = state:GetStateID()
    if self:ContainState(id) then
        PrintWarning("FSM:状态已注册", id)
        return
    end
    state:SetOwnerFSM(self)
    state:SetWorld(self.world)
    self.tbState[id] = state
end

---移除FSM状态
function FSM:RemoveState(stateId)
    if not self:ContainState(stateId) then
        PrintWarning("FSM:状态未注册", stateId)
        return
    end
    self.tbState[stateId]:Delete()
    self.tbState[stateId] = nil
end

---切换到某个状态
function FSM:ChangeState(stateId)
    return self:ChangeStateByOrder(FSMOrder.New(stateId))
end

---切换到某个状态
function FSM:ChangeStateByOrder(order)
    if not order then
        return false
    end

    local stateId = order:GetStateId()
    local enterData = order:GetEnterData()
    local exitData = order:GetExitData()
    local transitionData = order:GetTransitionData()

    if not self:ContainState(stateId) then
        PrintWarning("FSM:状态未注册", stateId)
        return false
    end

    local state = self.tbState[stateId]
    local lastState = self.curState

    if state ~= lastState then
        if not state:CanTransition(transitionData) then
            return false
        end
        self.curState = state
        if lastState ~= nil then
            lastState:Exit(exitData)
        end
        self.curState:Enter(enterData)
        return true
    end
    return false
end

---设置退出时自动切换的状态
function FSM:SetExitLink(stateId1, stateId2)
    self.exitLink[stateId1] = stateId2
end

---主动退出某个状态
function FSM:ExitState(stateId)
    local state = self.tbState[stateId]
    if not state then
        return
    end
    state:Exit()
    local linkStateId = self.exitLink[stateId]
    if linkStateId then
        self:ChangeState(linkStateId)
    end
end

function FSM:OnTick(deltaTime)
    if self.curState ~= nil then
        self.curState:Tick(deltaTime)
    end
end

return FSM
