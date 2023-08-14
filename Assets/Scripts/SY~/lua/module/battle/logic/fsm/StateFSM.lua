StateFSM = BaseClass("StateFSM",FSM)

function StateFSM:__Init()
end

function StateFSM:__Delete()
end

function StateFSM:OnInit(fight,entity)
	self:AddState(BattleDefine.EntityState.born, BornMachine)
	self:AddState(BattleDefine.EntityState.idle, IdleMachine)
	self:AddState(BattleDefine.EntityState.fightIdle,FightIdleMachine)
	self:AddState(BattleDefine.EntityState.move,MoveMachine)
	self:AddState(BattleDefine.EntityState.skill,SkillMachine)
	self:AddState(BattleDefine.EntityState.die, DieMachine)
	self:AddState(BattleDefine.EntityState.hit, HitMachine)

	self:InitState(self.entity,self)
end

function StateFSM:OnLateInit()
	self:LateInitState()
end

function StateFSM:OnCanSwitch()
	return self.statesMachine:OnCanSwitch()
end

function StateFSM:IsSubMoveState(subState)
	if self:IsState(BattleDefine.EntityState.move) then
		local moveState = self:GetStateMachine(BattleDefine.EntityState.move)
		return moveState.ownerFSM:IsState(subState)
	else
		return false
	end
end

function StateFSM:GetSubMoveState()
	if self:IsState(BattleDefine.EntityState.move) then
		local moveState = self:GetStateMachine(BattleDefine.EntityState.move)
		return moveState.ownerFSM:GetState()
	else
		return BattleDefine.EntityMoveSubState.none
	end
end

