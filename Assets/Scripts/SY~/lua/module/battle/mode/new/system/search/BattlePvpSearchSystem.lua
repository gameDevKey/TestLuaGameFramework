BattlePvpSearchSystem = BaseClass("BattlePvpSearchSystem",SECBSystem)
BattlePvpSearchSystem.NAME = "BattleSearchSystem"

function BattlePvpSearchSystem:__Init()
    local _ = PvpSearchSorter
    self:InitSort()

    self.searchParam = nil
    self.searchRange = nil
end

function BattlePvpSearchSystem:__Delete()

end

function BattlePvpSearchSystem:SearchByRange(param,range)
    self.searchParam = param
    self.searchRange = range

    local entitys = {}
    local entityDict = {}

    local entityGroups = nil
    if range.type == BattleDefine.RangeType.full then
       entityGroups = {self.world.EntitySystem.entityList}
    else
        local transInfo = self.searchParam.transInfo
    
        local x,z = self:GetPosByOfffset(transInfo.posX,transInfo.posZ,transInfo.dirX,transInfo.dirZ,range.offset)

        local beginGrid = 0
        local endGrid = 0

        if range.type == RangeDefine.RangeType.aabb then
            local halfWidth = FPMath.Divide(range.width,2)
            local halfHeight = FPMath.Divide(range.height,2)
            beginGrid = self.world.BattleCollistionSystem:PosToGrid(x - halfWidth,z + halfHeight)
            endGrid = self.world.BattleCollistionSystem:PosToGrid(x + halfWidth,z - halfHeight)
        elseif range.type == RangeDefine.RangeType.obb then
            local rangeRadius = FPMath.Max(range.width,range.height)
            local halfRadius = FPMath.Divide(rangeRadius,2)
            beginGrid = self.world.BattleCollistionSystem:PosToGrid(x - halfRadius,z + rangeRadius)
            endGrid = self.world.BattleCollistionSystem:PosToGrid(x + halfRadius,z - halfRadius)
        else
            local appendRadius = (range.appendModel and not range.passModel) and self.searchParam.entity.CollistionComponent:GetRadius() or 0
            beginGrid = self.world.BattleCollistionSystem:PosToGrid(x - (range.radius + appendRadius),z + (range.radius + appendRadius))
            endGrid = self.world.BattleCollistionSystem:PosToGrid(x + (range.radius + appendRadius),z - (range.radius + appendRadius))
        end
        
        entityGroups = self.world.BattleCollistionSystem:GetRangeEntitys(beginGrid,endGrid)
    end
    
    local tempEntitys = {}
    for i,entityGroup in ipairs(entityGroups) do
        for v in entityGroup:Items() do
            local targetEntityUid = v.value
            if not tempEntitys[targetEntityUid] then
                tempEntitys[targetEntityUid] = true
                
                local targetEntity = nil
                if self.world.EntitySystem:HasEntity(targetEntityUid) then
                    targetEntity = self.world.EntitySystem:GetEntity(targetEntityUid)
                end

                if targetEntity and targetEntity.HitComponent and targetEntity.HitComponent:IsEnable() then
                    local flag = true
                    if self.searchParam.passEntitys and self.searchParam.passEntitys[targetEntity.uid] then flag = false end
                    if flag then flag = self:IsCanSelect(targetEntity,self.searchParam.targetArgs) end
                    if flag then flag = self:IsTargetType(self.searchParam.entity,targetEntity,self.searchParam.targetArgs) end
                    if flag then
                        local inRange = self:InRangeEntity(self.searchParam.entity,targetEntity,self.searchParam.transInfo,range)
                        if inRange then
                            table.insert(entitys,targetEntity.uid)
                            entityDict[targetEntity.uid] = true
                        end
                    end
                end
            end
        end
    end

    if param.notFilterAndCull then
        return entitys,entityDict
    end
    
	entitys = self:SelectEntity(entitys,entityDict,true)

	return entitys,entityDict
end

function BattlePvpSearchSystem:OnLateUpdate()
    --Log("迭代次数",self.world.EntitySystem.entityList.length,self.searchByRangeNum,self.num,self.debugTime)
    --Log("迭代时间",DEBUG_TIME)
    --DEBUG_TIME = 0
end

function BattlePvpSearchSystem:IsCanSelect(entity,targetArgs)
    if not targetArgs then
        return true
    end

	if not self.world.PluginSystem.EntityStateCheck:CanBeSelect(entity) then
        return false
    end

    local isLock = self.searchParam.isLock or false
    local isSelectEnemy = targetArgs.targetCamp == BattleDefine.TargetCampType.enemy

    if isSelectEnemy and isLock and entity.BuffComponent:HasBuffState(BattleDefine.BuffState.not_be_select) then
        return false
    end

	-- if operateType == FindEntityDefine.OperateType.atk then
	-- 	return entity:CanDoAttack()
	-- end

	return true
end

--实体是否在范围内
local fpVec2_1 = FPVector2(0,0)
local fpVec2_2 = FPVector2(0,0)
local fpVec2_3 = FPVector2(0,0)
local fpVec2_4 = FPVector2(0,0)
function BattlePvpSearchSystem:InRangeEntity(srcEntity,targetEntity,transInfo,range)
	local curTargetPos = targetEntity.TransformComponent.pos
    fpVec2_1:Set(curTargetPos.x,curTargetPos.z)
	local targetPos = fpVec2_1
    local targetRadius = targetEntity.CollistionComponent and targetEntity.CollistionComponent:GetRadius() or 0

	local x,z = self:GetPosByOfffset(transInfo.posX,transInfo.posZ,transInfo.dirX,transInfo.dirZ,range.offset)
    fpVec2_2:Set(x,z)
	local rangePos = fpVec2_2

	local inRange = false
	if range.type == BattleDefine.RangeType.full then
		inRange = true
	elseif range.type == BattleDefine.RangeType.circle then
        local appendRadius = (range.appendModel and not range.passModel) and srcEntity.CollistionComponent:GetRadius() or 0
        inRange = FPCollision2D.CircleInCircle(targetPos,targetRadius,rangePos,range.radius + appendRadius)
	elseif range.type == BattleDefine.RangeType.annulus then
        local appendRadius = (range.appendModel and not range.passModel) and srcEntity.CollistionComponent:GetRadius() or 0
		inRange = FPCollision2D.CircleInAnnulus(targetPos,targetRadius,rangePos,range.radius,range.inRadius + appendRadius)
	elseif range.type == BattleDefine.RangeType.sector then
		local sectorDir = vint2_3
		sectorDir:Set(transInfo.dirX,transInfo.dirZ)
		inRange = IntMath.CircleInSector(targetPos,targetRadius,rangePos,sectorDir,range.angle,range.radius)
	elseif range.type == BattleDefine.RangeType.annulus_sector then
		local sectorDir = vint2_3
		sectorDir:Set(transInfo.dirX,transInfo.dirZ)
		inRange = IntMath.CircleInAnnulusSector(targetPos,targetRadius,rangePos,sectorDir,range.angle,range.radius,range.inRadius)
	elseif range.type == BattleDefine.RangeType.aabb then
        fpVec2_3:Set(range.width,range.height)
        local size = fpVec2_3
        local rangeRadius = FPMath.Divide(FPMath.Max(range.width,range.height),2)
		inRange = FPCollision2D.AABBInCircle(rangePos,rangeRadius,size,targetPos,targetRadius)
	elseif range.type == BattleDefine.RangeType.obb then
        fpVec2_3:Set(range.width,range.height)
        local size = fpVec2_3
        fpVec2_4:Set(transInfo.dirX,transInfo.dirZ)
		local dir = fpVec2_4
        local rangeRadius = FPMath.Divide(FPMath.Max(range.width,range.height),2) 
		inRange = FPCollision2D.CircleInOBB(targetPos,targetRadius,rangePos,rangeRadius,size,dir)
	elseif range.type == BattleDefine.RangeType.polygon then
		vint22:Set(transInfo.posX,transInfo.dirZ)
		if range.dir == 1 then
			vint23:Set(transInfo.dirX,transInfo.dirZ)
			inRange = IntMath.PointInDirPolygon(vint21,vint22,vint23,range.pos)
		else
			VInt2.Sub(vint21,vint22,vint23)
			inRange = IntMath.PointInPolygon(vint23,range.pos)
		end
	end

	if range.reverse and range.reverse == 1 then
		inRange = not inRange
	end

	return inRange
end

function BattlePvpSearchSystem:GetPosByOfffset(posX,posZ,dirX,dirZ,offset)
	if not offset or offset == 0 then
		return posX,posZ
    else
        local offsetPosX = FPFloat.Mul_ii(dirX,offset)
        local offsetPosZ = FPFloat.Mul_ii(dirZ,offset)
        return posX + offsetPosX,posZ + offsetPosZ
	end
end


function BattlePvpSearchSystem:IsTargetTypeByTargetId(entity,targetUid,targetCondId)
	local targetEntity = self.world.EntitySystem:GetEntity(targetUid)
    if targetEntity then 
        local targetArgs = self.world.BattleMixedSystem:GetTargetArgs(targetCondId)
        return self:IsTargetType(entity,targetEntity,targetArgs)
    else
        return false
    end
end

function BattlePvpSearchSystem:IsTargetType(entity,targetEntity,targetArgs)
    --LogTable("目标参数",targetArgs)
    if not entity or not targetEntity then
        return false
    end

    if not targetArgs then
        return true
    end
    
    local camp = entity.CampComponent:GetCamp()
    local targetCamp = targetEntity.CampComponent:GetCamp()

    --过滤掉不同阵营
    if targetArgs.targetCamp ~= 0 then
        if targetArgs.targetCamp == BattleDefine.TargetCampType.self and entity.uid ~= targetEntity.uid then
            return false
        elseif targetArgs.targetCamp == BattleDefine.TargetCampType.friend and (camp ~= targetCamp or entity.uid == targetEntity.uid) then
            return false
        elseif targetArgs.targetCamp == BattleDefine.TargetCampType.friend_in_self and camp ~= targetCamp then
            return false
        elseif targetArgs.targetCamp == BattleDefine.TargetCampType.enemy and camp == targetCamp then
            return false
        end
    end

    local unitConf = targetEntity.ObjectDataComponent.unitConf

    --过滤掉目标单位类型
    if targetArgs.targetTypes and not targetArgs.targetTypes[0] and not targetArgs.targetTypes[unitConf.type] then
        return false
    end

    --过滤掉移动方式
    local targetWalkType = targetEntity.ObjectDataComponent:GetWalkType()
    if targetArgs.walkType and targetArgs.walkType ~= 0 and targetWalkType ~= targetArgs.walkType then
        return false
    end

    --过滤掉目标生命类型
    if targetArgs.targetLifeTypes and not targetArgs.targetLifeTypes[0] and not targetArgs.targetLifeTypes[unitConf.life_type] then
        return false
    end

    --过滤掉种族类型
    if targetArgs.raceTypes and not targetArgs.raceTypes[0] and not targetArgs.raceTypes[unitConf.race_type] then
        return false
    end

    --过滤不符合条件的单位
    if targetArgs.targetConds and not self.world.PluginSystem.CheckCond:IsCond(targetEntity.uid,targetArgs.targetConds,{fromEntityUid=entity.uid,targetEntityUids={targetEntity.uid}}) then
        return false
    end

    return true
end

function BattlePvpSearchSystem:SelectEntity(entitys,entityDict,isCull)
    if #entitys <= 0 then
        return entitys
    end

	local targetNum = self.searchParam.targetNum
	local priorityEntityUid = self.searchParam.priorityEntityUid
    local selfEntity = self.searchParam.entity
    
    entitys = self:EntitySort(entitys)

    --优选目标（嘲讽等）
	-- local isPrioritySelect = false
	-- if #entitys > 1 then
	-- 	local swapIndex = nil
	-- 	for i,v in ipairs(entitys) do
	-- 		local flag = Facade.GetCtrl(BattleEventCtrl):OnSelectTarget(selfEntity.data.id,v)
	-- 		if flag then
	-- 			swapIndex = i
	-- 			break
	-- 		end
	-- 	end

	-- 	if swapIndex and swapIndex ~= 1 then
	-- 		local swapId = entitys[swapIndex]
	-- 		entitys[swapIndex] = entitys[1]
	-- 		entitys[1] = swapId
	-- 		isPrioritySelect = true
	-- 	end
	-- end

     --优选目标（嘲讽等）
    local isPrioritySelect = false
    if #entitys > 1 then
        local prioritySelectEntity = self.world.EventTriggerSystem:Trigger(BattleEvent.priority_select_unit,selfEntity.uid,entityDict)
        if prioritySelectEntity then
            isPrioritySelect = true
            local index = BaseUtils.FindTableIndex(entitys,prioritySelectEntity)
            if index and index ~= 1 then
                table.remove(entitys,index)
                table.insert(entitys,1,prioritySelectEntity)
            end
        end
    end

    --如果没优先选到，尝试把优先的实体往第一个排
	if not isPrioritySelect and priorityEntityUid and priorityEntityUid ~= -1 then
		local index = BaseUtils.FindTableIndex(entitys,priorityEntityUid)
		if index and index ~= 1 then
			table.remove(entitys,index)
			table.insert(entitys,1,priorityEntityUid)
		end
	end

    --移除多余的实体（比如本来选了10，但是目标数量只有3，那么会移除后7个）
    if targetNum > 0 and isCull then
        for i=#entitys,1,-1 do
            if #entitys > targetNum then
                entityDict[entitys[i]] = nil
                table.remove(entitys,i)
            else
                break
            end
        end
    end

    return entitys
end