MoveFSM = BaseClass("MoveFSM",FSM)

function MoveFSM:__Init()

end

function MoveFSM:__Delete()

end

function MoveFSM:OnInit()
	self:AddState(BattleDefine.EntityMoveSubState.none,MoveNoneMachine)
	self:AddState(BattleDefine.EntityMoveSubState.run, RunMachine)

	self:InitState(self.entity,self)

	self:SwitchState(BattleDefine.EntityMoveSubState.none)
end

function MoveFSM:OnLateInit()
	self:LateInitState()
end

function MoveFSM:StartMove()
	self:SwitchState(BattleDefine.EntityMoveSubState.run)
	-- if self:IsState(BattleDefine.EntityMoveSubState.RunStart) or self:IsState(BattleDefine.EntityMoveSubState.Run) then
	-- 	return
	-- end
	-- self:SwitchState(BattleDefine.EntityMoveSubState.RunStart)
end

function MoveFSM:StopMove()
	self.entity.StateComponent:SetState(BattleDefine.EntityState.idle)

	-- if self:IsState(BattleDefine.EntityMoveSubState.RunStartEnd) 
	-- 	or self:IsState(BattleDefine.EntityMoveSubState.RunEnd) then
	-- 	return
	-- end
	-- if self:IsState(BattleDefine.EntityMoveSubState.RunStart) then
	-- 	self:SwitchState(BattleDefine.EntityMoveSubState.RunStartEnd)
	-- else
	-- 	self:SwitchState(BattleDefine.EntityMoveSubState.RunEnd)
	-- end
end

function MoveFSM:SetMoveType(type)
	self:SwitchState(type)
end

function MoveFSM:Reset()
	self:SwitchState(BattleDefine.EntityMoveSubState.none)
end

