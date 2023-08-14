DieFSM = BaseClass("DieFSM",FSM)

function DieFSM:__Init()
end

function DieFSM:__Delete()
end

function DieFSM:OnInit()
	self:AddState(BattleDefine.EntityDieSubState.none,DieNoneMachine)
	self:AddState(BattleDefine.EntityDieSubState.death,DeathMachine)
	self:InitState(self.entity,self)
end

function DieFSM:OnEnter()
    self:SwitchState(BattleDefine.EntityDieSubState.none)
end

function DieFSM:Reset()
end

