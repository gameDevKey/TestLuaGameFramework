MoveMachine = BaseClass("MoveMachine",MachineBase)

function MoveMachine:__Init()
	self.moveFsm = nil
end

function MoveMachine:__Delete()
	if self.moveFSM then
		self.moveFSM:Delete()
	end
end

function MoveMachine:OnInit()
	self.moveFSM = MoveFSM.New()
	self.moveFSM:SetWorld(self.world)
	self.moveFSM:Init(self.entity)
end

function MoveMachine:LateInit()
	self.moveFSM:LateInit()
end

function MoveMachine:OnEnter()
	self.moveFSM:StartMove()
end

function MoveMachine:OnExit()
	self.moveFSM:Reset()
end

function MoveMachine:Update()
	self.moveFSM:Update()
end

function MoveMachine:StopMove()
	self.moveFSM:StopMove()
end

function MoveMachine:IsState(state)
	return self.moveFSM:IsState(state)
end

function MoveMachine:CanMove()
	return true
end

function MoveMachine:CanCastSkill()
	return true
end
