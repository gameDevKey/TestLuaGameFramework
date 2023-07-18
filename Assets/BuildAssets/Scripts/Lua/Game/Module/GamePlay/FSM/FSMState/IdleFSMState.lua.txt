IdleFSMState = Class("IdleFSMState",FSMState)

function IdleFSMState:OnInit()
    
end

function IdleFSMState:OnDelete()
    
end

function IdleFSMState:CanTransition(data) return true end

function IdleFSMState:OnEnter(data)
    PrintLog("进入了Idle状态")
end

function IdleFSMState:OnExit(data)
    PrintLog("退出了Idle状态")
end

function IdleFSMState:OnTick(deltaTime) end

return IdleFSMState