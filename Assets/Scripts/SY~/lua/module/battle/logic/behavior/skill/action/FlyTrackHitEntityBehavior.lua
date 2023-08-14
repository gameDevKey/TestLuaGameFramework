FlyTrackHitEntityBehavior = BaseClass("FlyTrackHitEntityBehavior",SkillBehavior)
--TODO:仔细检查是否会受到渲染影响,
function FlyTrackHitEntityBehavior:__Init()
    self.targetEntityUid = nil

    self.flyEffectUids = {}

    self.firstFlag = true
    self.targetPos = nil
    --已命中过的目标
    self.hitTargets = {}
    self.backComplete = false
    self.isPlayingAnim = false
    self.endActionTime = 0

    self.stageDefine =
    {
        none   = 0,  -- 未开始
        first  = 1,  -- 第一段飞行
        second = 2,  -- 第二段飞行
        back   = 3,  -- 返回飞行
    }

    self.stage = self.stageDefine.none
end

function FlyTrackHitEntityBehavior:__Delete()
    self:RemoveFlyEffect()
end

function FlyTrackHitEntityBehavior:OnInit(targetUid)
    self.skill:AddRefNum(1)
    --
    if targetUid then
        local targetEntity = self.world.EntitySystem:GetEntity(targetUid)
        self.targetPos = targetEntity.TransformComponent:GetPos()
        self.targetEntityUid = targetEntity.uid
    end

    self:InitPos()
    if not self.actionParam.canRelSkill then
        self.lockUid = self.timeline:Lock()
    end
    self:PlayFlyEffect(self.actionParam.fstFlyEffectId)
end

function FlyTrackHitEntityBehavior:InitPos()
    self.ownerEntity = self.world.EntitySystem:GetEntity(self.entity.ownerUid)
    self.ownerPos = self.ownerEntity.TransformComponent:GetPos()
    self.lastOwnerEnitytPos = {}
    self.lastOwnerEnitytPos.x = self.ownerPos.x
    self.lastOwnerEnitytPos.y = self.ownerPos.y
    self.lastOwnerEnitytPos.z = self.ownerPos.z
    self.ownerForward = self.ownerEntity.TransformComponent:GetForward()
    local offset = self.actionParam.transform
    local truePos = FPMath.Transform(FPVector3(offset[1],offset[2],offset[3]), self.ownerForward, self.ownerPos)
    self.entity.TransformComponent:SetPos(truePos.x,truePos.y,truePos.z)

    self.stage = self.stageDefine.first

    self.firstEndPos = self:GetFirstEndPos()
    local info = {}
    info.onComplete = self:ToFunc("OnFirstFlyComplete")
    info.params = {speed = self.actionParam.firstFlySpeed}
    info.moverType = BattleDefine.MoverType.linera
    self.entity.MoveComponent:MoveToPos(self.firstEndPos.x,self.firstEndPos.y,self.firstEndPos.z,info)
end

function FlyTrackHitEntityBehavior:GetFirstEndPos()
    local endPos = {}
    if self.actionParam.distanceType == 1 and not self.targetPos then
        assert(false,"节点飞行轨迹命中[fly_track_hit]配置根据目标位置设置飞行距离但没有获取到目标实体,请检查是否配置了可空放")
    end

    if self.actionParam.distanceType == 1 then  -- 1:根据目标位置设置飞行距离
        endPos.x = self.targetPos.x
        endPos.y = self.targetPos.y
        endPos.z = self.targetPos.z
    end

    local to = next(endPos) ~= nil and endPos - self.ownerPos or nil
    local distance = to and to.magnitude
    local minDis = self.actionParam.flyDistance
    if not self.actionParam.distanceType then
        assert(false,string.format("单位[uid:%s][unitId:%s]的飞行轨迹命中技能节点没有配置[distanceType]字段",self.ownerEntity.uid,self.ownerEntity.ObjectDataComponent.unitConf.id))
    end

    if self.actionParam.distanceType == 2 or distance < minDis then  -- 2:固定飞行距离 或 小于最小保护距离
        endPos.x = FPFloat.Mul_ii(self.ownerForward.x, minDis) + self.ownerPos.x
        endPos.y = FPFloat.Mul_ii(self.ownerForward.y, minDis) + self.ownerPos.y
        endPos.z = FPFloat.Mul_ii(self.ownerForward.z, minDis) + self.ownerPos.z
    end
    return endPos
end

function FlyTrackHitEntityBehavior:OnUpdate()
    if self.stage == self.stageDefine.back then
        if not self.isPlayingAnim then
            if self.actionParam.lockBack then
                local ownerEntityPos = self.ownerEntity.TransformComponent:GetPos()
                if ownerEntityPos.x ~= self.lastOwnerEnitytPos.x
                    or ownerEntityPos.y ~= self.lastOwnerEnitytPos.y
                    or ownerEntityPos.z ~= self.lastOwnerEnitytPos.z then
                        self.lastOwnerEnitytPos = {}
                        self.lastOwnerEnitytPos.x = ownerEntityPos.x
                        self.lastOwnerEnitytPos.y = ownerEntityPos.y
                        self.lastOwnerEnitytPos.z = ownerEntityPos.z
                        local info = {}
                        info.params = {speed = self.actionParam.backFlySpeed}
                        info.moverType = BattleDefine.MoverType.linera
                        self.entity.MoveComponent:MoveToPos(ownerEntityPos.x,ownerEntityPos.y,ownerEntityPos.z,info)
                end
            end
            local transInfo = {posX = self.lastOwnerEnitytPos.x,posZ = self.lastOwnerEnitytPos.z}
            local range = {type = BattleDefine.RangeType.circle, appendModel = true, radius = self.actionParam.overRadius or self.skill:GetHitRange().radius}
            local isInRange = self.world.BattleSearchSystem:InRangeEntity(self.ownerEntity,self.entity,transInfo,range)
            if isInRange then
                self:PlayOverAnim()
            end
        else
            self.endActionTime = self.endActionTime + self.world.opts.frameDeltaTime
            if self.endActionTime >= self.actionParam.overTime then
                if self.lockUid then
                    self.lockUid = self.timeline:Unlock(self.lockUid)
                end
                self:SetRemove(true)
            end
            return
        end
    end

    local searchParams = self.world.BattleCastSkillSystem.skillSearchParams
    searchParams.entity = self.entity
    searchParams.range = self.skill:GetHitRange()
    searchParams.targetNum = self.skill:GetHitNum()
    searchParams.transInfo = {}
    searchParams.transInfo.posX = self.entity.TransformComponent:GetPos().x
    searchParams.transInfo.posZ = self.entity.TransformComponent:GetPos().z
    searchParams.passEntitys = self.hitTargets

    local hitEntitys,_ = self.world.BattleCastSkillSystem:SkillSearchEntity(self.skill,searchParams)
    self:Attack(hitEntitys)
end

function FlyTrackHitEntityBehavior:Attack(hitEntitys)
    if TableUtils.IsEmpty(hitEntitys) then
        return
    end
    local hitUid = nil
    local hitEffectId = nil
    if self.stage == self.stageDefine.first then
        hitUid = self.actionParam.hitUid.first
        hitEffectId = self.actionParam.fstHitEffectId
    elseif self.stage == self.stageDefine.second then
        hitUid = self.actionParam.hitUid.second
        hitEffectId = self.actionParam.sndHitEffectId
    elseif self.stage == self.stageDefine.back then
        hitUid = self.actionParam.hitUid.back
        hitEffectId = self.actionParam.backHitEffectId
    end

    if self.firstFlag and self.stage == self.stageDefine.first then
        self.firstFlag = false
        local firstHitEntity = table.remove(hitEntitys,1)
        self:HitEntitys({firstHitEntity},hitUid,hitEffectId)
        self.hitTargets[firstHitEntity] = true

        if self.actionParam.hitSecondFlyImmediately then
            self:ChangeToSecondStage()
            return
        end
    end

    if TableUtils.IsValid(hitEntitys) then
        self:HitEntitys(hitEntitys,hitUid,hitEffectId)
        for i,hitEntity in ipairs(hitEntitys) do
            self.hitTargets[hitEntity] = true
        end
    end
end

function FlyTrackHitEntityBehavior:ChangeToSecondStage()
    self.stage = self.stageDefine.second
    local secondFlyDis = self.actionParam.secondFlyDistance
    if not secondFlyDis or secondFlyDis == 0 then
        self:ChangeToBackStage()
        return
    end
    local endPos = {}
    if secondFlyDis < 0 then
        endPos = self.firstEndPos
    else
        local curPos = self.entity.TransformComponent:GetPos()
        local forward = self.entity.TransformComponent:GetForward()
        endPos.x = FPFloat.Mul_ii(forward.x, secondFlyDis) + curPos.x
        endPos.y = FPFloat.Mul_ii(forward.y, secondFlyDis) + curPos.y
        endPos.z = FPFloat.Mul_ii(forward.z, secondFlyDis) + curPos.z
    end

    local info = {}
    info.onComplete = self:ToFunc("OnSecondFlyComplete")
    info.params = {speed = self.actionParam.secondFlySpeed}
    info.moverType = BattleDefine.MoverType.linera

    self.entity.MoveComponent:MoveToPos(endPos.x,endPos.y,endPos.z,info)

    self:PlayFlyEffect(self.actionParam.sndFlyEffectId)
end

function FlyTrackHitEntityBehavior:ChangeToBackStage()
    if not self.actionParam.shuttle then
        if self.lockUid then
            self.timeline:Unlock(self.lockUid)
        end
        self:SetRemove(true)
        return
    end
    self.stage = self.stageDefine.back
    self.hitTargets = {}
    local info = {}
    info.onComplete = self:ToFunc("OnBackFlyComplete")
    info.params = {speed = self.actionParam.backFlySpeed}
    info.moverType = BattleDefine.MoverType.linera
    self.entity.MoveComponent:MoveToPos(self.lastOwnerEnitytPos.x,self.lastOwnerEnitytPos.y,self.lastOwnerEnitytPos.z,info)
    self:PlayFlyEffect(self.actionParam.backFlyEffectId)
end

function FlyTrackHitEntityBehavior:OnFirstFlyComplete()
    self:ChangeToSecondStage()
end

function FlyTrackHitEntityBehavior:OnSecondFlyComplete()
    self:ChangeToBackStage()
end

function FlyTrackHitEntityBehavior:OnBackFlyComplete()
    self:RemoveFlyEffect()
    if not self.actionParam.lockBack then
        if self.lockUid then
            self.timeline:Unlock(self.lockUid)
        end
        self:SetRemove(true)
    end
end

function FlyTrackHitEntityBehavior:PlayFlyEffect(effectId)
    if effectId == 0 or not self.world.opts.isClient then
        return
    end

    local parent = self.entity.clientEntity.ClientTransformComponent.transform:Find("tpose")
    local flyEffect = self.world.BattleAssetsSystem:PlaySimpleEffect(effectId,parent,false)
    if not flyEffect then
        return
    end
    self:RemoveFlyEffect()
    self.flyEffectUids[self.stage] = flyEffect.uid
end

function FlyTrackHitEntityBehavior:PlayOverAnim()
    if self.ownerEntity.StateComponent:IsState(BattleDefine.EntityState.die) then
        return
    end
    if self.isPlayingAnim then
        return
    end

    self.entity.MoveComponent:StopMove()
    self:RemoveFlyEffect()

    if self.actionParam.overTime and self.actionParam.overTime > 0 then
        self.isPlayingAnim = true
        self.ownerEntity.AnimComponent:PlayAnim(self.actionParam.overAnim)
    else
        if self.lockUid then
            self.lockUid = self.timeline:Unlock(self.lockUid)
        end
        self:SetRemove(true)
    end
end

function FlyTrackHitEntityBehavior:RemoveFlyEffect()
    for k, v in pairs(self.flyEffectUids) do
        self.world.BattleAssetsSystem:RemoveEffect(v)
        self.flyEffectUids[k] = nil
    end
    self.flyEffectUids = {}
end