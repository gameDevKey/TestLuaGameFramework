SwallowThenSpitEntityBehavior = BaseClass("SwallowThenSpitEntityBehavior",SkillBehavior)

function SwallowThenSpitEntityBehavior:__Init()
    self.swallowEntity = nil
    self.effects = {}
end

function SwallowThenSpitEntityBehavior:__Delete()
    self:RemoveSwallowTargetEffects()
end

function SwallowThenSpitEntityBehavior:OnInit(targetEntitys)
    self.skill:AddRefNum(1)

    self.controlTimer = 0
    self.controlTime = self.actionParam.controlTime

    self.hitTimer = 0
    self.hitTime = self.actionParam.hitDeltaTime

    self.targetEntitys = targetEntitys

    -- self:SearchTargets(self.actionParam.range)
    -- self:print("搜索到目标",self.targetEntitys)

    self.swallowEntity = nil
    for _, uid in ipairs(self.targetEntitys) do
        if self.world.EntitySystem:HasEntity(uid) then
            self.swallowEntity = self.world.EntitySystem:GetEntity(uid)
            break
        end
    end
    if not self.swallowEntity then
        return
    end

    self:print("实体",self.entity.uid,'即将吞噬',self.swallowEntity.uid)

    local eventArgs = {}
    eventArgs.dieEntityUid = self.entity.uid
    self:AddEvent(BattleEvent.unit_die, self:ToFunc("OnUnitDie"), eventArgs)

    local eventArgs = {}
    eventArgs.dieEntityUid = self.swallowEntity.uid
    self:AddEvent(BattleEvent.unit_die, self:ToFunc("OnUnitDie"), eventArgs)

    local eventArgs = {}
    eventArgs.entityUid = self.entity.uid
    self:AddEvent(BattleEvent.do_control,self:ToFunc("OnDoControl"),eventArgs)

    self:AddOrRemoveBuff(self.entity, self.actionParam.selfBuffs,true)
    self:AddOrRemoveBuff(self.swallowEntity, self.actionParam.targetBuffs,true)
    self:AddEffectsToSwallowTarget(self.actionParam.effects)

    self:StartJump(self.swallowEntity,self.entity,self:ToFunc("SwallowTarget"))
    self:CreateEntityTimeline(self.entity, self.actionParam.spitActId)
end

-- function SwallowThenSpitEntityBehavior:SearchTargets(range)
--     local centerPos = self.entity.TransformComponent:GetPos()
--     local forward = self.entity.TransformComponent:GetForward()
--     local searchParams = {}
--     searchParams.entity = self.entity
--     searchParams.range = range or self.skill:GetHitRange()
--     searchParams.transInfo = {}
--     searchParams.transInfo.posX = centerPos.x
--     searchParams.transInfo.posZ = centerPos.z
--     searchParams.transInfo.dirX = forward.x
--     searchParams.transInfo.dirZ = forward.z
--     searchParams.targetNum = 1
--     searchParams.priorityType1 = BattleDefine.SearchPriority.min_to_self_dis
--     searchParams.isLock = true
--     self.targetEntitys,_ = self.world.BattleCastSkillSystem:SkillSearchEntity(self.skill,searchParams)
-- end

--吞进
function SwallowThenSpitEntityBehavior:SwallowTarget()
    if not self.swallowEntity then
        return
    end
    self.isSwallow = true
    self.world.ClientIFacdeSystem:Call("ActiveEntity",self.swallowEntity.uid,false)
    self:RemoveSwallowTargetEffects()
    self.swallowEntity:SetEnable(false)
    self:print("吞下",self.swallowEntity.uid)
end

function SwallowThenSpitEntityBehavior:HitSawllowTarget()
    if not self.swallowEntity then
        return
    end
    if self.actionParam.hitUid then
        self:print("攻击被吞单位",self.swallowEntity.uid)
        self:HitEntitys({self.swallowEntity.uid},self.actionParam.hitUid,self.actionParam.hitEffectId)
    end
end

--吐出
function SwallowThenSpitEntityBehavior:SpitTarget(...)
    if not self.swallowEntity then
        return
    end
    local uid = self.swallowEntity.uid
    self.swallowEntity = self.world.EntitySystem:GetEntity(uid)
    if not self.swallowEntity then --防止引用丢失或者实体死亡
        return
    end
    self:print("吐出被吞单位",self.swallowEntity.uid,'原因是',...)

    self:AddOrRemoveBuff(self.entity, self.actionParam.selfBuffs,false)
    self:AddOrRemoveBuff(self.swallowEntity, self.actionParam.targetBuffs,false)

    self.world.ClientIFacdeSystem:Call("ActiveEntity",self.swallowEntity.uid,true)
    if self.hpBarHideUid then
        self.world.ClientIFacdeSystem:Call("ForceShowHPByLock",self.swallowEntity.uid, self.hpBarHideUid)
        self.hpBarHideUid = nil
    end

    --成功吞进肚子里才执行子timeline
    if self.isSwallow then
        self.swallowEntity:SetEnable(true)
        local pos = self.entity.TransformComponent:GetForwardPos(self.actionParam.spitDistance)
        local y = self.world.BattleTerrainSystem.terrainY
        self.swallowEntity.TransformComponent:SetPos(pos.x,y,pos.z)
        if self.SkillTimelinePack then
            self:print("对被吞单位执行子行为",self.actionParam.spitActId)
            self.SkillTimelinePack:Start({self.swallowEntity.uid},{posX = pos.x,posY = pos.y,posZ = pos.z})
        end
    end

    self.entity.BehaviorComponent:RemoveBehavior(self.uid) --self:SetRemove(true)
    self.swallowEntity = nil

    self.isSwallow = false
end

function SwallowThenSpitEntityBehavior:OnUpdate()
    if not self.swallowEntity then
        return
    end

    if self.controlTime then
        self.controlTimer = self.controlTimer + self.world.opts.frameDeltaTime
        if self.controlTimer >= self.controlTime then
            self:AddEffectsToSwallowTarget(self.actionParam.effects)
            self:SpitTarget("超出控制时间",self.controlTime)
        end
    end

    if not self.jumpArgs and self.hitTime then
        self.hitTimer = self.hitTimer + self.world.opts.frameDeltaTime
        if self.hitTimer >= self.hitTime then
            self:HitSawllowTarget()
            self.hitTimer = 0
        end
    end
end

function SwallowThenSpitEntityBehavior:OnUnitDie(params)
    self:SpitTarget("单位死亡",params.dieEntityUid)
end

function SwallowThenSpitEntityBehavior:AddOrRemoveBuff(entity,buffList,addOrRemove)
    if entity then
        for _, buffId in ipairs(buffList or {}) do
            if addOrRemove then
                self:print("添加Buff",entity.uid, buffId)
                entity.BuffComponent:AddBuff(self.entity.uid,buffId)
            else
                self:print("移除Buff",entity.uid, buffId)
                entity.BuffComponent:RemoveBuffById(buffId)
            end
        end
    end
end

function SwallowThenSpitEntityBehavior:CreateEntityTimeline(entity, actId)
    if not actId or actId <= 0 then
        return
    end
    if not entity then
        return
    end

    if self.skill.actConf.Child then
        local actConf = self.skill.actConf.Child[actId]
        if not actConf then
            assert(false,string.format("找不到技能行为子配置[技能ID:%s][技能等级:%s][子行为Id:%s]",self.skill.skillId,self.skill.skillLev,tostring(actId)))
        end
        self:print("创建技能子行为",actId)
        self:AddBehaviorPack(SkillTimelinePack)
        self.SkillTimelinePack:Init(actConf,entity,self.skill)
    end
end

function SwallowThenSpitEntityBehavior:StartJump(fromEntity,toEntity,callback)
    self:print("开始跳跃",fromEntity.uid,'-->',toEntity.uid)

    self.jumpArgs = {
        fromUid = fromEntity.uid,
        fromScale = fromEntity.TransformComponent:GetScale() / FPFloat.Precision,
        toUid = toEntity.uid,
        callback = callback
    }

    self:AddMarkState(fromEntity,BattleDefine.MarkState.force_move)

    fromEntity.SkillComponent:Break()

    self.hpBarHideUid = self.world.ClientIFacdeSystem:Call("ForceHideHPByLock",fromEntity.uid)

    local fromPos = fromEntity.TransformComponent:GetPos()
    local targetPos = toEntity.TransformComponent:GetPos()
    local fromR = fromEntity.CollistionComponent:GetRadius()
    local targetR = toEntity.CollistionComponent:GetRadius()

    local targetForwardPos = toEntity.TransformComponent:GetForwardPos(targetR)

    local fixTargetPos = {
        posX = targetForwardPos.x,
        posY = targetForwardPos.y,
        posZ = targetForwardPos.z
    }

    local info = {}
    info.onAbort = self:ToFunc("JumpAbort")
    info.onUpdate = self:ToFunc("JumpUpdate")
    info.onComplete = self:ToFunc("JumpComplete")
    info.params = {
        logicPos = fromPos,
        targetPos = fixTargetPos,
        speed = self.actionParam.jumpSpeed,
        maxHeight = self.actionParam.jumpMaxHeight,
        moveMaxTime = self.actionParam.jumpMaxTime,
    }
    info.args = self.jumpArgs
    info.moverType = BattleDefine.MoverType.parabola
    if fromEntity.MoveComponent then
        fromEntity.MoveComponent:MoveToPos(fixTargetPos.posX,fixTargetPos.posY,fixTargetPos.posZ,info)
    else
        self:print("!!!!!被吞单位丢失移动组件",fromEntity.uid)
    end
end

function SwallowThenSpitEntityBehavior:JumpUpdate(lerp,args)
    -- self:print("跳跃中",lerp,args)
    local cur = Mathf.Lerp(args.fromScale,0.1,lerp/FPFloat.Precision)
    self.world.ClientIFacdeSystem:Call("SetEntityScale",args.fromUid,cur)
end

function SwallowThenSpitEntityBehavior:JumpAbort(args)
    self:print("跳跃中断",args.fromUid,'-->',args.toUid)

    self.jumpArgs = nil

    local fromEntity = self.world.EntitySystem:GetEntity(args.fromUid)
    if fromEntity then
        self:RemoveMarkState(fromEntity,BattleDefine.MarkState.force_move)
        if fromEntity.MoveComponent then --施法者被打断，跳跃中断，要让被吞单位停止移动
            fromEntity.MoveComponent:StopMove()
        end
        local pos = fromEntity.TransformComponent:GetPos()
        local y = self.world.BattleTerrainSystem.terrainY
        fromEntity.TransformComponent:SetPos(pos.x,y,pos.z) --直接掉落在地面
        fromEntity:SetEnable(true)
    end
    self.world.ClientIFacdeSystem:Call("SetEntityScale",args.fromUid,args.fromScale)

    self:SpitTarget("技能被打断")
end

function SwallowThenSpitEntityBehavior:JumpComplete(args)
    self:print("跳跃结束",args.fromUid,'-->',args.toUid)

    self.jumpArgs = nil

    local fromEntity = self.world.EntitySystem:GetEntity(args.fromUid)
    if fromEntity then
        self:RemoveMarkState(fromEntity,BattleDefine.MarkState.force_move)
        if fromEntity.MoveComponent then
            fromEntity.MoveComponent:StopMove()
        end
        fromEntity:SetEnable(true)
    end
    self.world.ClientIFacdeSystem:Call("SetEntityScale",args.fromUid,args.fromScale)

    if args.callback then
        args.callback(args)
    end
end

function SwallowThenSpitEntityBehavior:OnDoControl()
    self:print("技能被打断",self.jumpArgs)
    if self.jumpArgs then
        self:RemoveSwallowTargetEffects()
        self:JumpAbort(self.jumpArgs)
    end
end

function SwallowThenSpitEntityBehavior:AddEffectsToSwallowTarget(effects)
    if not self.swallowEntity then
        return
    end
    for _, eff in ipairs(effects or {}) do
        local effect = self.world.BattleAssetsSystem:PlayUnitEffect(self.swallowEntity.uid,eff)
        if effect then
            table.insert(self.effects, effect.uid)
            self:print("添加特效",eff,'uid:',effect.uid)
        end
    end
end

function SwallowThenSpitEntityBehavior:RemoveSwallowTargetEffects()
    for _, eff in ipairs(self.effects) do
        self.world.BattleAssetsSystem:RemoveEffect(eff)
        self:print("移除特效 uid:",eff)
    end
    self.effects = {}
end

--TODO 后面移除
SwallowThenSpitEntityBehavior.LOG = false
function SwallowThenSpitEntityBehavior:print(...)
    if not SwallowThenSpitEntityBehavior.LOG then
        return
    end
    if self.world.isCheck then
        return
    end
    LogYqh("SwallowThenSpitEntityBehavior",self.entity.uid,...)
end