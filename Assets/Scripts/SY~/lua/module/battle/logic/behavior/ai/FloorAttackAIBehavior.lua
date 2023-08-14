FloorAttackAIBehavior = BaseClass("FloorAttackAIBehavior",SECBBehavior)

function FloorAttackAIBehavior:__Init()
    self.isMoveToHome = false
    self.moveToHomeComplete = false
    self.targetAreaCamp = nil
    self.trackEntityUid = nil
    self.range = {}
    self.fromRange = {}
end

function FloorAttackAIBehavior:__Delete()

end

function FloorAttackAIBehavior:OnInit()
    self.range.type = BattleDefine.RangeType.circle
    self.range.radius = self.entity.ObjectDataComponent.unitConf.atk_radius
    self.range.uid = 0
    self.range.appendModel = true

    self.fromRange.type = BattleDefine.RangeType.circle
    self.fromRange.radius = self.entity.ObjectDataComponent.unitConf.atk_radius
end

function FloorAttackAIBehavior:OnUpdate()
    local flag = self.world.PluginSystem.EntityStateCheck:CanRelSkill(self.entity)
	if not flag then
        self.isMoveToHome = false
        self.targetAreaCamp = nil
		return
	end

    local skill,entitys,castArgs = self.world.BattleCastSkillSystem:GetCastSkill(self.entity)

    if skill then
        self.isMoveToHome = false
        self.targetAreaCamp = nil
        self.entity.SkillComponent:RelSkill(skill.skillId,entitys)
        return
    end

    --TODO:
    local fromPos = self.entity.TransformComponent:GetPos()
    local toPos = fromPos + self.entity.TransformComponent.velocity + self.entity.TransformComponent.steeringForce



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

    local camp = self.entity.CampComponent:GetCamp()
    local areaCamp = self.world.BattleTerrainSystem:GetAreaCamp(camp,pos.z)

    local entitys,_ = self.world.BattleSearchSystem:SearchByRange(findParam,range)
    if #entitys > 0 then
        local lastIsMoveToHome = self.isMoveToHome
        self.isMoveToHome = false

        local pos = self.entity.TransformComponent:GetPos()
        local camp = self.entity.CampComponent:GetCamp()

        self.trackEntityUid = entitys[1]
        local trackEntity = self.world.EntitySystem:GetEntity(self.trackEntityUid)
        local targetPos = trackEntity.TransformComponent:GetPos()
        local targetCamp = trackEntity.CampComponent:GetCamp()


        local areaCamp = self.world.BattleTerrainSystem:GetAreaCamp(camp,pos.z)
        local targetAreaCamp = self.world.BattleTerrainSystem:GetAreaCamp(targetCamp,targetPos.z)

        local selfIsRoad,selfRoadIndex = self.world.BattleTerrainSystem:InRoadArea(pos.x,pos.z)
        local targetIsRoad,targetRoadIndex = self.world.BattleTerrainSystem:InRoadArea(targetPos.x,targetPos.z)

        local inRoadX,inRoadIndex = self.world.BattleTerrainSystem:InRoadX(pos.x)
        local inTargetRoadX,inTargetRoadIndex = self.world.BattleTerrainSystem:InRoadX(targetPos.x)

        if selfIsRoad and targetIsRoad and selfRoadIndex == targetRoadIndex then
            --Log("都在桥上，直接追击",self.entity.uid,self.trackEntityUid)
            self.targetAreaCamp = nil
            self.entity.MoveComponent:MoveToPos(targetPos.x,pos.y,targetPos.z,{})
        elseif areaCamp and targetAreaCamp and areaCamp == targetAreaCamp then
            --Log("在同一半边，直接追击",self.entity.uid,self.trackEntityUid)
            self.targetAreaCamp = nil
            self.entity.MoveComponent:MoveToPos(targetPos.x,pos.y,targetPos.z,{})
        elseif not targetAreaCamp and inRoadX and inTargetRoadX and inRoadIndex == inTargetRoadIndex then
            self.targetAreaCamp = nil
            self.entity.MoveComponent:MoveToPos(targetPos.x,pos.y,targetPos.z,{})
        elseif not targetAreaCamp then
            self.isMoveToHome = lastIsMoveToHome
            self:CheckMoveToHome()
        else
            --先过桥
            -- if self.targetAreaCamp and self.targetAreaCamp == targetAreaCamp then
            --     return
            -- end
            -- self.targetAreaCamp = targetAreaCamp

            local inRoadX = self.world.BattleTerrainSystem:InRoadX(pos.x)
            --local minX,minZ = self.world.BattleTerrainSystem:GetMinRoadPos(areaCamp,pos.x,pos.z)
            local roadZ = self.world.BattleTerrainSystem:GetCampRoadZ(targetAreaCamp)

            if inRoadX or not areaCamp then
                --Log("直接往桥对面移动",self.entity.uid,targetAreaCamp)
                if targetAreaCamp == BattleDefine.Camp.attack then
                    if toPos.z <= roadZ then
                        self:MoveToRoad()
                        return
                    end
                elseif targetAreaCamp == BattleDefine.Camp.defence then
                    if toPos.z >= roadZ then
                        self:MoveToRoad()
                        return
                    end
                end

                self.entity.MoveComponent:MoveToPos(pos.x,pos.y,roadZ,{onComplete = self:ToFunc("MoveToRoad")})
            else
                local minX,minZ = self.world.BattleTerrainSystem:GetMinRoadPos(areaCamp,pos.x,pos.z)
                self.entity.MoveComponent:MoveToPos(minX,pos.y,minZ,{onComplete = self:ToFunc("MoveToRoad")})

                --Log("路径点往桥对面移动",self.entity.uid,areaCamp)
                --local minX,minZ = self.world.BattleTerrainSystem:GetMinRoadPos(areaCamp,pos.x,pos.z)

                -- if areaCamp == BattleDefine.Camp.attack then
                --     if toPos.z >= roadZ then
                --         self.entity.MoveComponent:MoveToPos(minX,pos.y,roadZ,{onComplete = self:ToFunc("MoveToRoad")})
                --         return
                --     end
                -- elseif areaCamp == BattleDefine.Camp.defence then
                --     if toPos.z <= roadZ then
                --         self.entity.MoveComponent:MoveToPos(minX,pos.y,roadZ,{onComplete = self:ToFunc("MoveToRoad")})
                --         return
                --     end
                -- end

                --self.entity.MoveComponent:MoveToPos(minX,pos.y,minZ,{onComplete = self:ToFunc("MoveToRoad")})
                --self.entity.MoveComponent:MoveToPath(paths,{onComplete = self:ToFunc("MoveToRoad")})


                --local paths = {{x = minX,y = pos.y,z = minZ},{x = minX,y = pos.y,z = roadZ}}
                --self.entity.MoveComponent:MoveToPath(paths,{onComplete = self:ToFunc("MoveToRoad")})
            end
        end
    else
        self.targetAreaCamp = nil
        self.trackEntityUid = nil
        self:CheckMoveToHome()
    end
end

function FloorAttackAIBehavior:GetRange()
    local changeInfo = self.entity.KvDataComponent:GetData(BattleDefine.EntityKvType.change_range)
    if changeInfo and self.range.uid ~= changeInfo.uid then
        self.range.uid = changeInfo.uid
        self.world.BattleMixedSystem:ChangeRange(self.fromRange,self.range,changeInfo.changes)
        return self.range
    else
        return self.range
    end
end

function FloorAttackAIBehavior:MoveToRoad()
    --Log("追踪移动到桥头完成",self.entity.uid)
    self.isMoveToHome = false
    self.targetAreaCamp = nil
end

function FloorAttackAIBehavior:CheckMoveToHome()
    if self.moveToHomeComplete then
        self:MoveToHome()
        return
    end

     --TODO:
     local fromPos = self.entity.TransformComponent:GetPos()
     local toPos = fromPos + self.entity.TransformComponent.velocity + self.entity.TransformComponent.steeringForce

    --Log("检测移动到主堡",self.entity.uid)

    -- if self.isMoveToHome then
    --     return
    -- end
    -- self.isMoveToHome = true

    local camp = self.entity.CampComponent:GetCamp()
    local enemyCamp = self.entity.CampComponent:GetEnemyCamp()

    local initTargetPos = self.world.BattleMixedSystem:GetInitTargetPos(camp)

    local pos = self.entity.TransformComponent:GetPos()

    local inRoadX = self.world.BattleTerrainSystem:InRoadX(pos.x)

    --areaCamp为nil，说明在非法区域
    local areaCamp = self.world.BattleTerrainSystem:GetAreaCamp(camp,pos.z)

    --Log("?",tostring(inRoadX),areaCamp,enemyCamp)

    if inRoadX or (areaCamp and areaCamp == enemyCamp) then
        --Log("直接移动到目标主堡位置",self.entity.uid)
        if camp == BattleDefine.Camp.attack then
            if pos.z >= initTargetPos.z then
                self:MoveToHome()
                return
            end
        elseif camp == BattleDefine.Camp.defence then
            if pos.z <= initTargetPos.z then
                self:MoveToHome()
                return
            end
        end

        self.entity.MoveComponent:MoveToPos(pos.x,pos.y,initTargetPos.z,{onComplete = self:ToFunc("MoveToHome")})
    else
        --Log("路径移动到目标主堡位置",self.entity.uid)
        local minX,minZ = self.world.BattleTerrainSystem:GetMinRoadPos(camp,pos.x,pos.z)
        -- if camp == BattleDefine.Camp.attack then
        --     if toPos.z >= minZ then
        --         if self.entity.uid == 7 then
        --             Log("444",pos.x,pos.y,initTargetPos.z)
        --         end
        --         self.entity.MoveComponent:MoveToPos(pos.x,pos.y,initTargetPos.z,{onComplete = self:ToFunc("MoveToHome")})
        --         return
        --     end
        -- elseif camp == BattleDefine.Camp.defence then
        --     if toPos.z <= minZ then
        --         if self.entity.uid == 7 then
        --             Log("333")
        --         end
        --         self.entity.MoveComponent:MoveToPos(pos.x,pos.y,initTargetPos.z,{onComplete = self:ToFunc("MoveToHome")})
        --         return
        --     end
        -- end
        self.entity.MoveComponent:MoveToPos(minX,pos.y,minZ,{onComplete = self:ToFunc("CheckMoveToHome")})
        --local paths = {{x = minX,y = pos.y,z = minZ},{x = minX,y = pos.y,z = initTargetPos.z}}
        --self.entity.MoveComponent:MoveToPath(paths,{onComplete = self:ToFunc("MoveToHome")})
    end
end

function FloorAttackAIBehavior:MoveToHome()
    --Log("向主堡移动",self.entity.uid)
    self.moveToHomeComplete = true
    --self.isMoveToHome = false

    local camp = self.entity.CampComponent:GetCamp()

    local enemyHomeUid = self.world.BattleMixedSystem:GetEnemyHomeUid(camp)
    local enemyHomeEntity = self.world.EntitySystem:GetEntity(enemyHomeUid)

    local pos = enemyHomeEntity.TransformComponent:GetPos()
    --Log("向主堡移动",self.entity.uid,pos.x,pos.y,pos.z)
    local fromPos = self.entity.TransformComponent:GetPos()
    self.entity.MoveComponent:MoveToPos(pos.x,fromPos.y,pos.z,{})
end