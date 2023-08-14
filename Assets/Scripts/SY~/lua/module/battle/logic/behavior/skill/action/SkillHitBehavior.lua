SkillHitBehavior = BaseClass("SkillHitBehavior",SkillBehavior)

function SkillHitBehavior:__Init()
    self.targetEntityUids = nil

    self.hitTime = 0     -- 命中时间点
    self.nextHitTime = 0 -- 下次命中时间点
    self.hitIndex = 0    -- 命中索引
end

function SkillHitBehavior:__Delete()
end

function SkillHitBehavior:OnInit(targetUids)
    self.skill:AddRefNum(1)

    self.hitTime = 0
    self.hitIndex = 0
    self.nextHitTime = 0
    self:SetNextHitIndex()

    self.targetEntityUids = targetUids
end

function SkillHitBehavior:OnUpdate()
    self.hitTime = self.hitTime + self.world.opts.frameDeltaTime
    if self.hitTime < self.nextHitTime then
        return
    end

    self:DoSkillHit()
    self:SetNextHitIndex()
end

function SkillHitBehavior:SetNextHitIndex()
    if self.hitIndex + 1 <= #self.actionParam.hitSteps then
        self.hitIndex = self.hitIndex + 1
    else
        self:SetRemove(true)
    end
    self.nextHitTime = self.nextHitTime + self.actionParam.hitSteps[self.hitIndex][2]
end

function SkillHitBehavior:DoSkillHit()
    local targetEntitys = nil
    if self.skill.baseConf.lock_target == 1 then
        targetEntitys = self.targetEntityUids
    else
        local searchParams = self.world.BattleCastSkillSystem.skillSearchParams
        searchParams.entity = self.entity
        searchParams.range = self.skill:GetHitRange()
        searchParams.targetNum = self.skill:GetHitNum()
        searchParams.transInfo = {}

        local x, z = nil, nil
        if self.actionParam.multiple then
            local lockTargetEntity = self.world.EntitySystem:GetEntity(self.targetEntityUids[1])
            local targetPos = nil
            if lockTargetEntity then
                targetPos = lockTargetEntity.TransformComponent:GetPos()
            else
                self:SetRemove(true)
                return
            end
            x = targetPos.x
            z = targetPos.z
        else
            x = self.transInfo.posX
            z = self.transInfo.posZ
        end

        searchParams.transInfo.posX = x
        searchParams.transInfo.posZ = z

        local entitys,_ = self.world.BattleCastSkillSystem:SkillSearchEntity(self.skill,searchParams)
        targetEntitys = entitys
    end

    self:HitEntitys(targetEntitys,self.actionParam.hitSteps[self.hitIndex][1])
end