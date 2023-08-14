BattleInputSystem = BaseClass("BattleInputSystem",SECBClientInputSystem)

function BattleInputSystem:__Init()
	self.opIndex = 0
	self.inputOps = {}
end

function BattleInputSystem:__Delete()
end

function BattleInputSystem:OnInitSystem()

end

function BattleInputSystem:GetOpIndex()
	self.opIndex = self.opIndex + 1
	return self.opIndex
end

function BattleInputSystem:AddOp(opType)
	local flag = self:ExistOp(opType)
	if not flag then
		local opIndex = self:GetOpIndex()
		self.inputOps[opIndex] = opType
		return true,opIndex
	else
		return false,nil
	end
end

function BattleInputSystem:ExistOp(opType)
	for _,v in pairs(self.inputOps) do
		if v == opType then
			return true
		end
	end
	return false
end

function BattleInputSystem:UnlockOp(opIndex)
	if self.inputOps[opIndex] then
		self.inputOps[opIndex] = nil
	end
end

function BattleInputSystem:CleanOp()
	if self:ExistOp(BattleDefine.Operation.select_hero) then
		self.world.ClientIFacdeSystem:Call("SendEvent","BattleSelectHeroView","ActiveSelectHero",true)
	end
	self.inputOps = {}
end

function BattleInputSystem:AddRandomUnits()
	local flag,opIndex = self:AddOp(BattleDefine.Operation.random_hero)
	if not flag then
		SystemMessage.Show(TI18N("操作过于频繁"))
		return
	end

	if self.world.BattleStateSystem.localRun then
		local data = {}
		data.update_list = {}

		local randomInfo = {}
		randomInfo.operate_num = opIndex
		randomInfo.role_uid = self.world.BattleDataSystem.roleUid
		randomInfo.choose_unit_list = {}
		table.insert(data.update_list,randomInfo)

		self:AddInput(BattleDefine.Operation.random_hero,data)
	else
		mod.BattleFacade:SendMsg(10405,opIndex)
	end
end

function BattleInputSystem:AddSelectUnit(unitId)
	local flag,opIndex = self:AddOp(BattleDefine.Operation.select_hero)
	if not flag then
		SystemMessage.Show(TI18N("操作过于频繁"))
		return
	end

	if self.world.BattleStateSystem.localRun then
		local data = {}
		data.update_list = {}

		--
		local selectInfo = {}
		selectInfo.operate_num = opIndex
		selectInfo.role_uid = self.world.BattleDataSystem.roleUid
		selectInfo.operate_type = BattleDefine.ServerOperation.select_hero
		selectInfo.grid_list = {}

		local gridInfo = {}
		gridInfo.grid_id = 0
		gridInfo.unit_id = unitId
		table.insert(selectInfo.grid_list,gridInfo)

		--
		table.insert(data.update_list,selectInfo)

		self:AddInput(BattleDefine.Operation.update_hero,data)
	else
		mod.BattleFacade:SendMsg(10406,opIndex,unitId)
	end
end

function BattleInputSystem:AddExtendGrid(grid)
	local flag,opIndex = self:AddOp(BattleDefine.Operation.extend_grid)
	if not flag then
		SystemMessage.Show(TI18N("操作过于频繁"))
		return
	end

	if self.world.BattleStateSystem.localRun then
		local data = {}
		data.update_list = {}

		--
		local selectInfo = {}
		selectInfo.operate_num = opIndex
		selectInfo.role_uid = self.world.BattleDataSystem.roleUid
		selectInfo.operate_type = BattleDefine.ServerOperation.extend_grid
		selectInfo.grid_list = {}

		local gridInfo = {}
		gridInfo.grid_id = grid
		gridInfo.unit_id = 0
		table.insert(selectInfo.grid_list,gridInfo)

		--
		table.insert(data.update_list,selectInfo)

		self:AddInput(BattleDefine.Operation.update_hero,data)
	else
		mod.BattleFacade:SendMsg(10407,opIndex,grid)
	end
end


function BattleInputSystem:AddSellHero(grid)
	local flag,opIndex = self:AddOp(BattleDefine.Operation.sell_hero)
	if not flag then
		SystemMessage.Show(TI18N("操作过于频繁"))
		return
	end

	if self.world.BattleStateSystem.localRun then
		local data = {}
		data.update_list = {}

		--
		local selectInfo = {}
		selectInfo.operate_num = opIndex
		selectInfo.role_uid = self.world.BattleDataSystem.roleUid
		selectInfo.operate_type = BattleDefine.ServerOperation.sell_hero
		selectInfo.grid_list = {}

		local gridInfo = {}
		gridInfo.grid_id = grid
		gridInfo.unit_id = 0
		table.insert(selectInfo.grid_list,gridInfo)

		--
		table.insert(data.update_list,selectInfo)

		self:AddInput(BattleDefine.Operation.update_hero,data)
		return true
	else
		mod.BattleFacade:SendMsg(10409,opIndex,grid)
	end
end

function BattleInputSystem:AddSwapGrid(toGrid,fromGrid)
	local flag,opIndex = self:AddOp(BattleDefine.Operation.swap_hero_grid)
	if not flag then
		SystemMessage.Show(TI18N("操作过于频繁"))
		return
	end
	
	if self.world.BattleStateSystem.localRun then
		local data = {}
		data.update_list = {}

		--
		local selectInfo = {}
		selectInfo.operate_num = opIndex
		selectInfo.role_uid = self.world.BattleDataSystem.roleUid
		selectInfo.operate_type = BattleDefine.ServerOperation.swap_hero_grid
		selectInfo.grid_list = {}

		local gridInfo = {}
		gridInfo.grid_id = toGrid
		gridInfo.unit_id = 0
		table.insert(selectInfo.grid_list,gridInfo)

		local gridInfo = {}
		gridInfo.grid_id = fromGrid
		gridInfo.unit_id = 0
		table.insert(selectInfo.grid_list,gridInfo)

		--
		table.insert(data.update_list,selectInfo)

		self:AddInput(BattleDefine.Operation.update_hero,data)
		return true
	else
		mod.BattleFacade:SendMsg(10408,opIndex,fromGrid,toGrid)
	end
end

function BattleInputSystem:AddUseMagicCard(roleUid,unitId,skillId,skillLev,transInfo,targets)
	local flag,opIndex = self:AddOp(BattleDefine.Operation.use_magic_card)
	if not flag then
		SystemMessage.Show(TI18N("操作过于频繁"))
		return
	end

	if self.world.BattleStateSystem.localRun then
		local data = {}
		data.frame_list = {}

		local useInfo = {}
		useInfo.operate_num = opIndex
		useInfo.role_uid = roleUid
		useInfo.unit_id = unitId

		local useArgs = {}
		useArgs.skillId = skillId
		useArgs.skillLev = skillLev
		useArgs.transInfo = transInfo
		useArgs.targets = targets

		useInfo.data = TableUtils.TableToString(useArgs)

		table.insert(data.frame_list,useInfo)
		
		self:AddInput(BattleDefine.Operation.use_magic_card,data)
	else
		local data = {}
		data.skillId = skillId
		data.skillLev = skillLev
		data.transInfo = transInfo
		data.targets = targets
		mod.BattleFacade:SendMsg(10413,opIndex,unitId,TableUtils.TableToString(data))
	end
end

function BattleInputSystem:AddSelectPveItem(itemGroupId,pveItemId)
    local flag,opIndex = self:AddOp(BattleDefine.Operation.select_pve_item)
    if not flag then
		SystemMessage.Show(TI18N("操作过于频繁"))
		return
	end

    if self.world.BattleStateSystem.localRun then
		local data = {}
		data.update_list = {}

		--
		local selectInfo = {}
		selectInfo.operate_num = opIndex
		selectInfo.role_uid = self.world.BattleDataSystem.roleUid
		selectInfo.camp = BattleDefine.Camp.defence
		selectInfo.entity_uid = self.world.EntitySystem:GetRoleCommander(selectInfo.role_uid).uid
		selectInfo.item_list = {}

		local itemInfo = {}
		itemInfo.item_group_id = itemGroupId
		itemInfo.item_id = pveItemId
		table.insert(selectInfo.item_list,itemInfo)

		--
		table.insert(data.update_list,selectInfo)
		self:AddInput(BattleDefine.Operation.select_pve_item,data)
	end
end

function BattleInputSystem:AddUseManualItem(roleUid,unitId,eventId,skillId,skillLev,transInfo,targets)
	local flag,opIndex = self:AddOp(BattleDefine.Operation.use_manual_item)
	if not flag then
		SystemMessage.Show(TI18N("操作过于频繁"))
		return
	end

	local data = {}
	data.frame_list = {}

	local useInfo = {}
	useInfo.operate_num = opIndex
	useInfo.role_uid = roleUid
	useInfo.camp = BattleDefine.Camp.defence
	useInfo.unit_id = unitId
	useInfo.entity_uid = self.world.EntitySystem:GetRoleCommander(useInfo.role_uid).uid
	useInfo.event_id = eventId

	local useArgs = {}
	useArgs.skillId = skillId
	useArgs.skillLev = skillLev
	useArgs.transInfo = transInfo
	useArgs.targets = targets

	useInfo.data = TableUtils.SerializerEncode(useArgs)

	table.insert(data.frame_list,useInfo)
	self:AddInput(BattleDefine.Operation.use_manual_item,data)
end