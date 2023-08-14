LoopLinkHitEntityBehavior = BaseClass("LoopLinkHitEntityBehavior",SkillBehavior)

function LoopLinkHitEntityBehavior:__Init()
    self.targetEntityUid = nil

    self.hitTime = 0     -- 命中时间点
    self.nextHitTime = 0 -- 下次命中时间点
    self.hitIndex = 0    -- 命中索引

    self.lineEffectUid = nil

    self.waitOvering = false
    self.waitOverTime = 0

    
    self.lockUid = nil
end

function LoopLinkHitEntityBehavior:__Delete()
    self:RemoveLineEffect()
    if self.lockUid then
        self.timeline:Unlock(self.lockUid)
    end
end

function LoopLinkHitEntityBehavior:OnInit(targetUid)
    self.skill:AddRefNum(1)
    if self.actionParam.bind then
        self.lockUid = self.timeline:Lock()
    end

    self.targetEntityUid = targetUid
    self:SetNextHitIndex()
    self:PlayLinkEffect()
end

function LoopLinkHitEntityBehavior:OnUpdate()
    local entity = self.world.EntitySystem:GetEntity(self.entity.ownerUid)
    if not entity then
        self:SetRemove(true)
        return
    end

    if self.waitOvering then
        self.waitOverTime = self.waitOverTime + self.world.opts.frameDeltaTime
        if self.waitOverTime >= self.actionParam.overTime then
            self:SetRemove(true)
        end
        return
    end

    if self:CheckRemove() then
        self:RemoveLineEffect()
        if self.actionParam.overAnim ~= "" then
            self.waitOvering = true
            entity.AnimComponent:PlayAnim(self.actionParam.overAnim)
        else
            self:SetRemove(true)
        end
        return
    end

    if self.actionParam.lookTarget then
        local targetEntity = self.world.EntitySystem:GetEntity(self.targetEntityUid)
        entity.RotateComponent:LookAtTarget(targetEntity)
    end

    self.hitTime = self.hitTime + self.world.opts.frameDeltaTime
    if self.hitTime < self.nextHitTime then
        return
    end

    self:DoSkillHit()
    self:SetNextHitIndex()
end

function LoopLinkHitEntityBehavior:SetNextHitIndex()
    if self.hitIndex + 1 <= #self.levParam.hitSteps then
        self.hitIndex = self.hitIndex + 1
    elseif not self.actionParam.loop then
        self:SetRemove(true)
    end
    self.nextHitTime = self.nextHitTime + self.levParam.hitSteps[self.hitIndex][2]
end

function LoopLinkHitEntityBehavior:PlayLinkEffect(entity)
    if not self.world.opts.isClient then
        return
    end

    local effect = self.world.BattleAssetsSystem:PlayStretchEffect(self.entity.ownerUid,self.targetEntityUid,self.levParam.linkEffectId)
    self.lineEffectUid = effect.uid
end

function LoopLinkHitEntityBehavior:CheckRemove()
    local targetEntity = self.world.EntitySystem:GetEntity(self.targetEntityUid)
    if not targetEntity or not self.world.EntitySystem:HasEntity(self.targetEntityUid) then
        return true
    end

    local entity = self.world.EntitySystem:GetEntity(self.entity.ownerUid)
    if self.world.PluginSystem.EntityStateCheck:IsControlState(entity) then
        return true
    end

    local selfEntityPos = entity.TransformComponent:GetPos()
    local selfEntityForward = entity.TransformComponent:GetForward()
    local transInfo = {}
    transInfo.posX = selfEntityPos.x
    transInfo.posZ = selfEntityPos.z
    transInfo.dirX = selfEntityForward.x
    transInfo.dirZ = selfEntityForward.z
    local range = {type = BattleDefine.RangeType.circle,radius = self.levParam.exitRadius}
    if not self.world.BattleSearchSystem:InRangeEntity(entity,targetEntity,transInfo,range) then
        return true
    end

    return false
end

function LoopLinkHitEntityBehavior:DoSkillHit()
    self:HitEntitys({self.targetEntityUid},self.levParam.hitSteps[self.hitIndex][1])
end

function LoopLinkHitEntityBehavior:RemoveLineEffect()
    if self.lineEffectUid then
        self.world.BattleAssetsSystem:RemoveEffect(self.lineEffectUid)
		self.lineEffectUid = nil
	end
end