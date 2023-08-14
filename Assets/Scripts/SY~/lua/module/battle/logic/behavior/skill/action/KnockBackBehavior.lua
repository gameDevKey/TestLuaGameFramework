KnockBackBehavior = BaseClass("KnockBackBehavior",SkillBehavior)
--TODO:仔细检查是否会受到渲染影响,
--TODO:缓存清理
function KnockBackBehavior:__Init()
    self.startKnock = false
    self.mainTargetEntityUid = nil
    self.mainTargetEntity = nil
    self.surroundingEntitys = nil
    self.knockParams = nil

    self.knockStateEntitys = {}
end

function KnockBackBehavior:__Delete()
    for i, v in ipairs(self.knockBackMovers) do
        v:Delete()
    end
end

function KnockBackBehavior:OnInit(targetUid)
    self.skill:AddRefNum(1)

    self.mainTargetEntityUid = targetUid
    self.mainTargetEntity = self.world.EntitySystem:GetEntity(self.mainTargetEntityUid)

    local searchParams = self.world.BattleCastSkillSystem.skillSearchParams
    searchParams.entity = self.entity
    searchParams.range = self.skill:GetHitRange()
    searchParams.targetNum = self.skill:GetHitNum()
    searchParams.transInfo = {}

    self:AssertSearchParams(searchParams)

    local x,z = nil, nil
    if self.actionParam.mutiple then
        x = self.transInfo.posX
        z = self.transInfo.posZ
    else
        local targetPos = nil
        if self.mainTargetEntity then
            targetPos = self.mainTargetEntity.TransformComponent:GetPos()
        else
            targetPos = self.world.EntitySystem:GetRefPos(self.mainTargetEntityUid)
        end
        x = targetPos.x
        z = targetPos.z
    end
    searchParams.transInfo.posX = x
    searchParams.transInfo.posZ = z

    local passEntitys = {}
    passEntitys[self.mainTargetEntityUid] = true
    searchParams.passEntitys = passEntitys

    self.surroundingEntitys,_ = self.world.BattleCastSkillSystem:SkillSearchEntity(self.skill,searchParams)

    -- Log("main",self.mainTargetEntityUid)
    -- LogTable("surrounding",self.surroundingEntitys)
    if not self.mainTargetEntity and (not self.surroundingEntitys or next(self.surroundingEntitys) == nil) then
        -- 主要目标没了且其周围不存在目标
        self:SetRemove(true)
        return
    end

    self.knockTime = 0
    self.startKnock = false
    self:InitTargetEntitysMover()
end

function KnockBackBehavior:InitTargetEntitysMover()
    local dir = nil
    local srcPos = self.entity.TransformComponent:GetPos()
    if not self.actionParam.mutiple then
        local mainTargetEntityPos = nil
        if self.mainTargetEntity then
            mainTargetEntityPos = self.mainTargetEntity.TransformComponent:GetPos()
        else
            mainTargetEntityPos = self.world.EntitySystem:GetRefPos(self.mainTargetEntityUid)
        end
        dir = mainTargetEntityPos - srcPos
    end

    self.knockParams = {}
    if self.mainTargetEntity then
        local startPos,endPos,moveTime,calcDis = self:GetKnockArgs(self.mainTargetEntity,srcPos,dir)
        local params = {}
        params.logicPos = startPos
        params.targetPos = {posX = endPos.x, posY = endPos.y, posZ = endPos.z}
        params.maxHeight = self.actionParam.maxHeight
        params.moveMaxTime = moveTime
        params.calcDis = calcDis
        -- LogTable("params",params)
        self.knockParams[self.mainTargetEntityUid] = params
    end
    for i, v in ipairs(self.surroundingEntitys) do
        local targetEntity = self.world.EntitySystem:GetEntity(v)
        if targetEntity then
            local startPos,endPos,moveTime,calcDis = self:GetKnockArgs(targetEntity,srcPos,dir)

            local params = {}
            params.logicPos = startPos
            params.targetPos = {posX = endPos.x, posY = endPos.y, posZ = endPos.z}
            params.maxHeight = self.actionParam.maxHeight
            params.moveMaxTime = moveTime
            params.calcDis = calcDis
            -- LogTable("params",params)
            self.knockParams[v] = params
        end
    end

    self:KnockBackTargetEntitys()
end

function KnockBackBehavior:GetKnockArgs(targetEntity,srcPos,dir)
    local targetEntityPos = targetEntity.TransformComponent:GetPos()
    if self.actionParam.maxDistance == 0 then  -- 仅击飞
        if self.actionParam.maxHeight == 0 then
            assert(false,string.format("技能%s_%s的击退节点最远距离与最大高度都为0",self.skill.skillId,self.skill.skillLev))
        end
        return targetEntityPos,targetEntityPos,self.actionParam.controlDuration
    end
    if not dir then
        dir = targetEntityPos - srcPos
    end
    dir = dir.normalized
    local force = FPFloat.Div_ii(self.actionParam.force,FPFloat.Precision)
    local t = FPFloat.Div_ii(self.actionParam.controlDuration,FPFloat.Precision)
    local mass = FPFloat.Div_ii(targetEntity.ObjectDataComponent.unitConf.mass,FPFloat.Precision)
    local calcDis = force - mass
    -- Log("force",force,"mass",mass,"calcDis",calcDis)
    if calcDis <= 0 then
        calcDis = 0
        return targetEntityPos,targetEntityPos,t,calcDis
    end
    local maxDistance = FPFloat.Div_ii(self.actionParam.maxDistance,FPFloat.Precision)
    local endPos = nil
    local moveTime = t
    local v = FPFloat.Div_ii(calcDis,moveTime)
    if calcDis > maxDistance then
        endPos = FPVector3(FPFloat.Mul_ii(dir.x,maxDistance) + targetEntityPos.x, targetEntityPos.y , FPFloat.Mul_ii(dir.z,maxDistance) + targetEntityPos.z)
    else
        endPos = FPVector3(FPFloat.Mul_ii(dir.x,calcDis) + targetEntityPos.x, targetEntityPos.y , FPFloat.Mul_ii(dir.z,calcDis) + targetEntityPos.z)
    end

    local fixX,fixZ = self.world.BattleTerrainSystem:PosFix(targetEntity,endPos.x,endPos.z)
    endPos.x = fixX
    endPos.z = fixZ
    local fixDir = endPos - targetEntityPos
    local fixDis = fixDir.magnitude

    moveTime = FPFloat.Div_ii(fixDis,v)
    return targetEntityPos,endPos,moveTime,calcDis
end

function KnockBackBehavior:KnockBackTargetEntitys()
    self.knockBackMovers = {}
    if self.mainTargetEntity then
        local params = self.knockParams[self.mainTargetEntityUid]
        local flag = self:KnockBackTargetEntity(self.mainTargetEntity,params,self.actionParam.mainHitUid)
        self.knockStateEntitys[self.mainTargetEntityUid] = flag
    end
    for i, v in ipairs(self.surroundingEntitys) do
        local targetEntity = self.world.EntitySystem:GetEntity(v)
        if targetEntity then
            local params = self.knockParams[v]
            local flag = self:KnockBackTargetEntity(targetEntity,params,self.actionParam.surroundingHitUid)
            self.knockStateEntitys[v] = flag
        end
    end
    self.startKnock = true
end

function KnockBackBehavior:KnockBackTargetEntity(entity,params,hitUid)
    if entity.StateComponent then
        if entity.StateComponent:HasMarkState(BattleDefine.MarkState.knock_back) then
            return false
        end
        self:AddMarkState(entity,BattleDefine.MarkState.knock_back)
    end
    if hitUid and hitUid ~= 0 then
        self:HitEntitys({entity.uid},hitUid)
    end
    if params.calcDis == 0 then
        return true
    end
	local knockBackMover = ParabolicMover.New()
	knockBackMover:SetWorld(self.world)
	knockBackMover:SetEntity(entity)
	knockBackMover:Init()

	knockBackMover:SetParams(params)
	knockBackMover:MoveToPos(params.targetPos.posX,params.targetPos.posY,params.targetPos.posZ,nil)
    table.insert(self.knockBackMovers,knockBackMover)
    return true
end

function KnockBackBehavior:OnUpdate()
    if self.startKnock then
        self.knockTime = self.knockTime + self.world.opts.frameDeltaTime
        for i, v in ipairs(self.knockBackMovers) do
            v:Update()
        end
        if self.knockTime < self.actionParam.controlDuration then
            return
        end
        self:OnKnockBackEnd()
    end
end

function KnockBackBehavior:OnKnockBackEnd()
    self.startKnock = false
    for i, v in ipairs(self.knockBackMovers) do
        --v:SetTransTransform(1000)
        v:MoveComplete()
        v:Delete()
    end
    if self.mainTargetEntity and self.mainTargetEntity.StateComponent and self.knockStateEntitys[self.mainTargetEntityUid] then
        self:RemoveMarkState(self.mainTargetEntity,BattleDefine.MarkState.knock_back)
    end
    self.mainTargetEntity = nil
    self.mainTargetEntityUid = nil
    for i, v in ipairs(self.surroundingEntitys) do
        local targetEntity = self.world.EntitySystem:GetEntity(v)
        if targetEntity and targetEntity.StateComponent and self.knockStateEntitys[v] then
            self:RemoveMarkState(targetEntity,BattleDefine.MarkState.knock_back)
        end
    end
    self.surroundingEntitys = {}

    self.knockBackMovers = {}
    self:SetRemove(true)
end

function KnockBackBehavior:AssertSearchParams(params)
    if not params.range then
        LogErrorAny("技能",self.skill.skillId,"没有配置命中范围(hit_range)")
        return false
    end
    if not params.range.radius then
        LogErrorAny("技能",self.skill.skillId,"没有配置命中范围半径(hit_range) Range=",params.range)
        return false
    end
    return true
end