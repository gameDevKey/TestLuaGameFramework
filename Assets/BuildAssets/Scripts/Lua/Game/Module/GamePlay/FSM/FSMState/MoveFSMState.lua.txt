MoveFSMState = Class("MoveFSMState",FSMState)

function MoveFSMState:OnInit()
    
end

function MoveFSMState:OnDelete()
    
end

function MoveFSMState:CanTransition(data) return true end

function MoveFSMState:OnEnter(data)
    PrintLog("进入了Move状态")
end

function MoveFSMState:OnExit(data)
    PrintLog("退出了Move状态")
end

function MoveFSMState:OnTick(deltaTime) end

return MoveFSMState