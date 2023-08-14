IdleFSM = BaseClass("IdleFSM",FSM)

function IdleFSM:__Init()
end

function IdleFSM:__Delete()
end

function IdleFSM:OnInit()
	self:AddState(BattleDefine.EntityIdleSubState.none,IdleNoneMachine)
	self:AddState(BattleDefine.EntityIdleSubState.fight_idle,IdleFightMachine)
	self:AddState(BattleDefine.EntityIdleSubState.leisurely_idle,IdleLeisurelyMachine)

	self:InitState(self.entity,self)
	self:SwitchState(BattleDefine.EntityIdleSubState.none)
end

function IdleFSM:OnEnter()
	self:SwitchState(BattleDefine.EntityIdleSubState.leisurely_idle)
	-- if self.fight.defaultIdleType then
	-- 	self:SwitchState(self.fight.defaultIdleType)
	-- else
	-- 	self:SwitchState(EntityIdleType.leisurely_idle)
	-- end
end

function IdleFSM:Reset()
	self:SwitchState(BattleDefine.EntityIdleSubState.none)
end

