ChargeCollidesContinuouslyBehavior = BaseClass("ChargeCollidesContinuouslyBehavior",SkillBehavior)

function ChargeCollidesContinuouslyBehavior:__Init()
    self.mainTargetEntityUid = nil
    self.mainTargetEntity = nil
    self.targetEntityUids = {}
    self.tempTargetEntitys = nil
    self.lastTargetList = nil
    self.lastTargetFlag = nil

    self.hitCount = 0
    self.hitStep = 0
    self.hitTime = 0

    self.endActionTime = 0

    self.isPlayingAnim = false

    self.stageDefine = {
        none     = 0,  -- 初始化
        charge   = 1,  -- 冲锋中
        collides = 2,  -- 撞击击退中
        overAnim = 3,  -- 结束动作
    }

    self.stage = self.stageDefine.none
    self.lockUid = nil
end

function ChargeCollidesContinuouslyBehavior:__Delete()
    self.lastTargetList:Delete()
end

function ChargeCollidesContinuouslyBehavior:OnInit(targetEntitys)
    self.skill:AddRefNum(1)
    self.mainTargetEntityUid = targetEntitys[1]

    self.acceleration = self.actionParam.acceleration
    self.maxSpeed = self.actionParam.maxSpeed
    self.hitStep = self.actionParam.hitStep
    self.hitDistance = self.actionParam.hitDistance
    self.hitMaxCount = self.actionParam.hitMaxCount
    self.hitEffectId = self.actionParam.hitEffectId
    self.overAnim = self.actionParam.overAnim
    self.overTime = self.actionParam.overTime

    self.speedTotalAdd = 0
    self.moveOffset = nil

    self.lastTargetList = SECBList.New()
    self.lastTargetFlag = {}

    self.stage = self.stageDefine.charge
    self.lockUid = self.timeline:Lock()
    self:PlayMoveAnim()

    self.entity.TransformComponent:AddMoveListener(self:ToFunc("OnSelfTransform"))

    local eventArgs = {}
    eventArgs.entityUid = self.entity.uid
    self:AddEvent(BattleEvent.do_control,self:ToFunc("OnDoControl"),eventArgs)
end

function ChargeCollidesContinuouslyBehavior:OnSelfTransform()
    local pos = self.entity.TransformComponent:GetPos()
    local lastPos = self.entity.TransformComponent.lastPos
    local offset = pos - lastPos
    self.moveOffset = offset
end

function ChargeCollidesContinuouslyBehavior:OnDoControl()
    self:OnAnimComplete()
end

function ChargeCollidesContinuouslyBehavior:OnUpdate()
    if self.stage == self.stageDefine.charge then
        if not self:IsMainTargetValid() then
            local targetEntitys = self:SearchTarget(true)
            self.mainTargetEntityUid = targetEntitys[1]
            if not self:IsMainTargetValid() then
                self:OnCollidesComplete()
                return
            end
        end
        self:OnCharge()
        if self:OtherTargetInRange() then
            if self.actionParam.stopAfterCollides then
                self.mainTargetEntityUid = self.tempTargetEntitys[1]
                self:ChangeStage()
                return
            else
                if self:IsMainTargetInRange() then
                    self:ChangeStage()
                    return
                else
                    for i, entityUid in ipairs(self.tempTargetEntitys) do
                        table.insert(self.targetEntityUids,entityUid)
                    end
                    self.tempTargetEntitys = nil
                    self:CarryTargetEntitys()
                end
            end
        end
    elseif self.stage == self.stageDefine.collides then
        -- local targetPos = self.mainTargetEntity.TransformComponent:GetPos()
        -- self.entity.MoveComponent:MoveToPos(targetPos.x,targetPos.y,targetPos.z,{})
        self.targetEntityUids = self:SearchTarget(false)
        self:CarryTargetEntitys()
        self.hitTime = self.hitTime + self.world.opts.frameDeltaTime
        if self.hitTime < self.hitStep then
            return
        end
        self:OnCollides()
    elseif self.stage == self.stageDefine.overAnim then
        self.endActionTime = self.endActionTime + self.world.opts.frameDeltaTime
        if self.endActionTime >= self.actionParam.overTime then
            self:OnAnimComplete()
        end
    end
end

function ChargeCollidesContinuouslyBehavior:IsMainTargetValid()
    self.mainTargetEntity = self.world.EntitySystem:GetEntity(self.mainTargetEntityUid)
    return self.mainTargetEntity ~= nil
            and not self.mainTargetEntity.StateComponent:IsState(BattleDefine.EntityState.die)
            and not self.mainTargetEntity.BuffComponent:HasBuffState(BattleDefine.BuffState.not_be_select)
end

function ChargeCollidesContinuouslyBehavior:IsMainTargetInRange()
    local selfPos = self.entity.TransformComponent:GetPos()
    local mainTargetPos = self.mainTargetEntity.TransformComponent:GetPos()

    local r1 = self.actionParam.collidesRange or FPMath.Divide(self.entity.CollistionComponent:GetRadius(), 2)
    local r2 = FPMath.Divide(self.mainTargetEntity.CollistionComponent:GetRadius(), 2)
    local range = r1 + r2

    return BattleUtils.CalMagnitude(selfPos.x,selfPos.z,mainTargetPos.x,mainTargetPos.z) <= range
end

function ChargeCollidesContinuouslyBehavior:OtherTargetInRange()
    local targetEntitys = self:SearchTarget(false)
    if targetEntitys and #targetEntitys > 0 then
        self.tempTargetEntitys = targetEntitys
        return true
    else
        return false
    end
end

function ChargeCollidesContinuouslyBehavior:SearchTarget(isMain)
    local centerPos = self.entity.TransformComponent:GetPos()
    local forward = self.entity.TransformComponent:GetForward()
    local searchParams = {}
    searchParams.entity = self.entity
    local collidesRange = {}
    collidesRange.type=BattleDefine.RangeType.circle
    collidesRange.radius= self.actionParam.collidesRange or self.entity.CollistionComponent:GetRadius()
    searchParams.range = isMain and self.skill:GetAtkRange() or collidesRange
    searchParams.transInfo = {}
    searchParams.transInfo.posX = centerPos.x
    searchParams.transInfo.posZ = centerPos.z
    searchParams.transInfo.dirX = forward.x
    searchParams.transInfo.dirZ = forward.z
    searchParams.targetNum = isMain and 1 or 0
    searchParams.priorityType1 = BattleDefine.SearchPriority.min_to_self_dis
    searchParams.isLock = true

    local targetEntitys,_ = self.world.BattleCastSkillSystem:SkillSearchEntity(self.skill,searchParams)
    return targetEntitys
end

function ChargeCollidesContinuouslyBehavior:ChangeStage()
    self.stage = self.stageDefine.collides

    local endPos = {}
    local curPos = self.entity.TransformComponent:GetPos()
    local forward = self.entity.TransformComponent:GetForward()
    endPos.x = FPFloat.Mul_ii(forward.x, self.hitDistance) + curPos.x
    endPos.y = FPFloat.Mul_ii(forward.y, self.hitDistance) + curPos.y
    endPos.z = FPFloat.Mul_ii(forward.z, self.hitDistance) + curPos.z

    local fixX,fixZ = self.world.BattleTerrainSystem:PosFix(self.entity,endPos.x,endPos.z)
    endPos.x = fixX
    endPos.z = fixZ

    self.entity.MoveComponent:MoveToPos(endPos.x,endPos.y,endPos.z,{
        onComplete = self:ToFunc("OnCollidesComplete")
    })
end

function ChargeCollidesContinuouslyBehavior:OnCharge()
    self:TryMarkState(true)
    local speed = self.entity.AttrComponent:GetValue(GDefine.Attr.move_speed)
    if self.acceleration > 0 and (not self.maxSpeed or speed < self.maxSpeed) then
        local addSpeed = FPFloat.Mul_ii(self.acceleration, self.world.opts.frameDeltaTime)
        self.entity.AttrComponent:AddValue(GDefine.Attr.move_speed, addSpeed)
        self.speedTotalAdd = self.speedTotalAdd + addSpeed
    end

    local targetPos = self.mainTargetEntity.TransformComponent:GetPos()
    self.entity.MoveComponent:MoveToPos(targetPos.x,targetPos.y,targetPos.z,{
        onComplete = self:ToFunc("ChangeStage")
    })
end

function ChargeCollidesContinuouslyBehavior:CarryTargetEntitys()
    if self.moveOffset == nil then
        return
    end
    for i, entityUid in ipairs(self.targetEntityUids) do
        local entity = self.world.EntitySystem:GetEntity(entityUid)
        if entity and not self.lastTargetList:ExistIndex(entityUid) then
            if entity.StateComponent and entity.CollistionComponent then
                self:AddMarkState(entity,BattleDefine.MarkState.knock_back)
                entity.CollistionComponent:SetEnable(false)
                self.lastTargetList:Push(entityUid,entityUid)
            end
        end
        self.lastTargetFlag[entityUid] = true

        entity.MoveComponent:SetPosOffset(self.moveOffset.x,self.moveOffset.y,self.moveOffset.z)
    end
    self.moveOffset = nil
    for iter in self.lastTargetList:Items() do
        local uid = iter.value
        if not self.lastTargetFlag[uid] then
            local entity = self.world.EntitySystem:GetEntity(uid)
            if entity and entity.StateComponent then
                self:RemoveMarkState(entity,BattleDefine.MarkState.knock_back)
                entity.CollistionComponent:SetEnable(true)
            end
            self.lastTargetList:RemoveByIndex(uid)
            self.lastTargetFlag[uid] = nil
        else
            self.lastTargetFlag[uid] = false
        end
    end
end

function ChargeCollidesContinuouslyBehavior:OnCollides()
    if self.hitCount < self.hitMaxCount then  --TODO 增加判断mainTarget是否在targetEntityUids中
        self:HitEntitys(self.targetEntityUids)
        self.hitTime = 0
        self.hitCount = self.hitCount + 1
    end
end

function ChargeCollidesContinuouslyBehavior:TryMarkState(isMark)
    if isMark then
        self:AddMarkState(self.entity,BattleDefine.MarkState.move_releasing_skill)
    else
        self:RemoveMarkState(self.entity,BattleDefine.MarkState.move_releasing_skill)
    end
end

function ChargeCollidesContinuouslyBehavior:OnCollidesComplete()
    self.stage = self.stageDefine.overAnim
    self.entity.AttrComponent:AddValue(GDefine.Attr.move_speed, -self.speedTotalAdd)
    self:PlayEndAnim()
end

function ChargeCollidesContinuouslyBehavior:PlayMoveAnim()
    if not self.world.opts.isClient then
        return
    end
    self.entity.AnimComponent:PlayAnim(self.actionParam.moveAnim)
end

function ChargeCollidesContinuouslyBehavior:PlayEndAnim()
    if self.isPlayingAnim then
        return
    end
    if self.actionParam.overTime > 0 then
        self.isPlayingAnim = true
        if self.world.opts.isClient then
            self.entity.AnimComponent:PlayAnim(self.actionParam.overAnim)
        end
    else
        self:OnAnimComplete()
    end
end

function ChargeCollidesContinuouslyBehavior:OnAnimComplete()
    self.stage = self.stageDefine.none
    self:TryMarkState(false)

    for iter in self.lastTargetList:Items() do
        local uid = iter.value
        local entity = self.world.EntitySystem:GetEntity(uid)
        if entity then
            self:RemoveMarkState(entity,BattleDefine.MarkState.knock_back)
            entity.CollistionComponent:SetEnable(true)
        end
    end
    self.lastTargetList:Delete()

    if self.lockUid then
        self.lockUid = self.timeline:Unlock(self.lockUid)
    end
    self.entity.BehaviorComponent:RemoveBehavior(self.uid)
end