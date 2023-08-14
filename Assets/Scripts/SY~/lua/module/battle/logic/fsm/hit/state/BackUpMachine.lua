BackUpMachine = BaseClass("BackUpMachine",MachineBase)

function BackUpMachine:__Init()

end

function BackUpMachine:__Delete()

end

function BackUpMachine:OnInit()
	self.hitTime = 1
end

function BackUpMachine:OnEnter()
	self.entity.AnimComponent:PlayAnim(self.hitName)
	--向后移动
end

function BackUpMachine:OnUpdate()

end

function BackUpMachine:CanMove()
	return true
end

function HitNoneMachine:OnCanSwitch()
	return false
end