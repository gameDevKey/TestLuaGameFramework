BouncingBulletEntityBehavior = BaseClass("BouncingBulletEntityBehavior",SkillBehavior)
--TODO:缓存清理
function BouncingBulletEntityBehavior:__Init()
    self.hitTargets = {}
    self.hitNum = 0
end

function BouncingBulletEntityBehavior:__Delete()
    self:RemoveBouncingEffect()
end

function BouncingBulletEntityBehavior:OnInit(targetUid)
    self.skill:AddRefNum(1)

    local targetEntity = self.world.EntitySystem:GetEntity(targetUid)
    if not targetEntity then
        self:SetRemove(true)
        return
    end

    self.targetEntityUid = targetUid

    self.hitTargets = {}
    self.hitNum = 0
    self.hitMaxNum = self.skill:GetHitNum()
    self.hitArgs = self.actionParam.hitArgs

    self:CreateTimeline()

    local ownerEntity = self.world.EntitySystem:GetEntity(self.entity.ownerUid)
    self.lastTargetPos = ownerEntity.TransformComponent:GetPos()
    self:BounceToNextTarget()
end

function BouncingBulletEntityBehavior:CreateTimeline()
    if not self.actionParam or self.actionParam.actId == 0 then
        return
    end

    local actConf = self.skill.actConf.Child[self.actionParam.actId]
    if not actConf then
        assert(false,string.format("找不到技能行为子配置[技能ID:%s][技能等级:%s][子行为Id:%s]",self.skill.skillId,self.skill.skillLev,tostring(self.actionParam.actId)))
    end

    self:AddBehaviorPack(SkillTimelinePack)
    self.SkillTimelinePack:Init(actConf,self.entity,self.skill,self:ToFunc("TimelineComplete"))
end

function BouncingBulletEntityBehavior:BounceToNextTarget()
    if self.hitNum >= self.hitMaxNum then
        self:BounceEnd()
        return
    end
    self.hitNum = self.hitNum + 1

    self.hitTargets[self.targetEntityUid] = true

    local targetEntity = self.world.EntitySystem:GetEntity(self.targetEntityUid)
    self.targetPos = targetEntity.TransformComponent:GetPos()

    self:PlayBouncingEffect()

    local speed = self.hitArgs[self.hitNum].speed

    local info = {}
    info.onComplete = self:ToFunc("BounceComplete")
    info.params = {targetUid = self.targetEntityUid,targetPos = self.targetPos, speed = speed,logicPos = self.lastTargetPos}
    info.moverType = BattleDefine.MoverType.fly_hit_lock_mover

    self.entity.MoveComponent:MoveToPos(0,0,0,info)
end

function BouncingBulletEntityBehavior:PlayBouncingEffect()
    local bouncingEffectId = self.hitArgs[self.hitNum].bouncingEffectId
    if bouncingEffectId == 0 or not self.world.opts.isClient then
        return
    end

    if self.bouncingEffectUid then
        self:RemoveBouncingEffect()
    end
    local parent = self.entity.clientEntity.ClientTransformComponent.transform:Find("tpose")
    local bouncingEffect = self.world.BattleAssetsSystem:PlaySimpleEffect(bouncingEffectId,parent,false)
    if not bouncingEffect then
        return
    end
    self.bouncingEffectUid = bouncingEffect.uid

    local boneRenderEntity = nil
    if self.hitNum == 1 then
        boneRenderEntity = self.world.EntitySystem:GetEntity(self.entity.ownerUid)
    else
        boneRenderEntity = self.world.EntitySystem:GetEntity(self.lastTargetEntityUid)
    end

    local boneRenderPos = nil
    if boneRenderEntity then
        boneRenderPos,_ = self.world.ClientIFacdeSystem:Call("GetBoneTransInfo",boneRenderEntity,bouncingEffect.conf.bone,bouncingEffect.conf.custom_bone,bouncingEffect.conf.offset_pos)
    else
        boneRenderPos = self.world.EntitySystem:GetRefPos(self.lastTargetEntityUid)
    end

    self.entity.clientEntity.ClientTransformComponent.transform:SetParent(BattleDefine.nodeObjs["entity"])
    self.entity.clientEntity.ClientTransformComponent.transform:SetLocalPosition(boneRenderPos.x,boneRenderPos.y,boneRenderPos.z)  -- 表现起始点

    local renderPos = self.entity.clientEntity.ClientTransformComponent:GetPos()
    local pos = FPVector3(0,0,0)
    FPMath.ToFPVector3(renderPos,pos)
    self.entity.TransformComponent:SetPos(pos.x,pos.y,pos.z)


    local renderRotation = self.entity.clientEntity.ClientTransformComponent:GetRotation()
    local rotation = FPQuaternion(0,0,0,0)
    FPMath.ToFPQuaternion(renderRotation,rotation)
    self.entity.TransformComponent:SetRotation(rotation)

    self.entity.clientEntity.ClientTransformComponent:SyncPos()
end

function BouncingBulletEntityBehavior:BounceComplete()
    self.lastTargetEntityUid = self.targetEntityUid
    local targetEntity = self.world.EntitySystem:GetEntity(self.lastTargetEntityUid)
    if targetEntity then
        self.lastTargetPos = targetEntity.TransformComponent:GetPos()
    else
        self.lastTargetPos = self.world.EntitySystem:GetRefPos(self.lastTargetEntityUid)
    end

    local hitUid = self.hitArgs[self.hitNum].hitUid
    local hitEffectId = self.hitArgs[self.hitNum].hitEffectId
    self:HitEntitys({self.targetEntityUid},hitUid,hitEffectId)

    -- 寻找新目标
    self.targetEntityUid = self:FindNextTarget()
    if self.targetEntityUid then
        self:BounceToNextTarget()
    else
        self:BounceEnd()
    end
end

function BouncingBulletEntityBehavior:FindNextTarget()
    --TODO:加上方向dirX
    local searchParams = self.world.BattleCastSkillSystem.skillSearchParams
    searchParams.entity = self.entity
    searchParams.range = self.skill:GetHitRange()
    searchParams.transInfo = {}
    searchParams.transInfo.posX = self.lastTargetPos.x
    searchParams.transInfo.posZ = self.lastTargetPos.z
    searchParams.passEntitys = self.hitTargets
    searchParams.targetNum = 1
    searchParams.priorityType1 = BattleDefine.SearchPriority.random

    local hitEntitys,_ = self.world.BattleCastSkillSystem:SkillSearchEntity(self.skill,searchParams)
    return hitEntitys[1]
end

function BouncingBulletEntityBehavior:BounceEnd()
    if not self.SkillTimelinePack then
        self:SetRemove(true)
        return
    end

    local targetPos = nil
    if self.lastTargetEntityUid then
        local lastTargetEntity = self.world.EntitySystem:GetEntity(self.lastTargetEntityUid)
        if lastTargetEntity then
            targetPos = lastTargetEntity.TransformComponent:GetPos()
        else
            targetPos = self.world.EntitySystem:GetRefPos(self.lastTargetEntityUid)
        end
    else
        targetPos = FPVector3(self.lastTargetPos.x,self.lastTargetPos.y or 0,self.lastTargetPos.z)
    end

    local transInfo = {posX = targetPos.x,posZ = targetPos.z}
    self.SkillTimelinePack:Start({self.lastTargetEntityUid},transInfo)
end

function BouncingBulletEntityBehavior:TimelineComplete()
    self:SetRemove(true)
end

function BouncingBulletEntityBehavior:RemoveBouncingEffect()
    if self.bouncingEffectUid then
        self.world.BattleAssetsSystem:RemoveEffect(self.bouncingEffectUid)
		self.bouncingEffectUid = nil
	end
end