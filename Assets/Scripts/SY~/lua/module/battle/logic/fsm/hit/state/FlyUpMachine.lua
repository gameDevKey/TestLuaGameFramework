FlyUpMachine = BaseClass("FlyUpMachine",MachineBase)

function FlyUpMachine:__Init()

end

function FlyUpMachine:__Delete()

end

function FlyUpMachine:OnInit()
	self.hitTime = 1
end

function FlyUpMachine:OnEnter()
	self.entity.animatorComponent:PlayAnimation(self.hitName)
	--浮空移动
end

function FlyUpMachine:OnUpdate()

end

function FlyUpMachine:CanMove()
	return true
end

function HitNoneMachine:OnCanSwitch()
	return false
end