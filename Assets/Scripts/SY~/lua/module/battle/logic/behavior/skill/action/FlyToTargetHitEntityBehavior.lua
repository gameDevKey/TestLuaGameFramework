FlyToTargetHitEntityBehavior = BaseClass("FlyToTargetHitEntityBehavior",SkillBehavior)
--TODO:仔细检查是否会受到渲染影响,
--TODO:缓存清理
function FlyToTargetHitEntityBehavior:__Init()
    self.flyEffectUid = nil
    self.targetEntityUid = nil
    self.skillTimelinePack = nil
end

function FlyToTargetHitEntityBehavior:__Delete()
    self:RemoveFlyEffect()
end

function FlyToTargetHitEntityBehavior:OnInit(targetUid,targetPos)
    self.skill:AddRefNum(1)


    --local targetEntity = self.world.EntitySystem:GetEntity(targetUid)
    self.targetEntityUid = targetUid
    self.targetPos = targetPos

    self:PlayFlyEffect()

    --
    --local targetPos = targetEntity.TposeComponent:GetPos()

    -- self.entity.RotateComponent:LookAtPos(targetPos.x,targetPos.z)

    self:CreateTimeline()

    local ownerEntity = self.world.EntitySystem:GetEntity(self.entity.ownerUid)

    local info = {}
    info.onComplete = self:ToFunc("MoveComplete")
    info.params = {targetUid = self.targetEntityUid,targetPos = self.targetPos, speed = self.actionParam.flySpeed,logicPos = ownerEntity.TransformComponent:GetPos()}
    info.moverType = BattleDefine.MoverType.fly_hit_lock_mover

    self.entity.MoveComponent:MoveToPos(0,0,0,info)
end

function FlyToTargetHitEntityBehavior:CreateTimeline()
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

function FlyToTargetHitEntityBehavior:PlayFlyEffect()
    if self.actionParam.flyEffectId == 0 or not self.world.opts.isClient then
        return
    end

    local parent = self.entity.clientEntity.ClientTransformComponent.transform:Find("tpose")
    local flyEffect = self.world.BattleAssetsSystem:PlaySimpleEffect(self.actionParam.flyEffectId,parent,false)
    if not flyEffect then
        return
    end

    self.flyEffectUid = flyEffect.uid

    local ownerEntity = self.world.EntitySystem:GetEntity(self.entity.ownerUid)

    local boneRenderPos,_ = self.world.ClientIFacdeSystem:Call("GetBoneTransInfo",ownerEntity,flyEffect.conf.bone,flyEffect.conf.custom_bone,flyEffect.conf.offset_pos)

    self.entity.clientEntity.ClientTransformComponent.transform:SetParent(BattleDefine.nodeObjs["entity"])
    self.entity.clientEntity.ClientTransformComponent.transform:SetLocalPosition(boneRenderPos.x,boneRenderPos.y,boneRenderPos.z)

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

function FlyToTargetHitEntityBehavior:RemoveFlyEffect()
    if self.flyEffectUid then
        self.world.BattleAssetsSystem:RemoveEffect(self.flyEffectUid)
		self.flyEffectUid = nil
	end
end

--移动完成
function FlyToTargetHitEntityBehavior:MoveComplete()
    if not self.SkillTimelinePack and self.skill.baseConf.lock_target == 1 and self.targetEntityUid then
        self:HitEntitys({self.targetEntityUid})
        self:SetRemove(true)
        return
    end

    local targetPos = nil
    if self.targetEntityUid then
        local lockTargetEntity = self.world.EntitySystem:GetEntity(self.targetEntityUid)
        if lockTargetEntity then
            targetPos = lockTargetEntity.TransformComponent:GetPos()
        else
            targetPos = self.world.EntitySystem:GetRefPos(self.targetEntityUid)
        end
    else
        targetPos = FPVector3(self.targetPos.posX,self.targetPos.posY or 0,self.targetPos.posZ)
    end

    if self.SkillTimelinePack then
        local transInfo = {posX = targetPos.x,posZ = targetPos.z}
        self.SkillTimelinePack:Start({self.targetEntityUid},transInfo)
    else
        local searchParams = self.world.BattleCastSkillSystem.skillSearchParams
        searchParams.entity = self.entity
        searchParams.range = self.skill:GetHitRange()
        searchParams.targetNum = self.skill:GetHitNum()
        searchParams.transInfo = {}
        searchParams.transInfo.posX = targetPos.x
        searchParams.transInfo.posZ = targetPos.z

        local hitEntitys,_ = self.world.BattleCastSkillSystem:SkillSearchEntity(self.skill,searchParams)
        self:HitEntitys(hitEntitys)
        self:SetRemove(true)
    end

    self.world.BattleAssetsSystem:PlaySceneEffect(self.actionParam.targetPosEffectId,targetPos.x,targetPos.y,targetPos.z)
end

function FlyToTargetHitEntityBehavior:TimelineComplete()
    self:SetRemove(true)
end