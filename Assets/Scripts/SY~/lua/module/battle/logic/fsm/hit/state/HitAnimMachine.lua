HitAnimMachine = BaseClass("HitAnimMachine",MachineBase)

function HitAnimMachine:__Init()
    self.hitTime = 0
    self.remainHitTime = 0
end

function HitAnimMachine:__Delete()

end

function HitAnimMachine:OnInit()

end

function HitAnimMachine:OnEnter()
	--TODO:时间配置
    self.hitTime = self.entity.AnimComponent:GetClipTime(BattleDefine.Anim.hit)
    self.remainHitTime = self.hitTime
	self.entity.AnimComponent:PlayAnim(BattleDefine.Anim.hit)
end

function HitAnimMachine:OnUpdate()
    self.remainHitTime = self.remainHitTime - self.world.opts.frameDeltaTime
	if self.remainHitTime <= 0 then
		self.entity.StateComponent:SetState(BattleDefine.EntityState.idle)
	end
end

function HitAnimMachine:CanMove()
	return true
end

function HitAnimMachine:OnCanSwitch()
	return false
end