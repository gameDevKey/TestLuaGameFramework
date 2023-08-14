ChestProxy = BaseClass("ChestProxy",Proxy)

function ChestProxy:__Init()
    self.chestPanel = nil
    self.chestDataList = {
        [1] = {},
        [2] = {},
        [3] = {},
        [4] = {},
    }
    self.maxChestCount = Config.ConstData.data_const_info["max_count_down_chest"].val      -- 最多同时持有的宝箱数量
    self.maxUnlockCount = Config.ConstData.data_const_info["max_unlock_count_down"].val    -- 最多同时解锁的数量
    self.countdownChange = Config.ConstData.data_const_info["count_down_change_data"].val  -- [1]时间 [2]消耗的钻石
end

function ChestProxy:__Delete()
    if self.chestPanel then
        self.chestPanel:Destroy()
        self.chestPanel = nil
    end
end

function ChestProxy:__InitProxy()
    self:BindMsg(10500) -- 宝箱信息
    self:BindMsg(10501) -- 倒计时宝箱更新
    self:BindMsg(10502) -- 解锁倒计时宝箱
    self:BindMsg(10503) -- 开启倒计时宝箱
    self:BindMsg(10504) -- 钻石开启倒计时宝箱
end

function ChestProxy:__InitComplete()
end

function ChestProxy:Recv_10500(data)
    LogTable("接收10500",data)
    for k, v in pairs(data.chest_list) do
        if v.grid_id then
            table.insert(self.chestDataList,v.grid_id,v)
        end
    end
end

function ChestProxy:Recv_10501(data)
    LogTable("接收10501",data)
    self:UpdateChestDataList(data.chest_list)
end

function ChestProxy:Send_10502(gridId)
    local data ={}
    data.grid_id = gridId
    LogTable("发送10502",data)
    return data
end

function ChestProxy:Recv_10502(data)
    LogTable("接收10502",data)
end

function ChestProxy:Send_10503(gridId)
    local data ={}
    data.grid_id = gridId
    LogTable("发送10503",data)
    return data
end

function ChestProxy:Recv_10503(data)
    LogTable("接收10503",data)
    self.chestDataList[data.grid_id] = {}
    mod.ChestFacade:SendEvent(ChestPanel.Event.RefreshChestPanel,self.chestDataList)
    mod.ChestFacade:SendEvent(ChestPanel.Event.ChestOpened,data.reward_items)
end

function ChestProxy:Send_10504(gridId,clientConsume)
    local data = {}
    data.grid_id = gridId
    data.client_count = clientConsume
    LogTable("发送10504",data)
    return data
end

function ChestProxy:Recv_10504(data)
    LogTable("接收10504",data)
    LogTable("接收10503",data)
    self.chestDataList[data.grid_id] = {}
    mod.ChestFacade:SendEvent(ChestPanel.Event.RefreshChestPanel,self.chestDataList)
    mod.ChestFacade:SendEvent(ChestPanel.Event.ChestOpened,data.reward_items)
end

function ChestProxy:UpdateChestDataList(data)
    for k, v in pairs(data) do
        if self.chestDataList[v.grid_id] then
            self.chestDataList[v.grid_id] = v
        else
            table.insert(self.chestDataList,v.grid_id,v)
        end
    end
    mod.ChestFacade:SendEvent(ChestPanel.Event.RefreshChestPanel,self.chestDataList)
end

function ChestProxy:GetUnlockingCount()
    local count = 0
    for k, v in pairs(self.chestDataList) do
        if v.lock_state == GDefine.ChestStateType.unlocked and v.open_time ~= 0 then
            count = count + 1
        end
    end
    return count
end

function ChestProxy:CanUnlockNewChest()
    local flag = self:GetUnlockingCount() < self.maxUnlockCount
    return flag
end

function ChestProxy:GetChestCfgById(id)
    local itemCfg = Config.ItemData.data_item_info[id]
    local chestCfg = Config.ChestData.data_chest_info_fun(id)
    return {itemCfg = itemCfg, chestCfg = chestCfg}
end