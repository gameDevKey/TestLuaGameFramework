DeathMachine = BaseClass("DeathMachine",MachineBase)

function DeathMachine:__Init()
	self.deathTimeline = nil
	self.downMover = nil
end

function DeathMachine:__Delete()
	if self.deathTimeline then
		self.deathTimeline:Delete()
	end

	if self.downMover then
		self.downMover:Delete()
	end
end

function DeathMachine:OnEnter()
	local deadActId = self.entity.ObjectDataComponent.unitConf.dead_args.actId
	if deadActId then
		local actConf = self.world.BattleConfSystem:DeadTimeline(deadActId)
		if not actConf then
			assert(false,string.format("找不到死亡行为配置[单位Id:%s][行为Id:%s]",self.entity.ObjectDataComponent.unitConf.id,tostring(deadActId)))
		end

		self.deathTimeline = PerformTimeline.New()
		self.deathTimeline:SetWorld(self.world)
		self.deathTimeline:Init(actConf,self.entity)
		self.deathTimeline:SetComplete(self:ToFunc("TimelineComplete"))
		if self.entity.ObjectDataComponent.unitConf.dead_args.duration > 0 then
			self.deathTimeline:SetDuration(self.entity.ObjectDataComponent.unitConf.dead_args.duration)
		end
		self.deathTimeline:Start()
	else
		self:DeathFinish()
	end
end

function DeathMachine:OnUpdate()
	if self.deathTimeline and not self.deathTimeline:IsFinish() then
		self.deathTimeline:Update(self.world.opts.frameDeltaTime)
	end

	if self.downMover then
		self.downMover:Update()
	end
end

function DeathMachine:TimelineComplete()
	local pos = self.entity.TransformComponent:GetPos()
	local y = -FPMath.Divide(self.entity.CollistionComponent.modelHeight,2)


	self.downMover = LineraMover.New()
	self.downMover:SetWorld(self.world)
	self.downMover:SetEntity(self.entity)
	self.downMover:Init()

	self.downMover:SetParams({speed = 3000})
	self.downMover:MoveToPos(pos.x,y,pos.z,self:ToFunc("DieDownFinish"))
end

function DeathMachine:DieDownFinish()
	self:DeathFinish()
end

function DeathMachine:DeathFinish()
	self.world.BattleStateSystem:AddOverLockNum(-1)
	self.world.EntitySystem:RemoveEntity(self.entity.uid)
end

function DeathMachine:OnExit()

end

function DeathMachine:CanMove()
	return false
end

function DeathMachine:OnCanSwitch()
	return false
end