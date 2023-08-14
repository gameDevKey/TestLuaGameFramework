BornMachine = BaseClass("BornMachine",MachineBase)

function BornMachine:__Init()
	self.bornTimeline = nil
end

function BornMachine:__Delete()
	if self.bornTimeline then
		self.bornTimeline:Delete()
	end
end

function BornMachine:OnInit()
end

function BornMachine:OnEnter()
	local bornActId = self.entity.ObjectDataComponent.unitConf.born_args.actId
	if bornActId then
		local actConf = self.world.BattleConfSystem:BornTimeline(bornActId)
		if not actConf then
			assert(false,string.format("找不到出场行为配置[单位Id:%s][行为Id:%s]",self.entity.ObjectDataComponent.unitConf.id,tostring(bornActId)))
		end

		self.entity.HitComponent:SetEnable(false)
		self.entity.SkillComponent:SetEnable(false)

		self.bornTimeline = PerformTimeline.New()
		self.bornTimeline:SetWorld(self.world)
		self.bornTimeline:Init(actConf,self.entity)
		self.bornTimeline:SetComplete(self:ToFunc("TimelineComplete"))

		if self.entity.ObjectDataComponent.unitConf.born_args.duration > 0 then
			self.bornTimeline:SetDuration(self.entity.ObjectDataComponent.unitConf.born_args.duration)
		end
		
		self.bornTimeline:Start()
	else
		self:DeathFinish()
	end
end

function BornMachine:OnUpdate()
	if self.bornTimeline and not self.bornTimeline:IsFinish() then
		self.bornTimeline:Update(self.world.opts.frameDeltaTime)
	end
end

function BornMachine:TimelineComplete()
	self.entity.HitComponent:SetEnable(true)
	self.entity.SkillComponent:SetEnable(true)
	self:DeathFinish()
end

function BornMachine:DeathFinish()
	self.entity.StateComponent:SetState(BattleDefine.EntityState.idle)
end

function BornMachine:OnCanSwitch()
	return false
end