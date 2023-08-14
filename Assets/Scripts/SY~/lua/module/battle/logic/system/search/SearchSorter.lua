SearchSorter = ExtendClass(BattleSearchSystem)
--TODO:检查排序的稳定

function SearchSorter:InitSort()
	self.sortMappings = 
	{
		[BattleDefine.SearchPriority.min_to_self_dis] = {func = self:ToFunc("min_to_self_dis"),action = self:ToFunc("min_to_self_dis_Action")},
		[BattleDefine.SearchPriority.max_to_self_dis] = {func = self:ToFunc("max_to_self_dis"),action = self:ToFunc("max_to_self_dis_Action")},
		[BattleDefine.SearchPriority.min_to_self_home_dis] = {func = self:ToFunc("min_to_self_home_dis"),action = self:ToFunc("min_to_self_home_dis_Action")},
		[BattleDefine.SearchPriority.max_to_self_home_dis] = {func = self:ToFunc("max_to_self_home_dis"),action = self:ToFunc("max_to_self_home_dis_Action")},
		[BattleDefine.SearchPriority.min_to_enemy_home_dis] = {func = self:ToFunc("min_to_enemy_home_dis"),action = self:ToFunc("min_to_enemy_home_dis_Action")},
		[BattleDefine.SearchPriority.max_to_enemy_home_dis] = {func = self:ToFunc("max_to_enemy_home_dis"),action = self:ToFunc("max_to_enemy_home_dis_Action")},
		[BattleDefine.SearchPriority.floor_walk_unit] = {func = self:ToFunc("floor_walk_unit"),action = self:ToFunc("floor_walk_unit_Action")},
		[BattleDefine.SearchPriority.fly_walk_unit] = {func = self:ToFunc("fly_walk_unit"),action = self:ToFunc("fly_walk_unit_Action")},
		[BattleDefine.SearchPriority.hp_low] = {func = self:ToFunc("hp_low"),action = self:ToFunc("hp_low_Action")},
		[BattleDefine.SearchPriority.hp_height] = {func = self:ToFunc("hp_height"),action = self:ToFunc("hp_height_Action")},
		[BattleDefine.SearchPriority.hp_ratio_low] = {func = self:ToFunc("hp_ratio_low"),action = self:ToFunc("hp_ratio_low_Action")},
		[BattleDefine.SearchPriority.hp_ratio_height] = {func = self:ToFunc("hp_ratio_height"),action = self:ToFunc("hp_ratio_height_Action")},
		[BattleDefine.SearchPriority.max_hp_low] = {func = self:ToFunc("max_hp_low"),action = self:ToFunc("max_hp_low_Action")},
		[BattleDefine.SearchPriority.max_hp_height] = {func = self:ToFunc("max_hp_height"),action = self:ToFunc("max_hp_height_Action")},
		[BattleDefine.SearchPriority.atk_low] = {func = self:ToFunc("atk_low"),action = self:ToFunc("atk_low_Action")},
		[BattleDefine.SearchPriority.atk_height] = {func = self:ToFunc("atk_height"),action = self:ToFunc("atk_height_Action")},
	}
end

function SearchSorter:EntitySort(targets)

	if self.searchParam.checkCampSort then
		local selfCamp = self.searchParam.entity.CampComponent:GetCamp()
		local curPos = self.searchParam.entity.TransformComponent:GetPos()
		--local curPosX,curPosZ = self.searchParam.transInfo.posX,self.searchParam.transInfo.posZ
		self.isSelfAreaCamp = self.world.BattleTerrainSystem:PosToCamp(curPos.x,curPos.z,selfCamp) == selfCamp
	end

    local priorityType = self.searchParam.priorityType1

	if priorityType == BattleDefine.SearchPriority.default then
		if self.searchParam.checkCampSort then
			table.sort(targets,self:ToFunc("default"))
		else
			return targets
		end
	elseif priorityType == BattleDefine.SearchPriority.random then
        if #targets > self.searchParam.targetNum then
            local waitRandomTargets = targets
            targets = {}
            for i=1,self.searchParam.targetNum do
                local index = self.world.BattleRandomSystem:Random(1,#waitRandomTargets)
                table.insert(targets,waitRandomTargets[index])
                table.remove(waitRandomTargets,index)
			end
		end
	else
		local sortMapping = self.sortMappings[priorityType]
		table.sort(targets,sortMapping.func)
    end

    return targets
end

--进行二级优先判定（这里并不是又排一次序，只是将需要对比的二级属性进行判定）
function SearchSorter:LastSortResult(a,b)
	local priorityType = self.searchParam.priorityType2
    if not priorityType or priorityType == BattleDefine.SearchPriority.default then
        return false
	elseif priorityType == BattleDefine.SearchPriority.random then
		return false
	else
		local sortMapping = self.sortMappings[priorityType]
		return sortMapping.action(a,b)
	end
end


function SearchSorter:CheckLastSortResult(flag,a,b)
	if flag then
		return true
	elseif flag == nil then
		return false
	else
		flag = self:LastSortResult(a,b)
		if flag then
			return true
		elseif flag == nil then
			return false
		else
			if self.searchParam.checkCampSort then
				if self.isSelfAreaCamp then
					flag = self:min_to_self_home_dis_Action(a,b)
				else
					flag = self:min_to_self_dis_Action(a,b)
				end

				if flag then
					return true
				elseif flag == nil then
					return false
				end
			end

			return self:SortIndex(a,b)
		end
	end
end

function SearchSorter:SortIndex(a,b)
    local aEntity = self.world.EntitySystem:GetEntity(a)
	local bEntity = self.world.EntitySystem:GetEntity(b)
    return aEntity.uid < bEntity.uid
end

function SearchSorter:default(a,b)
	return self:CheckLastSortResult(false,a,b)
end

--以下为具体排序对比规则

--优先离自己最近距离单位（直线距离）
function SearchSorter:min_to_self_dis(a,b)
	local flag = self:min_to_self_dis_Action(a,b)
	return self:CheckLastSortResult(flag,a,b)
end

function SearchSorter:min_to_self_dis_Action(a,b)
	local curPosX,curPosZ = self.searchParam.transInfo.posX,self.searchParam.transInfo.posZ

	local aEntity = self.world.EntitySystem:GetEntity(a)
	local bEntity = self.world.EntitySystem:GetEntity(b)

	local aPos = aEntity.TransformComponent:GetPos()
	local bPos = bEntity.TransformComponent:GetPos()

	local aMagnitude = BattleUtils.CalMagnitude(curPosX,curPosZ,aPos.x,aPos.z)
	local bMagnitude = BattleUtils.CalMagnitude(curPosX,curPosZ,bPos.x,bPos.z)

	if aMagnitude < bMagnitude then
		return true
	elseif aMagnitude > bMagnitude then
		return nil
	else
		return false
	end
end


--优先离自己最远距离单位（直线距离）
function SearchSorter:max_to_self_dis(a,b)
	local flag = self:max_to_self_dis_Action(a,b)
	return self:CheckLastSortResult(flag,a,b)
end

function SearchSorter:max_to_self_dis_Action(a,b)
	local curPosX,curPosZ = self.searchParam.transInfo.posX,self.searchParam.transInfo.posZ

	local aEntity = self.world.EntitySystem:GetEntity(a)
	local bEntity = self.world.EntitySystem:GetEntity(b)

	local aPos = aEntity.TransformComponent:GetPos()
	local bPos = bEntity.TransformComponent:GetPos()

	local aMagnitude = BattleUtils.CalMagnitude(curPosX,curPosZ,aPos.x,aPos.z)
	local bMagnitude = BattleUtils.CalMagnitude(curPosX,curPosZ,bPos.x,bPos.z)

	if aMagnitude > bMagnitude then
		return true
	elseif aMagnitude < bMagnitude then
		return nil
	else
		return false
	end
end


--离自己主堡最近
function SearchSorter:min_to_self_home_dis(a,b)
	local flag = self:min_to_self_home_dis_Action(a,b)
	return self:CheckLastSortResult(flag,a,b)
end

function SearchSorter:min_to_self_home_dis_Action(a,b)
	local camp = self.searchParam.entity.CampComponent:GetCamp()
	local homeUid = self.world.BattleDataSystem:GetHomeUid(camp)
	local homeEntity = self.world.EntitySystem:GetEntity(homeUid)
	if not homeEntity then
		return false
	end
	local homePos = homeEntity.TransformComponent:GetPos()

	local aEntity = self.world.EntitySystem:GetEntity(a)
	local bEntity = self.world.EntitySystem:GetEntity(b)

	local aPos = aEntity.TransformComponent:GetPos()
	local bPos = bEntity.TransformComponent:GetPos()

	local aMagnitude = BattleUtils.CalMagnitude(homePos.x,homePos.z,aPos.x,aPos.z)
	local bMagnitude = BattleUtils.CalMagnitude(homePos.x,homePos.z,bPos.x,bPos.z)

	if aMagnitude < bMagnitude then
		return true
	elseif aMagnitude > bMagnitude then
		return nil
	else
		return false
	end
end


--离自己主堡最远
function SearchSorter:max_to_self_home_dis(a,b)
	local flag = self:max_to_self_home_dis_Action(a,b)
	return self:CheckLastSortResult(flag,a,b)
end

function SearchSorter:max_to_self_home_dis_Action(a,b)
	local camp = self.searchParam.entity.CampComponent:GetCamp()
	local homeUid = self.world.BattleDataSystem:GetHomeUid(camp)
	local homeEntity = self.world.EntitySystem:GetEntity(homeUid)
	local homePos = homeEntity.TransformComponent:GetPos()

	local aEntity = self.world.EntitySystem:GetEntity(a)
	local bEntity = self.world.EntitySystem:GetEntity(b)

	local aPos = aEntity.TransformComponent:GetPos()
	local bPos = bEntity.TransformComponent:GetPos()

	local aMagnitude = BattleUtils.CalMagnitude(homePos.x,homePos.z,aPos.x,aPos.z)
	local bMagnitude = BattleUtils.CalMagnitude(homePos.x,homePos.z,bPos.x,bPos.z)

	if aMagnitude > bMagnitude then
		return true
	elseif aMagnitude < bMagnitude then
		return nil
	else
		return false
	end
end



--离敌方堡最近
function SearchSorter:min_to_enemy_home_dis(a,b)
	local flag = self:min_to_enemy_home_dis_Action(a,b)
	return self:CheckLastSortResult(flag,a,b)
end

function SearchSorter:min_to_enemy_home_dis_Action(a,b)
	local camp = self.searchParam.entity.CampComponent:GetEnemyCamp()
	local homeUid = self.world.BattleDataSystem:GetHomeUid(camp)
	local homeEntity = self.world.EntitySystem:GetEntity(homeUid)
	local homePos = homeEntity.TransformComponent:GetPos()

	local aEntity = self.world.EntitySystem:GetEntity(a)
	local bEntity = self.world.EntitySystem:GetEntity(b)

	local aPos = aEntity.TransformComponent:GetPos()
	local bPos = bEntity.TransformComponent:GetPos()

	local aMagnitude = FPMath.Abs(homePos.z - aPos.z)
	local bMagnitude = FPMath.Abs(homePos.z - bPos.z)

	if aMagnitude < bMagnitude then
		return true
	elseif aMagnitude > bMagnitude then
		return nil
	else
		return false
	end
end


--离敌方堡最远
function SearchSorter:max_to_enemy_home_dis(a,b)
	local flag = self:max_to_enemy_home_dis_Action(a,b)
	return self:CheckLastSortResult(flag,a,b)
end

function SearchSorter:max_to_enemy_home_dis_Action(a,b)
	local camp = self.searchParam.entity.CampComponent:GetEnemyCamp()
	local homeUid = self.world.BattleDataSystem:GetHomeUid(camp)
	local homeEntity = self.world.EntitySystem:GetEntity(homeUid)
	local homePos = homeEntity.TransformComponent:GetPos()

	local aEntity = self.world.EntitySystem:GetEntity(a)
	local bEntity = self.world.EntitySystem:GetEntity(b)

	local aPos = aEntity.TransformComponent:GetPos()
	local bPos = bEntity.TransformComponent:GetPos()

	local aMagnitude = FPMath.Abs(homePos.z - aPos.z)
	local bMagnitude = FPMath.Abs(homePos.z - bPos.z)

	if aMagnitude > bMagnitude then
		return true
	elseif aMagnitude < bMagnitude then
		return nil
	else
		return false
	end
end



--地面单位
function SearchSorter:floor_walk_unit(a,b)
	local flag = self:floor_walk_unit_Action(a,b)
	return self:CheckLastSortResult(flag,a,b)
end

function SearchSorter:floor_walk_unit_Action(a,b)
	local aEntity = self.world.EntitySystem:GetEntity(a)
	local bEntity = self.world.EntitySystem:GetEntity(b)

	local aWalkType = aEntity.ObjectDataComponent:GetWalkType()
	local bWalkType = bEntity.ObjectDataComponent:GetWalkType()

	if aWalkType == BattleDefine.WalkType.floor and bWalkType == BattleDefine.WalkType.fly then
		return true
	elseif aWalkType == BattleDefine.WalkType.fly and bWalkType == BattleDefine.WalkType.floor then
		return nil
	else
		return false
	end
end


--飞行单位
function SearchSorter:fly_walk_unit(a,b)
	local flag = self:fly_walk_unit_Action(a,b)
	return self:CheckLastSortResult(flag,a,b)
end

function SearchSorter:fly_walk_unit_Action(a,b)
	local aEntity = self.world.EntitySystem:GetEntity(a)
	local bEntity = self.world.EntitySystem:GetEntity(b)

	local aWalkType = aEntity.ObjectDataComponent:GetWalkType()
	local bWalkType = bEntity.ObjectDataComponent:GetWalkType()

	if aWalkType == BattleDefine.WalkType.fly and bWalkType == BattleDefine.WalkType.floor then
		return true
	elseif aWalkType == BattleDefine.WalkType.floor and bWalkType == BattleDefine.WalkType.fly then
		return nil
	else
		return false
	end
end


--血量低
function SearchSorter:hp_low(a,b)
	local flag = self:hp_low_Action(a,b)
	return self:CheckLastSortResult(flag,a,b)
end

function SearchSorter:hp_low_Action(a,b)
	local aEntity = self.world.EntitySystem:GetEntity(a)
	local bEntity = self.world.EntitySystem:GetEntity(b)

	local aHp = aEntity.AttrComponent:GetValue(BattleDefine.Attr.hp)
	local bHp = bEntity.AttrComponent:GetValue(BattleDefine.Attr.hp)

	if aHp < bHp then
		return true
	elseif aHp > bHp then
		return nil
	else
		return false
	end
end


--血量高
function SearchSorter:hp_height(a,b)
	local flag = self:hp_height_Action(a,b)
	return self:CheckLastSortResult(flag,a,b)
end

function SearchSorter:hp_height_Action(a,b)
	local aEntity = self.world.EntitySystem:GetEntity(a)
	local bEntity = self.world.EntitySystem:GetEntity(b)

	local aHp = aEntity.AttrComponent:GetValue(BattleDefine.Attr.hp)
	local bHp = bEntity.AttrComponent:GetValue(BattleDefine.Attr.hp)

	if aHp > bHp then
		return true
	elseif aHp < bHp then
		return nil
	else
		return false
	end
end


--血量比例低
function SearchSorter:hp_ratio_low(a,b)
	local flag = self:hp_ratio_low_Action(a,b)
	return self:CheckLastSortResult(flag,a,b)
end

function SearchSorter:hp_ratio_low_Action(a,b)
	local aEntity = self.world.EntitySystem:GetEntity(a)
	local bEntity = self.world.EntitySystem:GetEntity(b)

	local aHpRatio = aEntity.AttrComponent:GetHpRatio()
	local bHpRatio = bEntity.AttrComponent:GetHpRatio()

	if aHpRatio < bHpRatio then
		return true
	elseif aHpRatio > bHpRatio then
		return nil
	else
		return false
	end
end


--血量比例高
function SearchSorter:hp_ratio_height(a,b)
	local flag = self:hp_ratio_height_Action(a,b)
	return self:CheckLastSortResult(flag,a,b)
end

function SearchSorter:hp_ratio_height_Action(a,b)
	local aEntity = self.world.EntitySystem:GetEntity(a)
	local bEntity = self.world.EntitySystem:GetEntity(b)

	local aHpRatio = aEntity.AttrComponent:GetHpRatio()
	local bHpRatio = bEntity.AttrComponent:GetHpRatio()

	if aHpRatio > bHpRatio then
		return true
	elseif aHpRatio < bHpRatio then
		return nil
	else
		return false
	end
end


--血量上限低
function SearchSorter:max_hp_low(a,b)
	local flag = self:max_hp_low_Action(a,b)
	return self:CheckLastSortResult(flag,a,b)
end

function SearchSorter:max_hp_low_Action(a,b)
	local aEntity = self.world.EntitySystem:GetEntity(a)
	local bEntity = self.world.EntitySystem:GetEntity(b)

	local aMaxHp = aEntity.AttrComponent:GetValue(GDefine.Attr.max_hp)
	local bMaxHp = bEntity.AttrComponent:GetValue(GDefine.Attr.max_hp)

	if aHp < bHp then
		return true
	elseif aHp > bHp then
		return nil
	else
		return false
	end
end


--血量上限高
function SearchSorter:max_hp_height(a,b)
	local flag = self:max_hp_height_Action(a,b)
	return self:CheckLastSortResult(flag,a,b)
end

function SearchSorter:max_hp_height_Action(a,b)
	local aEntity = self.world.EntitySystem:GetEntity(a)
	local bEntity = self.world.EntitySystem:GetEntity(b)

	local aMaxHp = aEntity.AttrComponent:GetValue(GDefine.Attr.max_hp)
	local bMaxHp = bEntity.AttrComponent:GetValue(GDefine.Attr.max_hp)

	if aHp > bHp then
		return true
	elseif aHp < bHp then
		return nil
	else
		return false
	end
end


--攻击低
function SearchSorter:atk_low(a,b)
	local flag = self:atk_low_Action(a,b)
	return self:CheckLastSortResult(flag,a,b)
end

function SearchSorter:atk_low_Action(a,b)
	local aEntity = self.world.EntitySystem:GetEntity(a)
	local bEntity = self.world.EntitySystem:GetEntity(b)

	local aAtkHp = aEntity.AttrComponent:GetValue(GDefine.Attr.atk)
	local bAtkHp = bEntity.AttrComponent:GetValue(GDefine.Attr.atk)

	if aAtkHp < bAtkHp then
		return true
	elseif aAtkHp > bAtkHp then
		return nil
	else
		return false
	end
end


--攻击低
function SearchSorter:atk_height(a,b)
	local flag = self:atk_height_Action(a,b)
	return self:CheckLastSortResult(flag,a,b)
end

function SearchSorter:atk_height_Action(a,b)
	local aEntity = self.world.EntitySystem:GetEntity(a)
	local bEntity = self.world.EntitySystem:GetEntity(b)

	local aAtkHp = aEntity.AttrComponent:GetValue(GDefine.Attr.atk)
	local bAtkHp = bEntity.AttrComponent:GetValue(GDefine.Attr.atk)

	if aAtkHp > bAtkHp then
		return true
	elseif aAtkHp < bAtkHp then
		return nil
	else
		return false
	end
end





-- function FindEntitySort.SortMaxDmgNum(a,b)
-- 	local flag = FindEntitySort.SortMaxDmgNumAction(a,b)
-- 	return FindEntitySort.ReturnSortResult(flag,a,b)
-- end

-- function FindEntitySort.SortMaxDmgNumAction(a,b)
-- 	if not curFindParam.skill then
-- 		return false
-- 	end
	 
-- 	local aEntity = Facade.GetProxy(BattleEntityProxy):GetEntity(a)
-- 	local bEntity = Facade.GetProxy(BattleEntityProxy):GetEntity(b)

-- 	local transInfo1 = SkillUtils.GetTransInfo(curFindParam.skill,curFindParam.entity,aEntity)
-- 	local num1 = GeometryFindEntity.GetEntityNum(curFindParam,transInfo1,curFindParam.dmgRange)

-- 	local transInfo2 = SkillUtils.GetTransInfo(curFindParam.skill,curFindParam.entity,bEntity)
-- 	local num2 = GeometryFindEntity.GetEntityNum(curFindParam,transInfo2,curFindParam.dmgRange)

-- 	if num1 > num2 then
-- 		return true
-- 	elseif num1 < num2 then
-- 		return nil
-- 	else
-- 		return false
-- 	end
-- end