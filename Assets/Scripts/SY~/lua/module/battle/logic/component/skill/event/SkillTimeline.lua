SkillTimeline = BaseClass("SkillTimeline",SECBTimeline)

function SkillTimeline:__Init()
    self.entity = nil
    self.skill = nil
    self.targetEntitys = nil
    self.transInfo = nil
    self.effects = {}
    self:SetHandler(BattleDefine.SkillTimelineNode)
end

function SkillTimeline:__Delete()

end

function SkillTimeline:OnInit(entity,skill)
    self.entity = entity
    self.skill = skill
end

function SkillTimeline:OnStart(targetEntitys,transInfo)
    self.targetEntitys = targetEntitys
    self.transInfo = transInfo
end

function SkillTimeline:Log(params)
    Log(params.msg)
end

function SkillTimeline:PlayAnim(params)
    if not self.entity.AnimComponent then
        assert(false,string.format("实体不存在动作组件[unitId:%s][技能Id:%s]",self.entity.ObjectDataComponent.unitConf.id,self.skill.skillId))
    end
    self.entity.AnimComponent:PlayAnim(params.animName)
end
--
function SkillTimeline:PlaySelfEffect(params)
    local effect = self.world.BattleAssetsSystem:PlayUnitEffect(self.entity.uid,params.effectId)
    if effect then
        table.insert(self.effects,effect.uid)
    end
end

function SkillTimeline:PlaySceneEffect(params)
    local pos = self.entity.TransformComponent:GetPos()
    local fixedPosX = nil
    local fixedPosZ = nil
    if params.pos then
        fixedPosX = params.pos.x
        fixedPosZ = params.pos.z
    end
    self.world.BattleAssetsSystem:PlaySceneEffect(params.effectId,fixedPosX or pos.x,pos.y,fixedPosZ or pos.z)
end

function SkillTimeline:PlayTargetPosSceneEffect(params)
    self.world.BattleAssetsSystem:PlaySceneEffect(params.effectId,self.transInfo.posX,self.transInfo.posY or 0,self.transInfo.posZ)
end

function SkillTimeline:PlayTargetEffect(params)
    for i,uid in ipairs(self.targetEntitys) do
        self.world.BattleAssetsSystem:PlayUnitEffect(uid,params.effectId)
    end
end

--飞行攻击
function SkillTimeline:FlyToTargetHit(params)
    local targetEntitys = nil
    if not params.anew_lock_target then
        targetEntitys = self.targetEntitys
    else
        local searchParams = self.world.BattleCastSkillSystem.skillSearchParams
        searchParams.entity = self.entity
        searchParams.range = self.skill:GetAtkRange()
        searchParams.transInfo.posX = self.transInfo.posX
        searchParams.transInfo.posZ = self.transInfo.posZ

        targetEntitys,_ = self.world.BattleCastSkillSystem:SkillSearchEntity(self.skill,searchParams)
    end

    if not targetEntitys then
        return
    end

    for _,entityUid in ipairs(targetEntitys) do
        local targetEntity = self.world.EntitySystem:GetEntity(entityUid)
        if targetEntity then
            local entity = self:CreateFlyToTargetHitEntity()
            local behavior = entity.BehaviorComponent:AddBehavior(FlyToTargetHitEntityBehavior)
            behavior:SetSkill(self.skill)
            behavior:SetActionParam(params)
            behavior:SetTransInfo(self.transInfo)
            behavior:Init(entityUid,nil)
        end
    end
end


--飞行到目标位置
function SkillTimeline:FlyToTargetPosHit(params)
    local entity = self:CreateFlyToTargetHitEntity()
    local behavior = entity.BehaviorComponent:AddBehavior(FlyToTargetHitEntityBehavior)
    behavior:SetSkill(self.skill)
    behavior:SetActionParam(params)
    behavior:SetTransInfo(self.transInfo)
    behavior:Init(nil,self.transInfo)
end

--闪电链
function SkillTimeline:CryLinkHit(params)
    local targetEntitys = self.targetEntitys
    
    if not targetEntitys then
        return
    end

    for _,entityUid in ipairs(targetEntitys) do
        local targetEntity = self.world.EntitySystem:GetEntity(entityUid)
        if targetEntity then
            local entity = self:CreateCryLinkHitEntity()
            local behavior = entity.BehaviorComponent:AddBehavior(CryLinkHitEntityBehavior)
            behavior:SetSkill(self.skill)
            behavior:SetActionParam(params)
            behavior:SetTransInfo(self.transInfo)
            behavior:Init(entityUid)
        end
    end
end


--背刺
function SkillTimeline:BackstabHit(params)
    local targetEntitys = self.targetEntitys
    
    if not targetEntitys then
        return
    end

    if #targetEntitys ~= 1 then
        assert(false,string.format("背刺命中攻击数量只能为1[技能Id:%s]",self.skill.skillId))
    end

    for _,entityUid in ipairs(targetEntitys) do
        local targetEntity = self.world.EntitySystem:GetEntity(entityUid)
        if targetEntity then
            local entity = self:CreateBackstabHitEntity()
            local behavior = entity.BehaviorComponent:AddBehavior(BackstabHitEntityBehavior)
            behavior:SetSkill(self.skill)
            behavior:SetActionParam(params)
            behavior:SetTransInfo(self.transInfo)
            behavior:Init(entityUid)
        end
    end
end

function SkillTimeline:CreateFlyToTargetHitEntity()
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()

    entity:SetOwnerUid(self.entity.uid)
    entity:Init(uid,uid)

    entity:SetWorld(self.world)
    self.world.BattleEntityCreateSystem:CreateComponents(entity,BattleEntityDefine.EntityCreateType.fly_to_target_hit)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.skill_hit)
    entity.CampComponent:SetCamp(self.entity.CampComponent:GetCamp())

    entity:InitComponent()
    entity:AfterInitComponent()

    if entity.clientEntity then
        entity.clientEntity.ClientTransformComponent:SetName(string.format("飞行命中实体[uid:%s][owner_uid:%s]",uid,self.entity.uid))
        entity.clientEntity:InitComponent()
        entity.clientEntity:AfterInitComponent()

        self.world.ClientEntitySystem:AddEntity(entity.clientEntity)
    end

    self.world.EntitySystem:AddEntity(entity)

    return entity
end


function SkillTimeline:CreateCryLinkHitEntity()
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()

    entity:SetOwnerUid(self.entity.uid)
    entity:Init(uid,uid)

    entity:SetWorld(self.world)
    self.world.BattleEntityCreateSystem:CreateComponents(entity,BattleEntityDefine.EntityCreateType.cry_link_hit)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.skill_hit)
    entity.CampComponent:SetCamp(self.entity.CampComponent:GetCamp())

    entity:InitComponent()
    entity:AfterInitComponent()

    if entity.clientEntity then
        entity.clientEntity.ClientTransformComponent:SetName(string.format("闪电链命中实体[uid:%s][owner_uid:%s]",uid,self.entity.uid))
        entity.clientEntity:InitComponent()
        entity.clientEntity:AfterInitComponent()

        self.world.ClientEntitySystem:AddEntity(entity.clientEntity)
    end

    self.world.EntitySystem:AddEntity(entity)

    return entity
end

function SkillTimeline:LoopLinkHit(params)
    local targetEntitys = self.targetEntitys
    
    if not targetEntitys then
        return
    end
    

    for _,entityUid in ipairs(targetEntitys) do
        local targetEntity = self.world.EntitySystem:GetEntity(entityUid)
        if targetEntity then
            local entity = self:CreateLoopLinkHitEntity()
            local behavior = entity.BehaviorComponent:AddBehavior(LoopLinkHitEntityBehavior)
            behavior:SetSkill(self.skill)
            behavior:SetTimeline(self)
            behavior:SetActionParam(params)
            behavior:SetTransInfo(self.transInfo)
            behavior:Init(entityUid)
        end
    end
end

function SkillTimeline:CreateLoopLinkHitEntity()
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()

    entity:SetOwnerUid(self.entity.uid)
    entity:Init(uid,uid)

    entity:SetWorld(self.world)
    self.world.BattleEntityCreateSystem:CreateComponents(entity,BattleEntityDefine.EntityCreateType.loop_link_hit)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.skill_hit)
    entity.CampComponent:SetCamp(self.entity.CampComponent:GetCamp())

    entity:InitComponent()
    entity:AfterInitComponent()

    if entity.clientEntity then
        entity.clientEntity.ClientTransformComponent:SetName(string.format("循环连接命中实体[uid:%s][owner_uid:%s]",uid,self.entity.uid))
        entity.clientEntity:InitComponent()
        entity.clientEntity:AfterInitComponent()

        self.world.ClientEntitySystem:AddEntity(entity.clientEntity)
    end

    self.world.EntitySystem:AddEntity(entity)

    return entity
end


function SkillTimeline:CreateBackstabHitEntity()
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()

    entity:SetOwnerUid(self.entity.uid)
    entity:Init(uid,uid)

    entity:SetWorld(self.world)
    self.world.BattleEntityCreateSystem:CreateComponents(entity,BattleEntityDefine.EntityCreateType.backstab_hit)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.skill_hit)
    entity.CampComponent:SetCamp(self.entity.CampComponent:GetCamp())

    entity:InitComponent()
    entity:AfterInitComponent()

    if entity.clientEntity then
        entity.clientEntity.ClientTransformComponent:SetName(string.format("背刺命中实体[uid:%s][owner_uid:%s]",uid,self.entity.uid))
        entity.clientEntity:InitComponent()
        entity.clientEntity:AfterInitComponent()

        self.world.ClientEntitySystem:AddEntity(entity.clientEntity)
    end

    self.world.EntitySystem:AddEntity(entity)

    return entity
end

-- function SkillTimeline:GenEntityComplete(entity)
--     if self.genEntitys:ExistIndex(entity.uid) then
--         self.genEntitys:RemoveByIndex(entity.uid)
--     end
-- end

--目标命中
function SkillTimeline:DoHit(params)
    local targetEntitys = nil
    if self.skill.baseConf.lock_target == 1 then
        targetEntitys = self.targetEntitys
    else
        
        local searchParams = self.world.BattleCastSkillSystem.skillSearchParams
        searchParams.entity = self.entity
        searchParams.range = self.skill:GetHitRange()
        searchParams.targetNum = self.skill:GetHitNum()
        searchParams.transInfo.posX = self.transInfo.posX
        searchParams.transInfo.posZ = self.transInfo.posZ
        searchParams.transInfo.dirX = self.transInfo.dirX
        searchParams.transInfo.dirZ = self.transInfo.dirZ

        targetEntitys,_ = self.world.BattleCastSkillSystem:SkillSearchEntity(self.skill,searchParams)
    end

    if not targetEntitys then
        return
    end

    local fromUid = self.entity.uid
    local hitArgs = {skill = self.skill, skillId = self.skill.skillId,skillLev = self.skill.skillLev,hitUid = params.hitUid,relUid = self.skill.relUid}
    local hitResultId = self.skill:GetHitResultId(params.hitUid)
    local hitEffectId = params.hitEffectId
    self.world.BattleHitSystem:HitEntitys(fromUid,targetEntitys,hitArgs,hitResultId,hitEffectId)
end

--自身命中
function SkillTimeline:SelfDoHit(params)
    local fromUid = self.entity.ownerUid or self.entity.uid
    local hitArgs = {skill = self.skill, skillId = self.skill.skillId,skillLev = self.skill.skillLev,hitUid = params.hitUid,relUid = self.skill.relUid}
    local hitResultId = self.skill:GetHitResultId(params.hitUid)
    local hitEffectId = params.hitEffectId
    self.world.BattleHitSystem:HitEntitys(fromUid,{fromUid},hitArgs,hitResultId,hitEffectId)
end

--行为命中
function SkillTimeline:DoBehaviorHit(params)
    if params.multiple then
        for _,entityUid in ipairs(self.targetEntitys) do
            local targetEntity = self.world.EntitySystem:GetEntity(entityUid)
            if targetEntity then
                local entity = self:CreateBehaviorHitEntity()
                local behavior = entity.BehaviorComponent:AddBehavior(SkillHitBehavior)
                behavior:SetSkill(self.skill)
                behavior:SetActionParam(params)
                behavior:SetTransInfo(self.transInfo)
                behavior:Init({entityUid})
            end
        end
    else
        local entity = self:CreateBehaviorHitEntity()
        local behavior = entity.BehaviorComponent:AddBehavior(SkillHitBehavior)
        behavior:SetSkill(self.skill)
        behavior:SetActionParam(params)
        behavior:SetTransInfo(self.transInfo)
        behavior:Init(self.targetEntitys)
    end
end
function SkillTimeline:CreateBehaviorHitEntity()
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()

    entity:SetOwnerUid(self.entity.uid)
    entity:Init(uid,uid)

    entity:SetWorld(self.world)
    self.world.BattleEntityCreateSystem:CreateComponents(entity,BattleEntityDefine.EntityCreateType.skill_behavior_hit)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.skill_hit)
    entity.CampComponent:SetCamp(self.entity.CampComponent:GetCamp())

    entity:InitComponent()
    entity:AfterInitComponent()

    self.world.EntitySystem:AddEntity(entity)

    return entity
end

function SkillTimeline:SummonUnit(params)
    if not params.num or params.num <= 0 then
        assert(false,string.format("[技能Id:%s]召唤物数量配置异常 num = %s",self.skill.skillId, tostring(params.num)))
    end
    if not params.pos then
        assert(false,string.format("[技能Id:%s]请配置召唤物位置数据",self.skill.skillId))
    end
    for index=1,params.num do
        local posData = params.pos[index]
        if not posData or not posData.data then
            assert(false,string.format("[技能Id:%s]第[%d]个召唤物位置未配置 pos = %s",self.skill.skillId, index, TableUtils.TableToString(params.pos)))
        end
        local relativePos
        if posData.isAbsolute then
            relativePos = Vector3.zero --棋盘中心
        end
        local entity = self.world.BattleEntityCreateSystem:CreateSummonEntity(self.entity,params.unitId,params.lev,params.star,params.attrRatio,posData.data,relativePos)
        if params.lifeTime and params.lifeTime > 0 then
            local behavior = entity.BehaviorComponent:AddBehavior(LifeEntityBehavior)
            behavior:SetSkill(self.skill)
            behavior:SetActionParam(params)
            behavior:SetTransInfo(self.transInfo)
            behavior:Init(params.lifeTime)
        end
        self.world.BattleEntityCreateSystem:BindAttackAI(entity)
    end
end

function SkillTimeline:SummonCommanderUnit(params)
    local entity = self.world.BattleEntityCreateSystem:CreateSummonCommanderEntity(self.entity,params.unitId,params.lev,params.star,params.attrRatio,params.maxHpRatio,self.transInfo)
    if params.lifeTime and params.lifeTime > 0 then
        local behavior = entity.BehaviorComponent:AddBehavior(LifeEntityBehavior)
        behavior:SetSkill(self.skill)
        behavior:SetActionParam(params)
        behavior:SetTransInfo(self.transInfo)
        behavior:Init(params.lifeTime)
    end
    self.world.BattleEntityCreateSystem:BindAttackAI(entity)
end

function SkillTimeline:SummonCloneUnit(params)
    local ownerEntityUid = self.entity.ownerUid or self.entity.uid
    local ownerEntity = self.world.EntitySystem:GetEntity(ownerEntityUid)
    if not ownerEntity then --本体死亡了
        return
    end
    local kvType = BattleDefine.EntityKvType.clone_units
    local units = ownerEntity.KvDataComponent:GetData(kvType) or {}
    local curCount = #units
    local maxCount = params.limit or 0
    local levParam = params.levParam[self.skill.skillLev] or params.levParam[0]
    local genCount = maxCount > 0 and MathUtils.Clamp(levParam.num, 0, maxCount) or levParam.num
    if levParam and maxCount > 0 then
        if curCount + genCount > maxCount then --本次召唤已达上限
            if params.genNew then --移除旧的，生成新的
                local removeCount = curCount + genCount - maxCount
                -- if not self.world.isCheck then
                --     LogYqh(ownerEntity.uid,"召唤分身 移除旧的分身",removeCount)
                -- end
                for i = 1, removeCount do
                    local uid = units[i]
                    local entity = self.world.EntitySystem:GetEntity(uid)
                    if entity then
                        self.world.BattleHitSystem:ImmedDie(entity)
                    end
                end
                units = ownerEntity.KvDataComponent:GetData(kvType) or {}
                curCount = #units
            else    --到达上限则不再召唤
                genCount = maxCount - curCount
            end
        end
    end
    -- if not self.world.isCheck then
    --     LogYqh(ownerEntity.uid,"召唤分身 本次想召唤",levParam.num,"已召唤",curCount,"上限",maxCount,"实际可召唤",genCount)
    -- end
    for i = 1, genCount do
        local entity = self.world.BattleEntityCreateSystem:CreateSummonCloneEntity(
            ownerEntity,levParam.unitId,levParam.lev,levParam.star,levParam.attrList,levParam.radius)
        local behavior = entity.BehaviorComponent:AddBehavior(CloneUnitEntityBehavior)
        behavior:SetSkill(self.skill)
        behavior:SetActionParam(levParam)
        behavior:SetTransInfo(self.transInfo)
        behavior:Init()
        self.world.BattleEntityCreateSystem:BindAttackAI(entity)
    end
    -- if not self.world.isCheck then
    --     LogYqh(ownerEntity.uid,"召唤分身结束 当前分身",ownerEntity.KvDataComponent:GetData(kvType))
    -- end
end

--飞行轨迹命中
function SkillTimeline:FlyTrackHit(params)
    local targetEntitys = self.targetEntitys

    if not targetEntitys and not params.noTargetRelAngle then
        return
    end

    for _,entityUid in ipairs(targetEntitys) do
        local targetEntity = self.world.EntitySystem:GetEntity(entityUid)
        if targetEntity then
            local entity = self:CreateFlyTrackHitEntity()
            local behavior = entity.BehaviorComponent:AddBehavior(FlyTrackHitEntityBehavior)
            behavior:SetSkill(self.skill)
            behavior:SetTimeline(self)
            behavior:SetActionParam(params)
            behavior:SetTransInfo(self.transInfo)
            behavior:Init(entityUid)
        end
    end
end

function SkillTimeline:CreateFlyTrackHitEntity()
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()
    entity:SetOwnerUid(self.entity.uid)
    entity:Init(uid,uid)
    entity:SetWorld(self.world)
    self.world.BattleEntityCreateSystem:CreateComponents(entity,BattleEntityDefine.EntityCreateType.fly_track_hit)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.skill_hit)
    entity.CampComponent:SetCamp(self.entity.CampComponent:GetCamp())
    local pos = self.entity.TransformComponent:GetPos()
    entity.TransformComponent:SetPos(pos.x,pos.y,pos.z)

    entity:InitComponent()
    entity:AfterInitComponent()

    self.world.EntitySystem:AddEntity(entity)

    if entity.clientEntity then
        entity.clientEntity.ClientTransformComponent:SetName(string.format("飞行轨迹命中实体[uid:%s][owner_uid:%s]",uid,self.entity.uid))
        entity.clientEntity:InitComponent()
        entity.clientEntity:AfterInitComponent()

        self.world.ClientEntitySystem:AddEntity(entity.clientEntity)
    end


    return entity
end



--装载机
function SkillTimeline:Transport(params)
    local entity = self:CreateTransportEntity()
    local behavior = entity.BehaviorComponent:AddBehavior(TransportBehavior)
    behavior:SetSkill(self.skill)
    behavior:SetActionParam(params)
    behavior:SetTransInfo(self.transInfo)
    behavior:Init(entityUid)
end

function SkillTimeline:CreateTransportEntity()
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()
    entity:SetOwnerUid(self.entity.uid)
    entity:Init(uid,uid)
    entity:SetWorld(self.world)
    self.world.BattleEntityCreateSystem:CreateComponents(entity,BattleEntityDefine.EntityCreateType.transport)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.skill_hit)
    entity.CampComponent:SetCamp(self.entity.CampComponent:GetCamp())

    entity:InitComponent()
    entity:AfterInitComponent()

    self.world.EntitySystem:AddEntity(entity)

    return entity
end

-- 移除满足条件的buff
function SkillTimeline:RemoveSatisfiedBuff(params)
    local targetEntitys = nil
    if self.skill.baseConf.lock_target == 1 then
        targetEntitys = self.targetEntitys
    else
        local searchParams = self.world.BattleCastSkillSystem.skillSearchParams
        searchParams.entity = self.entity
        searchParams.range = self.skill:GetHitRange()
        searchParams.transInfo.posX = self.transInfo.posX
        searchParams.transInfo.posZ = self.transInfo.posZ

        targetEntitys,_ = self.world.BattleCastSkillSystem:SkillSearchEntity(self.skill,searchParams)
    end

    if not targetEntitys then
        return
    end

    local conds = params.conds

    for i,entityUid in ipairs(targetEntitys) do
        local targetEntity = self.world.EntitySystem:GetEntity(entityUid)
        if targetEntity then
            self.world.BattleAssetsSystem:PlayHitEffect(entityUid,params.hitEffectId)
            self.world.PluginSystem.EntityFunc:EntityRemoveBuffByConds(targetEntity,conds)
        end
    end
end

function SkillTimeline:ShakeScreenPos(params)
    if self.world.opts:IsClient() then
        self.world.BattleMixedSystem:ShakeCamera(params.lastTime * 0.001,params.strength * 0.001,params.vibrato,params.randomness)
    end
end

function SkillTimeline:ForceMoveByCenter(params)
    local entity = self:CreateForceMoveByCenterEntity()
    local behavior = entity.BehaviorComponent:AddBehavior(ForceMoveByCenterBehavior)
    behavior:SetSkill(self.skill)
    behavior:SetActionParam(params)
    behavior:SetTransInfo(self.transInfo)
    behavior:Init()
end

function SkillTimeline:CreateForceMoveByCenterEntity()
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()

    entity:SetOwnerUid(self.entity.uid)
    entity:Init(uid,uid)

    entity:SetWorld(self.world)
    self.world.BattleEntityCreateSystem:CreateComponents(entity,BattleEntityDefine.EntityCreateType.force_move_by_center)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.skill_hit)
    entity.CampComponent:SetCamp(self.entity.CampComponent:GetCamp())

    entity:InitComponent()
    entity:AfterInitComponent()

    self.world.EntitySystem:AddEntity(entity)

    return entity
end

function SkillTimeline:CommanderExpModify(params)
    local roleUid = self.world.BattleDataSystem.roleUid

    if not params.modifySelf then
        for i,v in ipairs(self.world.BattleDataSystem.data.role_list) do
            if v.role_base.role_uid ~= roleUid then
                roleUid = v.role_base.role_uid
                break
            end
        end
    end
    self.world.BattleCommanderSystem:AddExp(roleUid,params.modifyValue,{from = 3})
end

function SkillTimeline:UnitStarModify(params)
    local isSelf = self.entity.ObjectDataComponent.roleUid == self.world.BattleDataSystem.roleUid -- 自己释放的魔法卡才有拖尾特效

    local args = {prob = params.modifyProb[self.skill.skillLev]}
    local success = self.world.PluginSystem.CheckCond:Prob(nil,args)
    if success then
        local roleUid = self.entity.ObjectDataComponent.roleUid
        if not params.modifySelf then
            for i,v in ipairs(self.world.BattleDataSystem.data.role_list) do
                if v.role_base.role_uid ~= roleUid then
                    roleUid = v.role_base.role_uid
                    break
                end
            end
        end
        local unitDatas = self.world.BattleDataSystem.rolePkDatas[roleUid].unitDatas

        local starUpCountLimit = self.world.BattleDataSystem.pvpConf.star_up_count_limit
        local randomUnits = {}
        for k, v in pairs(unitDatas) do
            if v.star < starUpCountLimit then
                table.insert(randomUnits,v)
            end
            if params.modifyNum < 0 and v.star == 1 then
                table.remove(randomUnits)
            end
        end

        if #randomUnits > 0 then
            local index = self.world.BattleRandomSystem:Random(1,#randomUnits)
            local unitId = randomUnits[index].unit_id
            local grid = randomUnits[index].grid_id
            local star = randomUnits[index].star + params.modifyNum
            if star > starUpCountLimit then
                star = starUpCountLimit
            elseif star < 1 then
                star = 1
            end
            self.world.BattleMixedSystem:UpdateUnit(roleUid,unitId,grid,star)
            if isSelf then
                if params.modifyNum > 0 then
                    self.world.ClientIFacdeSystem:Call("SendEvent","BattleMixedEffectView","UseUpCardSuccess",self.transInfo,grid)
                else
                    self.world.ClientIFacdeSystem:Call("SendEvent","BattleMixedEffectView","UseDownCardSuccess",self.transInfo,unitId)
                end
            end
        else
            if isSelf then
                self.world.ClientIFacdeSystem:Call("SendEvent","BattleMixedEffectView","UseCardFailed",self.transInfo)
            end
        end
    else
        if isSelf then
            self.world.ClientIFacdeSystem:Call("SendEvent","BattleMixedEffectView","UseCardFailed",self.transInfo)
        end
    end
end

function SkillTimeline:ParabolicJump(params)
    local targetEntitys = self.targetEntitys
    
    if not targetEntitys then
        return
    end

    if #targetEntitys ~= 1 then
        assert(false,string.format("抛物线跳跃目标数量只能为1[技能Id:%s]",self.skill.skillId))
    end

    for _,entityUid in ipairs(targetEntitys) do
        local targetEntity = self.world.EntitySystem:GetEntity(entityUid)
        if targetEntity then
            local entity = self:CreateParabolicJumpEntity()
            local behavior = entity.BehaviorComponent:AddBehavior(ParabolicJumpEntityBehavior)
            behavior:SetSkill(self.skill)
            behavior:SetActionParam(params)
            behavior:SetTransInfo(self.transInfo)
            behavior:Init(entityUid)
        end
    end
end

function SkillTimeline:CreateParabolicJumpEntity()
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()

    entity:SetOwnerUid(self.entity.uid)
    entity:Init(uid,uid)

    entity:SetWorld(self.world)
    self.world.BattleEntityCreateSystem:CreateComponents(entity,BattleEntityDefine.EntityCreateType.parabolic_jump)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.skill_hit)
    entity.CampComponent:SetCamp(self.entity.CampComponent:GetCamp())

    entity:InitComponent()
    entity:AfterInitComponent()

    if entity.clientEntity then
        entity.clientEntity.ClientTransformComponent:SetName(string.format("背刺命中实体[uid:%s][owner_uid:%s]",uid,self.entity.uid))
        entity.clientEntity:InitComponent()
        entity.clientEntity:AfterInitComponent()

        self.world.ClientEntitySystem:AddEntity(entity.clientEntity)
    end

    self.world.EntitySystem:AddEntity(entity)

    return entity
end

function SkillTimeline:BouncingBullet(params)
    local targetEntitys = nil
    if not params.anew_lock_target then
        targetEntitys = self.targetEntitys
    else
        local searchParams = self.world.BattleCastSkillSystem.skillSearchParams
        searchParams.entity = self.entity
        searchParams.range = self.skill:GetAtkRange()
        searchParams.transInfo.posX = self.transInfo.posX
        searchParams.transInfo.posZ = self.transInfo.posZ

        targetEntitys,_ = self.world.BattleCastSkillSystem:SkillSearchEntity(self.skill,searchParams)
    end

    if not targetEntitys then
        return
    end

    for _, entityUid in ipairs(targetEntitys) do
        local targetEntity = self.world.EntitySystem:GetEntity(entityUid)
        if targetEntity then
            local entity = self:CreateBouncingBulletEntity()
            local behavior = entity.BehaviorComponent:AddBehavior(BouncingBulletEntityBehavior)
            behavior:SetSkill(self.skill)
            behavior:SetActionParam(params)
            behavior:SetTransInfo(self.transInfo)
            behavior:Init(entityUid)
        end
    end
end

function SkillTimeline:CreateBouncingBulletEntity()
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()

    entity:SetOwnerUid(self.entity.uid)
    entity:Init(uid,uid)

    entity:SetWorld(self.world)
    self.world.BattleEntityCreateSystem:CreateComponents(entity,BattleEntityDefine.EntityCreateType.bouncing_bullet)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.skill_hit)
    entity.CampComponent:SetCamp(self.entity.CampComponent:GetCamp())

    entity:InitComponent()
    entity:AfterInitComponent()

    if entity.clientEntity then
        entity.clientEntity.ClientTransformComponent:SetName(string.format("弹跳子弹实体[uid:%s][owner_uid:%s]",uid,self.entity.uid))
        entity.clientEntity:InitComponent()
        entity.clientEntity:AfterInitComponent()

        self.world.ClientEntitySystem:AddEntity(entity.clientEntity)
    end

    self.world.EntitySystem:AddEntity(entity)

    return entity
end

function SkillTimeline:KnockBack(params)
    local targetEntitys = self.targetEntitys

    if not targetEntitys then
        return
    end

    if #targetEntitys ~= 1 then
        assert(false,string.format("击退击飞目标数量只能为1[技能Id:%s]",self.skill.skillId))
    end

    for _,entityUid in ipairs(targetEntitys) do
        local targetEntity = self.world.EntitySystem:GetEntity(entityUid)
        if targetEntity then
            local entity = self:CreateKnockBackEntity()
            local ownerPos = self.entity.TransformComponent:GetPos()
            entity.TransformComponent:SetPos(ownerPos.x,ownerPos.y,ownerPos.z)
            local behavior = entity.BehaviorComponent:AddBehavior(KnockBackBehavior)
            behavior:SetSkill(self.skill)
            behavior:SetActionParam(params)
            behavior:SetTransInfo(self.transInfo)
            behavior:Init(entityUid)
        end
    end
end

function SkillTimeline:CreateKnockBackEntity()
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()

    entity:SetOwnerUid(self.entity.uid)
    entity:Init(uid,uid)

    entity:SetWorld(self.world)
    self.world.BattleEntityCreateSystem:CreateComponents(entity,BattleEntityDefine.EntityCreateType.knock_back)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.skill_hit)
    entity.CampComponent:SetCamp(self.entity.CampComponent:GetCamp())

    entity:InitComponent()
    entity:AfterInitComponent()

    self.world.EntitySystem:AddEntity(entity)

    return entity
end

function SkillTimeline:PlayAudio(params)
    self.world.ClientIFacdeSystem:Call("PlaySkillAudio",params.audioId)
end

function SkillTimeline:Transfigure(params)
    local entity = self:CreateTransfigureEntity()
    local behavior = entity.BehaviorComponent:AddBehavior(TransfigureBehavior)
    behavior:SetSkill(self.skill)
    behavior:SetActionParam(params)
    behavior:Init()
end

function SkillTimeline:CreateTransfigureEntity()
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()
    entity:SetOwnerUid(self.entity.uid)
    entity:Init(uid,uid)
    entity:SetWorld(self.world)
    self.world.BattleEntityCreateSystem:CreateComponents(entity,BattleEntityDefine.EntityCreateType.transfigure)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.skill_hit)
    entity.CampComponent:SetCamp(self.entity.CampComponent:GetCamp())

    entity:InitComponent()
    entity:AfterInitComponent()

    self.world.EntitySystem:AddEntity(entity)

    return entity
end

--冲锋
function SkillTimeline:FastCharge(params)
    local behavior = self.entity.BehaviorComponent:AddBehavior(FastChargeEntityBehavior)
    behavior:SetSkill(self.skill)
    behavior:SetActionParam(params)
    behavior:SetTransInfo(self.transInfo)
    behavior:Init(self.targetEntitys)
end

--吞噬
function SkillTimeline:SwallowThenSpit(params)
    local behavior = self.entity.BehaviorComponent:AddBehavior(SwallowThenSpitEntityBehavior)
    behavior:SetSkill(self.skill)
    behavior:SetActionParam(params)
    behavior:SetTransInfo(self.transInfo)
    behavior:Init(self.targetEntitys)
end

function SkillTimeline:DelayDie(params)
    local behavior = self.entity.BehaviorComponent:AddBehavior(DelayDieBehavior)
    behavior:SetSkill(self.skill)
    behavior:SetActionParam(params)
    behavior:SetTransInfo(self.transInfo)
    behavior:Init()
end

function SkillTimeline:PumpedStorage(params)
    local behavior = self.entity.BehaviorComponent:AddBehavior(PumpedStorageBehavior)
    behavior:SetSkill(self.skill)
    behavior:SetActionParam(params)
    behavior:SetTransInfo(self.transInfo)
    behavior:Init(self.targetEntitys)
end

--释放技能
function SkillTimeline:RelSkill(params)
    --TODO 后面整理一下这个接口

    local skillId = params.skillId
	local skillLev = params.skillLev

	local baseConf = self.world.BattleConfSystem:SkillData_data_skill_base(skillId)
    if not baseConf then
        assert(false,string.format("技能配置不存在[技能Id:%s][技能等级:%s]", skillId, skillLev))
    end

    self.entity.SkillComponent:RepSkill(skillId,skillLev)
    local skill = self.entity.SkillComponent:GetSkill(skillId)

    self.world.PluginSystem.PasvAction:CheckRelSkill(self.entity,skill)
end

function SkillTimeline:PullEntity(params)
    local behavior = self.entity.BehaviorComponent:AddBehavior(PullEntityBehavior)
    behavior:SetSkill(self.skill)
    behavior:SetActionParam(params)
    behavior:SetTransInfo(self.transInfo)
    behavior:Init(self.targetEntitys)
end

--持续冲撞
function SkillTimeline:ChargeCollidesContinuously(params)
    local behavior = self.entity.BehaviorComponent:AddBehavior(ChargeCollidesContinuouslyBehavior)
    behavior:SetSkill(self.skill)
    behavior:SetTimeline(self)
    behavior:SetActionParam(params)
    behavior:SetTransInfo(self.transInfo)
    behavior:Init(self.targetEntitys)
end

function SkillTimeline:OnAbort()
    if #self.effects > 0 then
        for _,uid in ipairs(self.effects) do
            self.world.BattleAssetsSystem:RemoveEffect(uid)
        end
        self.effects = {}
    end
end

function SkillTimeline:OnFinish()
    if #self.effects > 0 then
        self.effects = {}
    end
end