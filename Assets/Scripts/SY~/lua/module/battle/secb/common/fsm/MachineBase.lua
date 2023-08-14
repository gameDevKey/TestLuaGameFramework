MachineBase = BaseClass("MachineBase",SECBBase)

function MachineBase:__Init()
	self.entity = nil
	self.ownerFSM = nil
end

function MachineBase:__Delete()
end

function MachineBase:Init(entity,ownerFSM,...)
	self.entity = entity
	self.ownerFSM = ownerFSM
	self:OnInit(...)
end

function MachineBase:LateInit()
	self:OnLateInit()
end

function MachineBase:Update()
	self:OnUpdate()
end

--
function MachineBase:OnCreate()
end

function MachineBase:OnInit()
end

function MachineBase:OnLateInit()
end

function MachineBase:OnEnter()
end

function MachineBase:OnUpdate()
end

function MachineBase:OnExit()
end

function MachineBase:OnCanSwitch()
	return true
end