IdleLeisurelyMachine = BaseClass("IdleLeisurelyMachine",MachineBase)

function IdleLeisurelyMachine:__Init()
end

function IdleLeisurelyMachine:__Delete()
end

function IdleLeisurelyMachine:OnInit()
end

function IdleLeisurelyMachine:OnEnter()
	if self.entity.AnimComponent then
		self.entity.AnimComponent:PlayAnim(BattleDefine.Anim.idle)
	end
end

function IdleLeisurelyMachine:OnExit()

end