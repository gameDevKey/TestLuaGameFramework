FastChargeEntityBehavior = BaseClass("FastChargeEntityBehavior",SkillBehavior)

function FastChargeEntityBehavior:__Init()
    self.targetEntitys = nil
    self.target = nil
end

function FastChargeEntityBehavior:__Delete()

end

function FastChargeEntityBehavior:OnInit(targetEntitys)
    self.skill:AddRefNum(1)
    self.isFinish = false
    self.followDis = self.actionParam.followDis or 0
    self.speedAdd = self.actionParam.speedAdd or 0
    self.maxSpeed = self.actionParam.maxSpeed
    self.searchRange = self.actionParam.searchRange or self.skill:GetHitRange()
    self.speedTotalAdd = 0
    self.targetEntitys = targetEntitys
    if self.actionParam.timeline then
        self:AddBehaviorPack(SkillTimelinePack)
        local actConf = self.world.BattleConfSystem:SkillTimeline(self.actionParam.timeline)
        if actConf then
            self.SkillTimelinePack:Init(actConf,self.entity,self.skill,self:ToFunc("TimelineComplete"))
        else
            error(string.format("找不到技能行为[ID:%s]",self.actionParam.timeline))
        end
    end
    -- self:print(" 初始化", self.entity.uid, self.targetEntitys, self.actionParam)
end

function FastChargeEntityBehavior:OnUpdate()
    if self.isFinish then
        return
    end
    if not self:CheckTargetEntitys() then
        self:ResearchTargets()
        if not self:CheckTargetEntitys() then
            -- self:print("重新搜索仍然没有冲锋目标，停止冲锋")
            self:OnComplete()
            return
        end
    end
    if self.target then
        local r1 = FPMath.Divide(self.target.CollistionComponent:GetRadius(), 2)
        local r2 = FPMath.Divide(self.entity.CollistionComponent:GetRadius(), 2)
        if self:IsDistanceInRange(self.target, r1 + r2) then
            -- self:print("冲锋距离小于两者圆心距，停止冲锋",r1,r2)
            self:OnComplete()
            return
        end
    end
    self:OnFastCharge()
end

function FastChargeEntityBehavior:CheckTargetEntitys()
    local target = nil
    for _, uid in ipairs(self.targetEntitys or {}) do
        local entity = self.world.EntitySystem:GetEntity(uid)
        if self:IsTargetValid(entity) then
            target = entity
            break
        end
    end
    self.target = target
    -- self:print(" 冲锋目标是",self.target and self.target.uid or "nil")
    return self.target ~= nil
end

function FastChargeEntityBehavior:IsTargetValid(entity)
    return entity ~= nil
        and not entity.StateComponent:IsState(BattleDefine.EntityState.die)
        and not entity.BuffComponent:HasBuffState(BattleDefine.BuffState.not_be_select)
        and self:IsDistanceInRange(entity, self.followDis)
end

function FastChargeEntityBehavior:IsDistanceInRange(entity, range)
    local myPos = self.entity.TransformComponent:GetPos()
    local targetPos = entity.TransformComponent:GetPos()

    -- self:print("FastChargeEntityBehavior 目标距离",self.entity.uid,'>>',entity.uid,
    --     BattleUtils.CalMagnitude(myPos.x,myPos.z,targetPos.x,targetPos.z),'/',range)

    return BattleUtils.CalMagnitude(myPos.x,myPos.z,targetPos.x,targetPos.z) <= range
    -- return FPMath.Sqrt(Mathf.Pow(myPos.x - targetPos.x,2) + Mathf.Pow(myPos.z - targetPos.z,2)) <= range
end

function FastChargeEntityBehavior:OnFastCharge()
    if not self.target then
        self:TryMarkState(false)
        return
    end

    self:TryMarkState(true)

    local speed = self.entity.AttrComponent:GetValue(GDefine.Attr.move_speed)
    if self.speedAdd > 0 and (not self.maxSpeed or speed < self.maxSpeed) then
        local addSpeed = FPFloat.Mul_ii(self.speedAdd, self.world.opts.frameDeltaTime)
        self.entity.AttrComponent:AddValue(GDefine.Attr.move_speed, addSpeed)
        self.speedTotalAdd = self.speedTotalAdd + addSpeed
        -- self:print(" 速度加成",addSpeed,'/',self.speedTotalAdd,
        --     '当前速度',self.entity.AttrComponent:GetValue(GDefine.Attr.move_speed))
    end

    local targetPos = self.target.TransformComponent:GetPos()
    self.entity.MoveComponent:MoveToPos(targetPos.x,targetPos.y,targetPos.z,{
        onComplete = self:ToFunc("OnComplete")
    })
    -- self:print(" 冲锋到目标点",self.entity.uid, '-->', self.target.uid,targetPos)
end

function FastChargeEntityBehavior:ResearchTargets()
    local centerPos = self.entity.TransformComponent:GetPos()
    local forward = self.entity.TransformComponent:GetForward()
    local searchParams = {}
    searchParams.entity = self.entity
    searchParams.range = self.searchRange
    searchParams.transInfo = {}
    searchParams.transInfo.posX = centerPos.x
    searchParams.transInfo.posZ = centerPos.z
    searchParams.transInfo.dirX = forward.x
    searchParams.transInfo.dirZ = forward.z
    searchParams.targetNum = 1
    searchParams.priorityType1 = BattleDefine.SearchPriority.min_to_self_dis
    searchParams.isLock = true
    self.targetEntitys,_ = self.world.BattleCastSkillSystem:SkillSearchEntity(self.skill,searchParams)
    -- self:print(" 重新搜索目标",self.targetEntitys)
end

function FastChargeEntityBehavior:OnComplete()
    -- self:print(" 冲锋结束",self.entity.uid)
    self.isFinish = true
    self:TryMarkState(false)
    self.entity.AttrComponent:AddValue(GDefine.Attr.move_speed, -self.speedTotalAdd)
    self.entity.BehaviorComponent:RemoveBehavior(self.uid) --self:SetRemove(true)
    if self.SkillTimelinePack and self:IsTargetValid(self.target) then
        -- self:print(" 执行timeline",self.actionParam.timeline)
        self.SkillTimelinePack:Start({self.target.uid}, self.transInfo)
    end
end

function FastChargeEntityBehavior:TimelineComplete()
end

function FastChargeEntityBehavior:TryMarkState(isMark)
    if isMark then
        self:AddMarkState(self.entity,BattleDefine.MarkState.releasing_skill)
    else
        self:RemoveMarkState(self.entity,BattleDefine.MarkState.releasing_skill)
    end
end

--TODO 后面移除
FastChargeEntityBehavior.LOG = false
function FastChargeEntityBehavior:print(...)
    if not FastChargeEntityBehavior.LOG then
        return
    end
    if self.world.isCheck then
        return
    end
    local all = {...}
    table.insert(all,"\n Uid:" .. self.entity.uid)
    table.insert(all,"\n Behavior:" .. tostring(self))
    LogYqh("FastChargeEntityBehavior",unpack(all))
end