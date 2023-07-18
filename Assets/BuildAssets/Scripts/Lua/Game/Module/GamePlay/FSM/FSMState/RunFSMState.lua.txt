RunFSMState = Class("RunFSMState",FSMState)

function RunFSMState:OnInit()
    
end

function RunFSMState:OnDelete()
    
end

function RunFSMState:CanTransition(data) return true end

function RunFSMState:OnEnter(data)
    PrintLog("进入了Run状态")
end

function RunFSMState:OnExit(data)
    PrintLog("退出了Run状态")
end

function RunFSMState:OnTick(deltaTime) end

return RunFSMState