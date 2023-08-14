DieMachine = BaseClass("DieMachine",MachineBase)

function DieMachine:__Init()
	self.dieFSM = nil
end

function DieMachine:__Delete()
	if self.dieFSM then
		self.dieFSM:Delete()
	end
end

function DieMachine:OnInit()
	self.dieFSM = DieFSM.New()
	self.dieFSM:SetWorld(self.world)
	self.dieFSM:Init(self.entity)
end

function DieMachine:OnEnter()
	self.dieFSM:OnEnter()
end

function DieMachine:OnUpdate()
	self.dieFSM:Update()
end

function DieMachine:OnExit()
	self.dieFSM:Reset()
end

function DieMachine:CanMove()
	return false
end

function DieMachine:OnCanSwitch()
	return false
end