FSMOrder = Class("FSMOrder")

function FSMOrder:OnInit(stateId, enterData, exitData, transitionData)
    self.stateId = stateId
    self.enterData = enterData
    self.exitData = exitData
    self.transitionData = transitionData
end

function FSMOrder:GetStateId()
    return self.stateId
end

function FSMOrder:GetEnterData()
    return self.enterData
end

function FSMOrder:GetExitData()
    return self.exitData
end

function FSMOrder:GetTransitionData()
    return self.transitionData
end

return FSMOrder
