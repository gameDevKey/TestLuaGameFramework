CollectionProxy = BaseClass("CollectionProxy", Proxy)

function CollectionProxy:__Init()
    self.unitDataDict = {}

    self.curEmbattleGroupIndex = 0 -- 当前出战卡组索引
    self.commanderSlot = nil
    self.curCommander = nil
    self.embattleGroupData = {}

    self.obtainedCard = {}  -- 已获得
    self.notObtainedCard = {}  -- 未获得
    self.obtainedCommander = {}
    self.notObtainedCommander = {}

    self.sortMode = CollectionDefine.SortMode.none
    self.sortedOrder = nil

    self.newUnlockUnits = {}
end

function CollectionProxy:__InitProxy()
    -- 绑定协议
    self:BindMsg(10200) -- 玩家单位背包列表(已解锁的才会发送)
    self:BindMsg(10201) -- 玩家单位更新(增量)
    self:BindMsg(10202) -- 玩家单位升级
    -- self:BindMsg(10203) -- 玩家卡组
    self:BindMsg(10204) -- 修改玩家卡组
    self:BindMsg(10205) -- 修改使用卡组
end

function CollectionProxy:__InitComplete()
    local count = Config.ConstData.data_const_info["card_group_count"].val
    for i = 1, count do
        table.insert(self.embattleGroupData,{})
    end
end

function CollectionProxy:Recv_10200(data)
    LogTable("接收10200",data)
    for i, v in ipairs(data.unit_list) do
        self.unitDataDict[v.unit_id] = v
    end

    self.curEmbattleGroupIndex = data.cur_group_id

    for i, v in ipairs(data.group_list) do
        self.embattleGroupData[v.group_id][v.slot] = v
    end

    self.commanderSlot = Config.ConstData.data_const_info["commander_slot"].val
    self.curCommander = self.embattleGroupData[self.curEmbattleGroupIndex][self.commanderSlot]
    self:SetLibrary()
    self:GetSortedOrder(CollectionDefine.SortMode.by_unit_id)
end

function CollectionProxy:Recv_10201(data)
    LogTable("接收10201", data)
    self:UnitDataUpdate(data)
end

function CollectionProxy:Send_10202(id)
    local data = {}
    data.unit_id = id
    LogTable("发送10202",data)
    return data
end

function CollectionProxy:Send_10204(id, group, slot)
    local data = {}
    data.unit_id = id
    data.group_id = group
    data.slot = slot
    LogTable("发送10204",data)
    return data
end

function CollectionProxy:Recv_10204(data)
    LogTable("接收10204",data)
    for i, v in ipairs(data.update_unit ) do
        self.embattleGroupData[v.group_id][v.slot] = v
        if v.slot == self.commanderSlot then
            self.curCommander = v
        end
    end
    self:SortCommanderList()
    mod.CollectionFacade:SendEvent(CollectionEmbattleView.Event.RefreshEmbattleView, self:GetEmbattleGroupData())
    mod.CollectionFacade:SendEvent(CollectionLibraryView.Event.RefreshLibraryView, self:GetLibraryData())
    mod.MainuiFacade:SendEvent(FastConfigCardPanel.Event.RefreshCardGroup)
    mod.MainuiFacade:SendEvent(MainuiModelView.Event.RefreshCardModels)
    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_card_config)
end

function CollectionProxy:Send_10205(args)
    local data = {}
    data.group_id = args
    LogTable("发送10205",data)
    return data
end

function CollectionProxy:Recv_10205(data)
    LogTable("接收10205",data)
    self.curEmbattleGroupIndex = data.cur_group_id
    self.curCommander = self.embattleGroupData[self.curEmbattleGroupIndex][self.commanderSlot]
    self:SortCommanderList()
    mod.CollectionFacade:SendEvent(CollectionEmbattleView.Event.RefreshEmbattleView, self:GetEmbattleGroupData())
    mod.CollectionFacade:SendEvent(CollectionLibraryView.Event.RefreshLibraryView, self:GetLibraryData())
    local commanderArgs = self:GetCommanderLibrary()
    mod.MainuiFacade:SendEvent(BattleModePanel.Event.RefreshBattleCardGroup,commanderArgs)
    mod.MainuiFacade:SendEvent(FastConfigCardPanel.Event.RefreshCardGroup)
    mod.MainuiFacade:SendEvent(MainuiModelView.Event.RefreshCardModels)
end


-- 初始化卡牌收藏数据，得到已获得卡牌的列表与未获得卡牌的列表
function CollectionProxy:SetLibrary()
    self.obtainedCard = {}
    self.notObtainedCard = {}
    self.obtainedCommander = {}
    self.notObtainedCommander = {}
    for k, v in pairs(Config.UnitData.data_unit_info) do
        local unit = nil
        if v.in_unit_bag == 1 then
            unit = self.unitDataDict[v.id]
            if v.type == GDefine.UnitType.commander then
                if unit ~= nil then
                    table.insert(self.obtainedCommander, { unit_id = v.id})
                else
                    table.insert(self.notObtainedCommander, { unit_id = v.id})
                end
            else
                if unit ~= nil then
                    table.insert(self.obtainedCard, { unit_id = v.id })
                else
                    table.insert(self.notObtainedCard, { unit_id = v.id })
                end
            end
        end
    end
    self:SortCommanderList()
end

function CollectionProxy:SortCommanderList()
    if self.curCommander == nil then
        return
    end
    local pos = 1
    for i, v in ipairs(self.obtainedCommander) do
        if v.unit_id == self.curCommander.unit_id then
            pos = i
        end
    end
    table.remove(self.obtainedCommander, pos)
    table.insert(self.obtainedCommander,1,{unit_id = self.curCommander.unit_id})
end

function CollectionProxy:GetEmbattleGroupData()
    return {index = self.curEmbattleGroupIndex, embattleGroupData = self.embattleGroupData[self.curEmbattleGroupIndex]}
end

function CollectionProxy:GetLibraryData()
    local order = self:GetSortedOrder(CollectionDefine.SortMode.by_unit_id)
    return {dict = self.unitDataDict, order = order}
end

function CollectionProxy:GetCommanderLibrary()
    return { index = self.curEmbattleGroupIndex, battleGroup = self.embattleGroupData[self.curEmbattleGroupIndex], ob = self.obtainedCommander, notOb = self.notObtainedCommander}
end

function CollectionProxy:GetDataById(id)
    if id < 0 then
        return nil
    end
    return self.unitDataDict[id]
end

function CollectionProxy:UnitDataUpdate(data)
    for k, v in pairs(data.update_list) do
        local unitData = self.unitDataDict[v.unit_id]
        self.unitDataDict[v.unit_id] = v
        if not unitData then
            table.insert(self.newUnlockUnits,v.unit_id)
            self:SetLibrary()
        else
            if unitData.level < v.level then
                if Config.UnitData.data_unit_info[v.unit_id].type == GDefine.UnitType.commander then
                    -- mod.CollectionFacade:SendEvent(BackpackCommanderView.Event.CommanderLevelUp,v) --TODO rename
                else
                    mod.CollectionFacade:SendEvent(CollectionDetailsWindow.Event.ResetDetailsData,v.unit_id) 
                    -- mod.CollectionFacade:SendEvent(BackpackCardView.Event.CardLevelUp,v) --TODO rename
                end
            end
        end
    end
    self:SortCommanderList()
    mod.CollectionFacade:SendEvent(CollectionEmbattleView.Event.RefreshEmbattleView, self:GetEmbattleGroupData())
    mod.CollectionFacade:SendEvent(CollectionLibraryView.Event.RefreshLibraryView, self:GetLibraryData())
    mod.MainuiFacade:SendEvent(FastConfigCardPanel.Event.RefreshCardGroup)
    mod.MainuiFacade:SendEvent(MainuiModelView.Event.RefreshCardModels)
end

function CollectionProxy:GetBattleGroupData()
    return self.embattleGroupData
end

function CollectionProxy:GetBattleGroupCurIndex()
    return self.curEmbattleGroupIndex
end

function CollectionProxy:GetCollectCount()
    return #self.obtainedCard, #self.notObtainedCard
end

function CollectionProxy:IsEmbattled(unitId)
    local battleGroup = self.embattleGroupData[self.curEmbattleGroupIndex]
    for i, v in ipairs(battleGroup) do
        if v.unit_id == unitId then
            return true
        end
    end

    return false
end

---获取牌库中所有满足的卡
---@param getEmbattle boolean|nil 是否获取上阵卡牌，不填代表获取所有
---@return table list 返回有序列表
function CollectionProxy:GetCardFromLibrary(getEmbattle)
    local allData = self:GetLibraryData()
    if getEmbattle==nil then
        return allData.order
    end
    local list = {}
    for i, unitId in ipairs(allData.order) do
        if getEmbattle then
            if self:IsEmbattled(unitId) then
                table.insert(list, allData.dict[unitId])
            end
        else
            if not self:IsEmbattled(unitId) then
                table.insert(list, allData.dict[unitId])
            end
        end
    end
    return list
end

function CollectionProxy:CanUnitUpgrade(unitId)
    local data = self:GetDataById(unitId)
    if not data then
        return false
    end
    local nextKey = unitId.."_"..data.level+1
    local nextLevCfg = Config.UnitData.data_unit_lev_info[nextKey]
    if not nextLevCfg then
        return false
    end
    local flag1 = data.count >= nextLevCfg.lv_up_count
    local itemId = GDefine.ItemId.Gold
    local itemNum = nextLevCfg.lv_up_coin_count
    local flag2 = mod.RoleItemProxy:HasItemNum(itemId,itemNum)

    return flag1 and flag2
end

function CollectionProxy:GetSortedOrder(sortMode)
    if sortMode and sortMode ~= self.sortMode then
        self.sortMode = sortMode
        local fn = CollectionDefine.SortModeMapping[sortMode].fn
        self.sortedOrder = self[fn](self)
    end
    -- LogTable("GetSortedOrder",self.sortedOrder)
    return self.sortedOrder
end

function CollectionProxy:SortByUnitId()
    local order = {}
    for i, v in ipairs({self.obtainedCard,self.notObtainedCard}) do
        for ii, vv in ipairs(v) do
            table.insert(order, vv.unit_id)
        end
    end

    table.sort(order,function (a, b)
        return a < b
    end)

    return order
end