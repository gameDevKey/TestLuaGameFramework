FightFSMState = Class("FightFSMState",FSMState)

function FightFSMState:OnInit()
    
end

function FightFSMState:OnDelete()
    
end

function FightFSMState:CanTransition(data) return true end

function FightFSMState:OnEnter(data)
    PrintLog("进入了Fight状态")
end

function FightFSMState:OnExit(data)
    PrintLog("退出了Fight状态")
end

function FightFSMState:OnTick(deltaTime) end

return FightFSMState