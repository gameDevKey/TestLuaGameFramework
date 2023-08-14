IdleFightMachine = BaseClass("IdleFightMachine",MachineBase)

function IdleFightMachine:__Init()
	self.idleFSM = idleFSM
end

function IdleFightMachine:__Delete()

end

function IdleFightMachine:OnInit(idleFSM)
	self.fight = fight
	self.entity = entity
end

function IdleFightMachine:OnEnter()
	--self.entity.AnimComponent:PlayAnimation(Config.EntityCommonConfig.AnimatorNames.FightIdle)
end

function IdleFightMachine:OnExit()

end

