DieNoneMachine = BaseClass("DieNoneMachine",MachineBase)

function DieNoneMachine:__Init()
    self.dieFrame = 0
end

function DieNoneMachine:__Delete()

end


function DieNoneMachine:OnEnter()
	self.dieFrame = self.world.frame
	self.world.EntitySystem:PreRemove(self.entity.uid)
end

function DieNoneMachine:OnUpdate()
	if self.world.frame - self.dieFrame > 0 then
        self.ownerFSM:SwitchState(BattleDefine.EntityDieSubState.death)
	end
end

function DieNoneMachine:OnCanSwitch()
	return false
end
