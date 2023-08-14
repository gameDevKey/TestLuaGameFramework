HitNoneMachine = BaseClass("HitNoneMachine",MachineBase)

function HitNoneMachine:__Init()

end

function HitNoneMachine:__Delete()

end

function HitNoneMachine:OnEnter()

end

function HitNoneMachine:CanMove()
	return false
end

function HitNoneMachine:OnCanSwitch()
	return false
end
