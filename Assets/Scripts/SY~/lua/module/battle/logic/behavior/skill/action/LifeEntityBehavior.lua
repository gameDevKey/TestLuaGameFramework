LifeEntityBehavior = BaseClass("LifeEntityBehavior",SkillBehavior)

function LifeEntityBehavior:__Init()
    self.lifeTime = 0
    self.currentTime = 0
    self.isReachLifeTime = false
end

function LifeEntityBehavior:__Delete()

end

function LifeEntityBehavior:OnInit(lifeTime)
    self.skill:AddRefNum(1)
    self.currentTime = 0
    self.isReachLifeTime = false
    self:SetLifeTime(lifeTime)
end

function LifeEntityBehavior:SetLifeTime(lifeTime)
    self.lifeTime = lifeTime or 0
end

function LifeEntityBehavior:OnReachLifeTime()
    if self.isReachLifeTime then
        return
    end
    self.isReachLifeTime = true
    self.world.BattleHitSystem:ImmedDie(self.entity)
end

function LifeEntityBehavior:OnUpdate()
    if self.isReachLifeTime then
        return
    end
    self.currentTime = self.currentTime + self.world.opts.frameDeltaTime
    if self.currentTime >= self.lifeTime then
        self:OnReachLifeTime()
    end
end