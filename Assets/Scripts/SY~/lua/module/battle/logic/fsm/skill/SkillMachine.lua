SkillMachine = BaseClass("SkillMachine",MachineBase)

function SkillMachine:__Init()

end

function SkillMachine:__Delete()

end

function SkillMachine:OnInit()

end

function SkillMachine:OnEnter()

end

function SkillMachine:OnExit()
	self.entity.SkillComponent:Clear()
end

function SkillMachine:OnCanSwitch()
	return self.entity.SkillComponent:CanFinish()
end
