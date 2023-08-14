IdleMachine = BaseClass("IdleMachine",MachineBase)

function IdleMachine:__Init()
	self.idleFSM = nil
end

function IdleMachine:__Delete()
	if self.idleFSM then
		self.idleFSM:Delete()
	end
end

function IdleMachine:OnInit()
	self.idleFSM = IdleFSM.New()
	self.idleFSM:SetWorld(self.world)
	self.idleFSM:Init(self.entity)
end

function IdleMachine:OnEnter()
	self.idleFSM:OnEnter()
end

function IdleMachine:OnUpdate()
	self.idleFSM:Update()
end

function IdleMachine:OnExit()
	self.idleFSM:Reset()
end
