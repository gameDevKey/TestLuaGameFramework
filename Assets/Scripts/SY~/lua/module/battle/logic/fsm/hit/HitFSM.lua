HitFSM = BaseClass("HitFSM",FSM)

function HitFSM:__Init()

end

function HitFSM:__Delete()

end

function HitFSM:OnInit()
	self:AddState(BattleDefine.EntityHitState.none,HitNoneMachine)
	self:AddState(BattleDefine.EntityHitState.anim,HitAnimMachine)
	self:AddState(BattleDefine.EntityHitState.back_up,BackUpMachine)
	self:AddState(BattleDefine.EntityHitState.fly_up,FlyUpMachine)

	self:InitState(self.entity,self)
	self:SwitchState(BattleDefine.EntityHitState.none)
end

function HitFSM:Reset()
	self:SwitchState(BattleDefine.EntityHitState.none)
end

function HitFSM:OnEnter(hitType)
	self:SwitchState(hitType)
end

function HitFSM:CanMove()
	return self.statesMachine:CanMove()
end

function HitFSM:OnCanSwitch()
	return self.statesMachine:OnCanSwitch()
end