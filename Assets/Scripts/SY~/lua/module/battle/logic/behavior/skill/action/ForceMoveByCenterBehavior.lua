ForceMoveByCenterBehavior = BaseClass("ForceMoveByCenterBehavior",SkillBehavior)

function ForceMoveByCenterBehavior:__Init()
    self.holdingTime = 0
    self.centerPos = FPVector3(0,0,0)
end

function ForceMoveByCenterBehavior:__Delete()
end

function ForceMoveByCenterBehavior:OnInit()
    self.skill:AddRefNum(1)

    self.centerPos:Set(self.transInfo.posX,0,self.transInfo.posZ)
end

function ForceMoveByCenterBehavior:OnUpdate()
    self.holdingTime = self.holdingTime + self.world.opts.frameDeltaTime
    if self.holdingTime >= self.actionParam.holdingTime then
        self:SetRemove(true)
    end

    local targetEntitys = nil
    local searchParams = self.world.BattleCastSkillSystem.skillSearchParams
    searchParams.entity = self.entity
    searchParams.range = self.skill:GetHitRange()
    searchParams.targetNum = self.skill:GetHitNum()
    searchParams.transInfo = {}

    searchParams.transInfo.posX = self.centerPos.x
    searchParams.transInfo.posZ = self.centerPos.z

    local entitys,_ = self.world.BattleCastSkillSystem:SkillSearchEntity(self.skill,searchParams)
    targetEntitys = entitys
    self:ForceMove(targetEntitys)
end

function ForceMoveByCenterBehavior:ForceMove(entityUids)
    for k, v in pairs(entityUids) do
        local entity = self.world.EntitySystem:GetEntity(v)
        if entity and entity.TransformComponent then
            local pos = entity.TransformComponent:GetPos()
            local force = FPVector3.zero
            if self.actionParam.closerCenter then
                force = self.centerPos - pos
            else
                force = pos - self.centerPos
            end
            force:NormalizeTo(FPMath.Divide(self.actionParam.strength,1000))
            entity.TransformComponent:AddVelocity(force.x,force.y,force.z)
        end
    end
end