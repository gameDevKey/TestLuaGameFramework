BattleMixedSystem = BaseClass("BattleMixedSystem",SECBEntitySystem)

function BattleMixedSystem:__Init()
    self.placeGridToRowCol = {}
    self.placeRowColToGrid = {}
end

function BattleMixedSystem:__Delete()
    self:ClearCameraShakeAnim()
end

function BattleMixedSystem:OnInitSystem()
    for grid = 1,BattleDefine.PlaceSlotNum do
		local row = FPMath.Divide(grid - 1,BattleDefine.PlaceGridCol) + 1
		local col = (grid - 1) % BattleDefine.PlaceGridCol + 1
		if not self.placeRowColToGrid[row] then
			self.placeRowColToGrid[row] = {}
		end
		self.placeRowColToGrid[row][col] = grid
		self.placeGridToRowCol[grid] = {row,col}
	end
end

function BattleMixedSystem:OnLateInitSystem()
    self.world.EventTriggerSystem:AddListener(BattleEvent.unit_die,self:ToFunc("UnitDieAddMoney"))
end

function BattleMixedSystem:UnitDieAddMoney(eventParams)
    local dieEntity = self.world.EntitySystem:GetEntity(eventParams.dieEntityUid)
    local unitId = dieEntity.ObjectDataComponent.unitConf.id
    local star = dieEntity.ObjectDataComponent:GetStar() or 0

    local conf = self.world.BattleConfSystem:UnitData_data_kill_res(unitId,star)
    if not conf then
        return
    end

    local addMoneyCamp = self.world.BattleMixedSystem:GetReverseCamp(dieEntity.CampComponent:GetCamp())

    for _,roleUid in ipairs(self.world.BattleDataSystem:GetCampRoleUid(addMoneyCamp)) do
        self.world.BattleDataSystem:AddRoleMoney(roleUid,conf.res)
    end

    self.world.ClientIFacdeSystem:Call("SendEvent","BattleInfoView","RefreshMoney")
    self.world.ClientIFacdeSystem:Call("SendEvent","BattleHeroGridView","RefreshExtGrid")
end

function BattleMixedSystem:GetPlaceSlotPos(index)
    local gridNode = BattleDefine.nodeObjs["mixed/operate/place_slot"]:Find(tostring(index))
    return gridNode.position
end

function BattleMixedSystem:GetRotateDependCamp()
    local camp = self.world.BattleDataSystem.enterExtraData.selfCamp
    local dir = self:GetCampIndex(camp)
    local rotate = Quaternion.AngleAxis(dir<0 and 180 or 0, Vector3.up)
    return rotate
end

function BattleMixedSystem:GetInitTargetPos(camp)
    local dir = self:GetCampIndex(camp)
    return BattleDefine.StancePos[dir][-1]
end

function BattleMixedSystem:GetStanceDir(camp)
    local dir = self:GetCampIndex(camp)
	local rotate = FPQuaternion.LookRotation(FPVector3(0,0,dir * 1000))
    return rotate
end

function BattleMixedSystem:IsSelfCamp(camp)
    return self.world.BattleDataSystem.enterExtraData.selfCamp == camp
end

function BattleMixedSystem:GetReverseCamp(camp)
    return camp == BattleDefine.Camp.attack and BattleDefine.Camp.defence or BattleDefine.Camp.attack
end

function BattleMixedSystem:GetCampIndex(camp)
    return camp == BattleDefine.Camp.attack and 1 or -1
end

function BattleMixedSystem:GetEnemyHomeUid(camp)
    local enemyCamp = camp == BattleDefine.Camp.attack and BattleDefine.Camp.defence or BattleDefine.Camp.attack
    return self.world.BattleDataSystem:GetHomeUid(enemyCamp)
end

function BattleMixedSystem:ChangeRange(fromRange,targetRange,changes)
    for k,v in pairs(fromRange) do
        targetRange[k] = v
    end
    for iter in changes:Items() do
        local args = iter.value
        local factor = 1
        if args.linkRound and args.linkRound == 1 then
            factor = self.world.BattleGroupSystem.group
        end
        if targetRange.type == RangeDefine.RangeType.circle then
            local val = self.world.PluginSystem.CalcAttr:CalcVal(fromRange.radius,args) * factor
            targetRange.radius = targetRange.radius + val
        elseif targetRange.type == RangeDefine.RangeType.annulus then
            local val = self.world.PluginSystem.CalcAttr:CalcVal(fromRange.radius,args) * factor
            targetRange.radius = targetRange.radius + val

            val = self.world.PluginSystem.CalcAttr:CalcVal(fromRange.inRadius,args) * factor
            targetRange.inRadius = targetRange.inRadius + val
        elseif targetRange.type == RangeDefine.RangeType.aabb or targetRange.type == RangeDefine.RangeType.obb then
            local val = self.world.PluginSystem.CalcAttr:CalcVal(fromRange.width,args) * factor
            targetRange.width = targetRange.width + val

            val = self.world.PluginSystem.CalcAttr:CalcVal(fromRange.height,args) * factor
            targetRange.height = targetRange.height + val
        end
    end
end


function BattleMixedSystem:GetGridListByOffset(grid,offset)

end

function BattleMixedSystem:GetGridDictByOffset(grid,offsets)
    local grids = {}

    local gridRowCol = self.placeGridToRowCol[grid]
    local row,col = gridRowCol[1],gridRowCol[2]
    for i,v in ipairs(offsets) do
        local newRow = row + v[1]
		local newCol = col + v[2]
        if self.placeRowColToGrid[newRow] and self.placeRowColToGrid[newRow][newCol] then
            local newGrid = self.placeRowColToGrid[newRow][newCol]
            grids[newGrid] = true
        end
	end
    return grids
end

function BattleMixedSystem:ShakeCamera(time,strength,vibrato,randomness)
	if self.cameraShakeAnim then 
		return
	end

	self.cameraShakeAnim = ShakePositionAnim.New(BattleDefine.nodeObjs["main_camera"].transform,time,strength,vibrato,randomness,false,true)
	self.cameraShakeAnim:SetTimeScale(true)
	self.cameraShakeAnim:SetComplete(self:ToFunc("CameraShakeAnimComplete"))
	self.cameraShakeAnim:Play()
end

function BattleMixedSystem:CameraShakeAnimComplete()
	self:ClearCameraShakeAnim()
end

function BattleMixedSystem:ClearCameraShakeAnim()
	if self.cameraShakeAnim then
		self.cameraShakeAnim:Destroy()
		self.cameraShakeAnim = nil
	end
end

function BattleMixedSystem:UpdateUnit(roleUid,unitId,grid,star)
    local camp = self.world.BattleDataSystem:GetCampByRoleUid(roleUid)
    local unitBaseData = self.world.BattleDataSystem:GetBaseUnitData(roleUid,unitId)
    if not unitBaseData then
        assert(false,string.format("不存在单位进场数据[角色uid:%s][单位Id:%s][阵营:%s]",roleUid,unitId,camp))
    end

    local newUnitData = self.world.BattleMixedSystem:CalcUpStarData(unitBaseData,star,grid)

    local srcUnitData = self.world.BattleDataSystem:GetUnitData(roleUid,unitId)

    self.world.BattleDataSystem:UpdateUnit(roleUid,newUnitData)
    
    --更新数据

    if srcUnitData then
        self.world.EventTriggerSystem:Trigger(BattleEvent.update_unit,roleUid,camp,unitId,grid)
    else
        self.world.EventTriggerSystem:Trigger(BattleEvent.place_unit,roleUid,camp,unitId,grid)
    end

    if srcUnitData then
        local curSkills = {}
        for _,v in ipairs(newUnitData.skill_list) do
            curSkills[v.skill_id] = true
        end

        local removeSkills = {}
        for _,v in ipairs(srcUnitData.skill_list) do
            if not curSkills[v.skill_id] then
                table.insert(removeSkills,v.skill_id)
            end
        end

        local existEntitys = self.world.EntitySystem:GetRoleEntitys(roleUid,unitId)
        for _,entityUid in ipairs(existEntitys) do
            local entity = self.world.EntitySystem:GetEntity(entityUid)

            entity.ObjectDataComponent:SetObjectData(newUnitData)
            entity.AttrComponent:UpdateSrcAttr(entity.ObjectDataComponent.objectData.attr_list)

            for _,v in ipairs(newUnitData.skill_list) do
                entity.SkillComponent:RepSkill(v.skill_id,v.skill_level,true)
            end
            for _,skillId in ipairs(removeSkills) do
                entity.SkillComponent:RemoveSKillById(skillId)
            end
            entity.SkillComponent:SortSkill()
        end

        self.world.ClientIFacdeSystem:Call("RefreshHeroGrid",roleUid)
    end

    local srcStar = srcUnitData and srcUnitData.star or 0
    local starOffset = star - srcStar
    if starOffset > 0 then
        self.world.ClientIFacdeSystem:Call("SendGuideEvent","PlayerGuideDefine","unit_up_star",roleUid,unitId,star)
    end
    self.world.ClientIFacdeSystem:Call("SendEvent","BattleStarUpView","UnitStarUpdate",roleUid,unitId,grid,star,srcStar)
    if roleUid ~= self.world.BattleDataSystem.roleUid then
        self.world.ClientIFacdeSystem:Call("SendEvent","BattleEnemyGridView","ActiveEnemyUnitStar",unitId,starOffset)
    end
end

function BattleMixedSystem:ExtendGrid(roleUid,grid)
    local unitData = {}
    unitData.grid_id = grid
    unitData.unit_id = 0
    self.world.BattleDataSystem:UpdateUnit(roleUid,unitData)
end

function BattleMixedSystem:SwapUnit(roleUid,toGrid,srcGrid)
    --Log("info",toGrid,srcGrid)
    local srcUnitData = self.world.BattleDataSystem:GetUnitDataByGrid(roleUid,srcGrid)
    if not srcUnitData then
        assert(false,string.format("交换单位异常，对应格子不存在单位[角色Uid:%s][格子:%s]",roleUid,srcGrid))
    end

    srcUnitData.grid_id = toGrid

    local toUnitData = self.world.BattleDataSystem:GetUnitDataByGrid(roleUid,toGrid)
    if not toUnitData then
        toUnitData = {}
        toUnitData.grid_id = srcGrid
        toUnitData.unit_id = 0
    else
        toUnitData.grid_id = srcGrid
    end

    self.world.BattleDataSystem:UpdateUnit(roleUid,toUnitData)
    self.world.BattleDataSystem:UpdateUnit(roleUid,srcUnitData)
end

function BattleMixedSystem:RemoveUnit(roleUid,grid)
    local camp = self.world.BattleDataSystem:GetCampByRoleUid(roleUid)
    local srcUnitData = self.world.BattleDataSystem:GetUnitDataByGrid(roleUid,grid)

    local unitData = {}
    unitData.grid_id = grid
    unitData.unit_id = 0
    self.world.BattleDataSystem:UpdateUnit(roleUid,unitData)

    self.world.EventTriggerSystem:Trigger(BattleEvent.cancel_unit,roleUid,camp,srcUnitData.unit_id,grid)
end

function BattleMixedSystem:CalcUpStarData(srcData,star,grid)
    local starConf = self.world.BattleConfSystem:UnitData_data_unit_star_info(srcData.unit_id,star)

    local upStarData = {}
    upStarData.grid_id = grid
    upStarData.unit_id = srcData.unit_id
    upStarData.star = star
    upStarData.skill_list = {}
    upStarData.attr_list = {}


    local attrDatas = {}
    for i,v in ipairs(srcData.attr_list) do
        local attrData = {attr_id = v.attr_id,attr_val = v.attr_val}
        table.insert(upStarData.attr_list,attrData)
        attrDatas[v.attr_id] = attrData
    end

    for i,v in ipairs(starConf.attr_list) do
        local attrId = GDefine.AttrNameToId[v[1]]
        local ratio = v[2]

        local attrData = attrDatas[attrId]

        local value = attrData and attrData.attr_val or 0
        value = FPMath.Divide(value * ratio,BattleDefine.AttrRatio)

        if attrData then
            attrData.attr_val = value
        else
            table.insert(upStarData.attr_list,{attr_id = attrId,attr_val = value})
        end
    end

    --
    for i,v in ipairs(srcData.skill_list) do
        local skillInfo = {}
        skillInfo.skill_id = v.skill_id
        skillInfo.skill_level = v.skill_level
        table.insert(upStarData.skill_list,skillInfo)
    end

    local skillLevUp = {}
    for i,v in ipairs(starConf.skill_lv_up) do
        local skillId = upStarData.skill_list[v[1]].skill_id
        local addLev = v[2]
        skillLevUp[skillId] = addLev
    end

    local skillCover = {}
    for i,v in ipairs(starConf.skill_cover) do
        skillCover[v[2]] = v[1]
    end

    for i = #upStarData.skill_list, 1,-1 do
        local skillInfo = upStarData.skill_list[i]
        if skillLevUp[skillInfo.skill_id] then
            skillInfo.skill_level = skillInfo.skill_level + skillLevUp[skillInfo.skill_id]
        end

        if skillCover[skillInfo.skill_id] then
            if skillCover[skillInfo.skill_id] == 0 then
                table.remove(upStarData.skill_list,i)
            else
                skillInfo.skill_id = skillCover[skillInfo.skill_id]
            end
        end
    end

    return upStarData
end


function BattleMixedSystem:GetTargetArgs(targetCondId,inArgs)
    if not targetCondId or targetCondId == 0 then
        return nil
    end

    local targetCondConf = self.world.BattleConfSystem:SkillData_data_target_cond(targetCondId)
    local targetArgs = {}
    if not inArgs then inArgs = {} end

	targetArgs.targetCamp = inArgs.targetCamp or targetCondConf.target_camp
	targetArgs.targetTypes = inArgs.targetTypes or targetCondConf.unit_type
	targetArgs.walkType = inArgs.walkType or targetCondConf.walk_type
	targetArgs.targetLifeTypes = inArgs.targetLifeTypes or targetCondConf.life_type
	targetArgs.raceTypes = inArgs.raceTypes or targetCondConf.race_type
	targetArgs.targetConds = inArgs.targetConds or targetCondConf.target_cond

    return targetArgs
end

function BattleMixedSystem:BattlePause(flag)
    if flag then
        Time.timeScale = 0.0
    else
        Time.timeScale = 1.0
    end
end