CryLinkHitEntityBehavior = BaseClass("CryLinkHitEntityBehavior",SkillBehavior)
--TODO:缓存清理

function CryLinkHitEntityBehavior:__Init()
    --
    self.lastHitRenderPos = nil
    self.hitPos = FPVector3(0,0,0)

    self.hitTargetUid = 0

    --已命中过的目标Uid
    self.hitTargets = {}

    self.hitNum = 0 --已命中次数
    self.hitMaxNum = 0
    self.hitIndex = 0
    self.hitTime = 0
    self.nextHitTime = 0

    self.isFirstPlayEffect = true
end

function CryLinkHitEntityBehavior:__Delete()
end

function CryLinkHitEntityBehavior:OnInit(targetUid)
    self.skill:AddRefNum(1)
    --
    self.hitInfo = self.actionParam.hitInfo
    local targetEntity = self.world.EntitySystem:GetEntity(targetUid)
    if not targetEntity then
        self:SetRemove(true)
        return
    end

    self.hitMaxNum = self.skill:GetHitNum()

    self.hitTime = 0
    self.hitIndex = 0
    self:SetNextHitIndex()
    self:InitPos()

    self.hitTargetUid = targetUid
end

function CryLinkHitEntityBehavior:InitPos()
    if not self.world.opts.isClient or self:GetHitInfo().effectId == 0 then
        return
    end

    local ownerEntity = self.world.EntitySystem:GetEntity(self.entity.ownerUid)

    local conf = self.world.BattleConfSystem:EffectData_data_skill_effect(self:GetHitInfo().effectId)
    local pos,_ = self.world.ClientIFacdeSystem:Call("GetBoneTransInfo",ownerEntity,conf.bone,conf.custom_bone,conf.offset_pos)

    self.lastHitRenderPos = pos
end

function CryLinkHitEntityBehavior:OnUpdate()
    self.hitTime = self.hitTime + self.world.opts.frameDeltaTime
    if self.hitTime < self.nextHitTime then 
        return
    end

    self.hitNum = self.hitNum + 1

    if self.hitNum == 1 then
        self:Attack()
    else
        self.hitTargetUid = self:FindNextTarget()
        self:Attack()
    end

    if not self.hitTargetUid or not self.world.EntitySystem:GetEntity(self.hitTargetUid) then
        self:SetRemove(true)
    elseif self.hitMaxNum ~= 0 and self.hitNum >= self.hitMaxNum then
        self:SetRemove(true)
    else
        self:SetNextHitIndex()
    end
end

function CryLinkHitEntityBehavior:FindNextTarget()
    local probArgs = {prob = self.actionParam.prob}
    local flag = self.world.PluginSystem.CheckCond:Prob(nil,probArgs)
    if not flag then
        return nil
    end

    local searchParams = self.world.BattleCastSkillSystem.skillSearchParams
    searchParams.entity = self.entity
    searchParams.range = self.skill:GetHitRange()
    -- LogTable("skillId "..self.skill.skillId.." skillLev "..self.skill.skillLev.." range",self.skill:GetHitRange())
    searchParams.transInfo = {}
    searchParams.transInfo.posX = self.hitPos.x
    searchParams.transInfo.posZ = self.hitPos.z
    searchParams.passEntitys = self.hitTargets
    searchParams.targetNum = 1
    searchParams.priorityType1 = BattleDefine.SearchPriority.random
   

    local hitEntitys,_ = self.world.BattleCastSkillSystem:SkillSearchEntity(self.skill,searchParams)
    return hitEntitys[1]
end

function CryLinkHitEntityBehavior:Attack()
    local hitEntity = self.world.EntitySystem:GetEntity(self.hitTargetUid)
    if not hitEntity then
        return
    end

    if self.actionParam.canRepeateLink then
        self.hitTargets = {}
    end
    self.hitTargets[self.hitTargetUid] = true
    self.hitPos:SetByFPVector3(hitEntity.TransformComponent:GetPos())

    local hitInfo = self:GetHitInfo()
    local hitUid = hitInfo.hitUid
    local hitEffectId = hitInfo.hitEffectId
    -- local hitArgs = {skillId = self.skill.skillId,skillLev = self.skill.skillLev,hitUid = hitUid}
    -- local hitResultId = self.skill:GetHitResultId(hitUid)
    -- self.world.BattleAssetsSystem:PlayHitEffect(self.hitTargetUid,self:GetHitInfo().hitEffectId)
    -- self.world.BattleHitSystem:HitResult(BattleDefine.HitFrom.skill,self.entity.ownerUid,hitEntity.uid,hitResultId,hitArgs)
    self:HitEntitys({self.hitTargetUid},hitUid,hitEffectId)

    self:PlayCryLinkEffect(hitEntity)
end

function CryLinkHitEntityBehavior:PlayCryLinkEffect(entity)
    if not self.world.opts.isClient or self:GetHitInfo().effectId == 0 then
        return
    end

    local targetPos,_ = self.world.ClientIFacdeSystem:Call("GetBoneTransInfo",entity,GDefine.Bone.chest)

    if self.isFirstPlayEffect and self.world.EntitySystem:HasEntity(self.entity.ownerUid) then
        self.isFirstPlayEffect = false
        self.world.BattleAssetsSystem:PlayStretchEffect(self.entity.ownerUid,entity.uid,self:GetHitInfo().effectId)
    else
        local diff = targetPos - self.lastHitRenderPos

        local effect = self.world.BattleAssetsSystem:PlaySimpleEffect(self:GetHitInfo().effectId,BattleDefine.nodeObjs["effect"],true)
        effect:SetPos(self.lastHitRenderPos.x,self.lastHitRenderPos.y,self.lastHitRenderPos.z)
        effect.transform.forward = diff.normalized
        effect.transform:SetLocalScale(1,1,diff.magnitude)
    end

    self.lastHitRenderPos = targetPos
end

function CryLinkHitEntityBehavior:SetNextHitIndex()
    -- if self.hitIndex + 1 <= #self.actionParam.hitInfo then
        self.hitIndex = self.hitIndex + 1
    -- end
    local stepTime = self:GetHitInfo().stepTime or 200
    self.nextHitTime = self.nextHitTime + stepTime
end

function CryLinkHitEntityBehavior:GetHitInfo()
    for i, v in ipairs(self.hitInfo) do
        if v.maxCount > self.hitIndex then
            return v
        end
    end
end