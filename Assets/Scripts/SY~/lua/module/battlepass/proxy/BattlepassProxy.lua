BattlepassProxy = BaseClass("BattlepassProxy",Proxy)

function BattlepassProxy:__Init()
    self.data = {}
    self.customSelectData = nil
end

function BattlepassProxy:__InitProxy()
    self:BindMsg(11100)
    self:BindMsg(11101)
    self:BindMsg(11102)
    self:BindMsg(11103)
end

function BattlepassProxy:__InitComplete()
end

function BattlepassProxy:Recv_11100(data)
    LogTable("接收11100",data)
    self.data = {}
    self:OnDataChange(self.data, data)
    -- LogYqh("接收11100后",self.data)
end

function BattlepassProxy:Recv_11101(data)
    LogTable("接收11101",data)
    self:OnDataChange(self.data, data, BattlepassWindow.Event.RefreshProgress)
    EventManager.Instance:SendEvent(EventDefine.update_battlepass_info, data)
    -- LogYqh("接收11101后",self.data)
end

function BattlepassProxy:Send_11102(list)
    local data = {list = list}
    LogTable("发送11102",data)
    return data
end

function BattlepassProxy:Recv_11102(data)
    LogTable("接收11102",data)
    self:OnDataChange(self.data, data, BattlepassWindow.Event.RefreshAwardState)
    -- LogYqh("接收11102后",self.data)

    local items = {}
    for _, info in pairs(data.list) do
        local conf = self:GetInfoConfig(self.data.season_id, info.level)
        local award = info.is_pay == 1 and conf.pay_reward[1] or conf.free_reward[1]
        local isCustom = self:IsCustomSelectAward(self.data.season_id, info.level,info.is_pay == 1)
        if isCustom then
            for _, choose in ipairs(info.choose_list) do
                local count = self:GetChooseItemCountByItemId(award[1], choose.val)
                table.insert( items, { item_id = choose.val, count = count })
            end
        else
            table.insert( items, { item_id = award[1], count = award[2] })
        end
    end
    ViewManager.Instance:OpenWindow(AwardWindow, {itemList = items})
end

function BattlepassProxy:Recv_11103(data)
    LogTable("接收11103",data)
    self:OnDataChange(self.data, data, BattlepassWindow.Event.RefreshVipState)
end

function BattlepassProxy:GetAllData()
    return self.data
end

function BattlepassProxy:GetTargetData(tb, lv,is_pay)
    for i, data in ipairs(tb) do
        if data.level == lv and data.is_pay == is_pay then
            return data
        end
    end
end

function BattlepassProxy:OnDataChange(tb, data, event)
    local updateKvs = {}
    local change = false
    for field, value in pairs(data or {}) do
        if type(value) == "table" then
            change = true
            if field == "list" then
                if not tb[field] then tb[field] = {} end

                for i, info1 in ipairs(value) do
                    local info2 = self:GetTargetData(tb.list, info1.level, info1.is_pay)
                    if info2 then
                        info2 = info1
                    else
                        table.insert(tb[field], info1)
                    end
                end
            else
                table.insert(tb[field], value)
            end
            updateKvs[field] = value
        elseif type(value) == "number" then
            local origin = tb[field] or 0
            tb[field] = value
            local offset = value - origin
            if offset ~= 0 then
                updateKvs[field] = {
                    lastVal = origin,
                    newVal = value,
                    diffVal = offset
                }
                change = true
            end
        else
            LogError(string.format("接收到战令数据变化,但无法处理 Key:%s Value:%s",field,tostring(value)))
        end
    end
    -- LogYqh("BattlepassProxy:OnDataChange change,updateKvs=",change,updateKvs)
    if change and event then
        mod.BattlepassFacade:SendEvent(event, updateKvs)
    end
    return updateKvs, change
end

function BattlepassProxy:GetSeasonId()
    return self.data.season_id
end

function BattlepassProxy:GetInfoConfig(seasonId,lv)
    local key = string.format("%d_%d",seasonId,lv)
    return Config.BattlePassData.data_battlepass_info[key]
end

--某个等级的奖励状态
--TODO 暂无赛季切换逻辑，self.data可以等于所有赛季的数据,以后self.data应该是个数组
function BattlepassProxy:GetAwardState(seasonId,lv,isVip)
    if isVip and not self:IsVip() then
        return GDefine.AwardState.Lock
    end
    local data = self:GetAllData()
    local playerLv = data.level
    if lv > playerLv  then
        return GDefine.AwardState.Lock
    end
    for _, info in ipairs(self.data.list) do
        if info.level == lv then
            if (isVip and info.is_pay == 1) or (not isVip and info.is_pay == 0) then
                return GDefine.AwardState.Receive
            end
        end
    end
    return GDefine.AwardState.Unclaimed
end

--判断玩家是否VIP战令
function BattlepassProxy:IsVip()
    return self.data.is_pay == 1
end

---获取可领奖励等级
---@return integer index 可领奖励等级(0表示没有可领奖励)
---@return boolean isVip 是否Vip奖励
function BattlepassProxy:GetUnclaimedAwardLevel()
    local seasonId = self:GetSeasonId()
    local data = self:GetAllData()
    local playerLv = data.level
    for i = 1, playerLv do
        local vipState = self:GetAwardState(seasonId,i,true)
        if vipState == GDefine.AwardState.Unclaimed then
            return i, true
        end
        local freeState = self:GetAwardState(seasonId,i,false)
        if freeState == GDefine.AwardState.Unclaimed then
            return i, false
        end
    end
    return 0, false
end

function BattlepassProxy:SetSelectAwardData(data,lv,isVip)
    self:ClearSelectAwardData()
    self:AddSelectAwardData(data,lv,isVip)
end

function BattlepassProxy:AddSelectAwardData(data,lv,isVip)
    if not self.customSelectData then
        self.customSelectData = {}
    end
    if not self.customSelectData[lv] then
        self.customSelectData[lv] = {}
    end
    local key = isVip and 1 or 0
    if not self.customSelectData[lv][key] then
        self.customSelectData[lv][key] = {}
    end
    for _, item in ipairs(self.customSelectData[lv][key]) do
        if item.val == data.val then
            return
        end
    end
    table.insert(self.customSelectData[lv][key], data)
end

function BattlepassProxy:GetSelectAwardData(lv,isVip)
    if not self.customSelectData then
        return
    end
    if not self.customSelectData[lv] then
        return
    end
    local key = isVip and 1 or 0
    return self.customSelectData[lv][key]
end

function BattlepassProxy:ClearSelectAwardData()
    self.customSelectData = nil
end

--TODO 一键领取所有奖励(包括可选)
function BattlepassProxy:ReqAllCustomAwards()

end

function BattlepassProxy:GetChooseItemCountByItemId(itemId, selectItemId)
    local poolId = Config.ItemData.data_item_info[itemId].item_attr
    local poolConf = Config.ItemData.data_choose_pool[poolId]
    if not poolConf then
        return 0
    end
    local items = Config.ItemData.data_choose_items[poolId]
    if not items then
        return 0
    end
    for _, data in ipairs(items) do
        if data.item_id == selectItemId then
            return data.item_count
        end
    end
    return 0
end

function BattlepassProxy:IsCustomSelectAward(seasonId,level,isVip)
    local conf = self:GetInfoConfig(seasonId,level)
    if not conf then
        return false
    end
    local data = isVip and conf.pay_reward[1] or conf.free_reward[1]
    if not data or TableUtils.IsEmpty(data) then
        return false
    end
    local item = Config.ItemData.data_item_info[data[1]]
    if not item then
        return false
    end
    return item.type == GDefine.ItemType.customSelectAward
end

function BattlepassProxy:GetTotalExp(lv,exp,seasonId)
    seasonId = seasonId or self:GetSeasonId()
    local seasonData = Config.BattlePassData.data_battlepass_season[seasonId]
    local total = 0
    for _, season in ipairs(seasonData or {}) do
        if lv == season.level then
            break
        end
        local data = self:GetInfoConfig(seasonId,season.level)
        total = total + data.need_exp
    end
    return total + exp
end