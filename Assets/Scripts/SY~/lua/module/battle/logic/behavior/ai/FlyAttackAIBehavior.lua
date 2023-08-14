FlyAttackAIBehavior = BaseClass("FlyAttackAIBehavior",SECBBehavior)

function FlyAttackAIBehavior:__Init()
    self.trackEntityUid = nil
    self.range = {}
    self.fromRange = {}
end

function FlyAttackAIBehavior:__Delete()

end

function FlyAttackAIBehavior:OnInit()
    self.range.type = BattleDefine.RangeType.circle
    self.range.radius = self.entity.ObjectDataComponent.unitConf.atk_radius
    self.range.uid = 0
    self.range.appendModel = true

    self.fromRange.type = BattleDefine.RangeType.circle
    self.fromRange.radius = self.entity.ObjectDataComponent.unitConf.atk_radius
end

function FlyAttackAIBehavior:OnUpdate()
    -- if not self.entity.StateComponent:CanSwitchState() then
    --     return
    -- end

    local flag = self.world.PluginSystem.EntityStateCheck:CanRelSkill(self.entity)
	if not flag then
		return
	end

    local skill,entitys,castArgs = self.world.BattleCastSkillSystem:GetCastSkill(self.entity)

    if skill then
        self.entity.SkillComponent:RelSkill(skill.skillId,entitys)
        return
    end

    local range = self:GetRange()

    local findParam = {}
    findParam.entity = self.entity
    findParam.targetNum = 1
    findParam.priorityType1 = BattleDefine.SearchPriority.min_to_self_dis
    findParam.camp = self.entity.CampComponent:GetCamp()
    findParam.priorityEntityUid = self.trackEntityUid
    findParam.isLock = true

    local followWalkType = self.entity.ObjectDataComponent.unitConf.follow_walk_type
    if followWalkType == BattleDefine.FollowWalkType.floor then
        findParam.targetType = BattleDefine.TargetType.enemy_floor
    elseif followWalkType == BattleDefine.FollowWalkType.fly then
        findParam.targetType = BattleDefine.TargetType.enemy_fly
    else
        if castArgs.canAtkFly and castArgs.canAtkFloor then
            findParam.targetType = BattleDefine.TargetType.enemy
        elseif castArgs.canAtkFly then
            findParam.targetType = BattleDefine.TargetType.enemy_fly
        elseif castArgs.canAtkFloor then
            findParam.targetType = BattleDefine.TargetType.enemy_floor
        end
    end

    if followWalkType == BattleDefine.FollowWalkType.home then
        findParam.targetCond = {{{type="主堡"}}}
    else
        findParam.targetCond = {{{type="非主堡"}}}
    end

    local pos = self.entity.TransformComponent:GetPos()
    local forward = self.entity.TransformComponent:GetForward()
    findParam.transInfo = {posX = pos.x,posZ = pos.z,dirX = forward.x,dirZ = forward.z}

    local entitys,_ = self.world.BattleSearchSystem:SearchByRange(findParam,range)

    if #entitys > 0 then
        self.trackEntityUid = entitys[1]
        local trackEntity = self.world.EntitySystem:GetEntity(self.trackEntityUid)
        local targetPos = trackEntity.TransformComponent:GetPos()
        self.entity.MoveComponent:MoveToPos(targetPos.x,pos.y,targetPos.z,{})
    else
        local flag = false
        if self.trackEntityUid and not self.world.EntitySystem:HasEntity(self.trackEntityUid) then
            flag = true
        elseif not self.entity.StateComponent:IsState(BattleDefine.EntityState.move) then
            flag = true
        end
        
        if flag then
            local camp = self.entity.CampComponent:GetCamp()
            local initTargetPos = self.world.BattleMixedSystem:GetInitTargetPos(camp)
            local pos = self.entity.TransformComponent:GetPos()
            self.entity.MoveComponent:MoveToPos(pos.x,pos.y,initTargetPos.z,{onComplete = self:ToFunc("MoveToTargetFinish")})
        end

        self.trackEntityUid = nil
    end

    --1.获取最优技能
    --2.最优技能因范围不够，朝向上次目标、最近敌人移动
    --3.释放
end

function FlyAttackAIBehavior:GetRange()
    local changeInfo = self.entity.KvDataComponent:GetData(BattleDefine.EntityKvType.change_range)
    if changeInfo and self.range.uid ~= changeInfo.uid then
        self.range.uid = changeInfo.uid
        self.world.BattleMixedSystem:ChangeRange(self.fromRange,self.range,changeInfo.changes)
        return self.range
    else
        return self.range
    end
end

function FlyAttackAIBehavior:MoveToTarget(targetUid)
    
end

function FlyAttackAIBehavior:MoveToHome()

end

function FlyAttackAIBehavior:MoveToTargetFinish()
    local camp = self.entity.CampComponent:GetCamp()

    local enemyHomeUid = self.world.BattleMixedSystem:GetEnemyHomeUid(camp)
    local enemyHomeEntity = self.world.EntitySystem:GetEntity(enemyHomeUid)

    local pos = enemyHomeEntity.TransformComponent:GetPos()
    --Log("向主堡移动",self.entity.uid,pos.x,pos.y,pos.z)
    self.entity.MoveComponent:MoveToPos(pos.x,pos.y,pos.z,{})
end