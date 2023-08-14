HitMachine = BaseClass("HitMachine",MachineBase)

function HitMachine:__Init()
	self.hitFSM = nil
end

function HitMachine:__Delete()
	if self.hitFSM then
		self.hitFSM:Delete()
	end
end

function HitMachine:OnInit(fight,entity)
	self.hitFSM = HitFSM.New()
	self.hitFSM:SetWorld(self.world)
	self.hitFSM:Init(self.entity)
end

function HitMachine:OnEnter(hitType)
	self.hitFSM:OnEnter(hitType)
end

function HitMachine:OnUpdate()
	self.hitFSM:Update()
end

function HitMachine:CanMove()
	return self.hitFSM:CanMove()
end

function HitMachine:OnCanSwitch()
	return self.hitFSM:OnCanSwitch()
end

function HitMachine:OnExit()
	self.hitFSM:Reset()
end