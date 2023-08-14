StateComponent = BaseClass("StateComponent",SECBComponent)

function StateComponent:__Init()
    self.stateFSM = nil
	self.isActionMove = false
	self.abnormalStates = {}
	self.markState = {}
	self.markStateUids = {}
	self.markStateUid = 0
end

function StateComponent:__Delete()
	if self.stateFSM then
		self.stateFSM:Delete()
	end
end

function StateComponent:OnInit()
    self.stateFSM = StateFSM.New()
    self.stateFSM:SetWorld(self.world)
    self.stateFSM:Init(self.entity)
end

function StateComponent:OnLateInit()
	self.stateFSM:LateInit()
end

function StateComponent:OnUpdate()
	self.stateFSM:Update()
end

function StateComponent:GetMarkStateUid()
	self.markStateUid = self.markStateUid + 1
	return self.markStateUid
end

function StateComponent:GetState()
	return self.stateFSM.curState
end

function StateComponent:IsState(state)
	return self.stateFSM:IsState(state)
end

function StateComponent:SetState(state,...)
	self.stateFSM:SwitchState(state,...)
end

function StateComponent:AddMarkState(markState)
	if not self.markState[markState] then 
		self.markState[markState] = 0 
	end
	self.markState[markState] = self.markState[markState] + 1

	local uid = self:GetMarkStateUid()
	self.markStateUids[uid] = markState

	local stateInfo = BattleDefine.MarkStateInfo[markState]
	if stateInfo and stateInfo.isControl then
		self:AddMarkState(BattleDefine.MarkState.control)
	end

	if markState == BattleDefine.MarkState.control and self.markState[markState] == 1 then
		--触发控制事件
		self.world.EventTriggerSystem:Trigger(BattleEvent.do_control,self.entity.uid)
	end

	return uid
end

function StateComponent:RemoveMarkState(markState)
	self.markState[markState] = self.markState[markState] - 1
	if self.markState[markState] < 0 then
		Log("可能有地方存在多次减少markState导致小于0")
		self.markState[markState] = 0
	end
	local stateInfo = BattleDefine.MarkStateInfo[markState]
	if stateInfo and stateInfo.isControl then
		self:RemoveMarkState(BattleDefine.MarkState.control)
	end
end

function StateComponent:RemoveMarkStateByUid(uid)
	local state = self.markStateUids[uid]
	if state then
		self.markStateUids[uid] = nil
		self:RemoveMarkState(state)
	end
end

function StateComponent:HasMarkState(markState)
	return self.markState[markState] and self.markState[markState] > 0
end

function StateComponent:CanSwitchState()
	return self.stateFSM:OnCanSwitch()
end

function StateComponent:SwitchHit(hitType)
	if self:CanSwitchState() then
		self:SetState(BattleDefine.EntityState.hit,hitType)
	end
end

function StateComponent:SetActionMove(flag)
	self.isActionMove = flag
end

function StateComponent:IsActionMove()
	return self.isActionMove
end

function StateComponent:CanMove()
	if not self:CanSwitchState() then
		return false
	end

	--TODO:后续加入异常状态导致的无法移动（眩晕、冰冻等）
	return true
end