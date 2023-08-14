FightIdleMachine = BaseClass("FightIdleMachine",MachineBase)

function FightIdleMachine:__Init()

end

function FightIdleMachine:__Delete()

end

function FightIdleMachine:OnInit()

end

function FightIdleMachine:OnEnter()
	--self.entity.AnimComponent:PlayAnimation(Config.EntityCommonConfig.AnimatorNames.FightIdle)
end

function FightIdleMachine:OnExit()

end
