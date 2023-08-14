RunMachine = BaseClass("RunMachine",MachineBase)

function RunMachine:__Init()
end

function RunMachine:__Delete()

end

function RunMachine:OnInit()

end

function RunMachine:OnLateInit()
	--self.runSpeed = self.entity.attrComponent.attrs[EntityAttrsConfig.AttrType.RunSpeed]
end

function RunMachine:OnEnter()
	self.entity.AnimComponent:PlayAnim(BattleDefine.Anim.run)
end

function RunMachine:OnUpdate()

end

function RunMachine:OnExit()
end
