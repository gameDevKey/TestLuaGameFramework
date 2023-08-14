DivisionProxy = BaseClass("DivisionProxy",Proxy)

function DivisionProxy:__Init()
    self.trophyRewardState = {}     --map[reward_id]state 奖励领取状态
    self.showList,self.rewardMap = self:InitShowList()   --显示列表
    self.isAutoOpen = false
    self.rankList = {}
    self.tbRankData = {}

    self.lastDivisionDataInRankWin = {}
    self.lastDivisionDataInMainView = {}
end

function DivisionProxy:__InitProxy()
    self:BindMsg(10600) -- 杯数奖励状态
    self:BindMsg(10601) -- 领取杯数奖励
    self:BindMsg(11300) -- 排行榜
end

function DivisionProxy:__InitComplete()
    EventManager.Instance:AddEvent(EventDefine.update_open_func, self:ToFunc("OnOpenFuncUpdate"))
    EventManager.Instance:AddEvent(EventDefine.update_role_info, self:ToFunc("OnRoleInfoChange"))
    EventManager.Instance:AddEvent(EventDefine.enter_mainui, self:ToFunc("OnMainUIFirstActive"))
    EventManager.Instance:AddEvent(EventDefine.active_mainui, self:ToFunc("OnMainUIActive"))
    EventManager.Instance:AddEvent(EventDefine.on_battle_exit, self:ToFunc("OnBattleExit"))
end

function DivisionProxy:InitShowList()
    local result = {}
    local rewardMap = {}
    local divisionCfg = Config.DivisionData.data_division_info
    local trophyRewardCfg = Config.DivisionData.data_trophy_reward
    for i = #divisionCfg, 1, -1 do
        local divisionInfo = divisionCfg[i]
        local list = trophyRewardCfg[i]
        local extra = {}
        if list then
            for j = #list, 1, -1 do
                local reward = list[j]
                if reward.trophy == divisionInfo.trophy then
                    table.insert(extra, { trophyReward = reward, belongDivision = divisionInfo.division, isDivisionReward = true})
                else
                    table.insert(result, { trophyReward = reward, belongDivision = divisionInfo.division, isDivisionReward = false } )
                end
                rewardMap[reward.id] = reward
            end
        end
        --若段位中包含奖励，则放在段位下方
        table.insert(result,{ divisionInfo = divisionInfo })
        for _, data in ipairs(extra) do
            table.insert(result, data)
        end
    end
    return result,rewardMap
end

function DivisionProxy:Recv_10600(data)
    LogTable("接收10600",data)
    for k, v in pairs(data.reward_list) do
        self.trophyRewardState[v.reward_id] = v.state
    end
end

function DivisionProxy:Send_10601(id)
    local data = {}
    data.id = id
    LogTable("发送10601",data)
    return data
end

--[[
    data = {
        reward_items = {
            {
                count = 1, 
                item_id = 1009
            }, 
            {
                count = 1, 
                item_id = 1001
            }
        }, 
        trophy_reward = {
            reward_id = 1, 
            state = 2
        }
    }
]]--
function DivisionProxy:Recv_10601(data)
    LogTable("接收10601",data)

    local info = data.trophy_reward
    if info then
        self.trophyRewardState[info.reward_id] = info.state
    end
    mod.DivisionFacade:SendEvent(RankWindow.Event.RefreshRewardState,info.reward_id)
    -- mod.RewardProxy.rewardPanel:ReceiveReward(data.reward_items)

    ViewManager.Instance:OpenWindow(AwardWindow, {itemList = data.reward_items})
end

function DivisionProxy:GetNodeData()
    local divisionCfg = Config.DivisionData.data_division_info
    local trophyRewardCfg = Config.DivisionData.data_trophy_reward
    return divisionCfg, trophyRewardCfg
end

function DivisionProxy:GetTrophyRewardState(rewardId) -- 领取状态 1.未领取；2.已领取
    local rewardInfo = self.rewardMap[rewardId]
    if not rewardInfo then
        return DivisionDefine.RewardStatus.Lock
    end
    local trophy = self:GetPlayerTrophy()
    local needTrophy = rewardInfo.trophy
    local state = self.trophyRewardState[rewardId] --服务端只会返回领取过的奖励id
    if trophy < needTrophy then -- 当前杯数小于所需杯数
        return DivisionDefine.RewardStatus.Lock
    end
    if state == 2 then
        return DivisionDefine.RewardStatus.Receive
    end
    return DivisionDefine.RewardStatus.Unclaimed
end

function DivisionProxy:IsTrophyRewardUnclaimed(rewardId)
    return self:GetTrophyRewardState(rewardId) == DivisionDefine.RewardStatus.Unclaimed
end

--获取未领取奖励的索引
function DivisionProxy:GetUnclaimedRewardItemIndex()
    local trophy = self:GetPlayerTrophy()
    for i, data in ipairs(self.showList or {}) do --TODO 二分查找
        if data.trophyReward ~= nil and data.trophyReward.trophy <= trophy then
            local id = data.belongDivision
            if self:IsTrophyRewardUnclaimed(data.trophyReward.id) then
                return i,id
            end
        end
    end
    return 0
end

function DivisionProxy:GetShowList()
    return self.showList
end

--是否需要自动打开段位界面
function DivisionProxy:IsAutoOpenRankWindow(lastDivision,currentDivision)
    if lastDivision and currentDivision and lastDivision < currentDivision then
        return true
    end
    return self:GetUnclaimedRewardItemIndex() > 0
end

---判断该段位是否包含奖励
---@param divisionId any
---@return boolean
function DivisionProxy:ContainAward(divisionId)
    for _, info in pairs(Config.DivisionData.data_division_info or {}) do
        if info.division == divisionId then
            local award = Config.DivisionData.data_trophy_reward[info.division]
            for _, aInfo in pairs(award or {}) do
                if aInfo.trophy == info.trophy then
                    return true
                end
            end
            break
        end
    end
    return false
end

---计算当前段位占据当前段位所需杯数的比例值，返回-1代表异常情况
---@param division any
---@return integer
function DivisionProxy:CalcTrophyProgress(division)
    if not division then return -1 end

    local curDivisionCfg = Config.DivisionData.data_division_info[division]
    if not curDivisionCfg then
        LogError("无法获取段位数据",division)
        return -1
    end

    local current = self:GetPlayerTrophy()
    local val = 1
    local nextDivisionCfg = Config.DivisionData.data_division_info[division + 1]
    if nextDivisionCfg and nextDivisionCfg.trophy ~= curDivisionCfg.trophy then
        val = (current - curDivisionCfg.trophy) / (nextDivisionCfg.trophy - curDivisionCfg.trophy)
    end
    return MathUtils.Clamp(val, 0, 1)
end

function DivisionProxy:GetPlayerTrophy()
    local data = mod.RoleProxy:GetRoleData()
    return data and data.trophy or 0
end

function DivisionProxy:GetPlayerDivision()
    local data = mod.RoleProxy:GetRoleData()
    return data and data.division or 0
end

function DivisionProxy:IsAutoOpenDivisionWinUnlock()
    -- return mod.OpenFuncCtrl:IsOpenFunc(1003)
    return false --2022年11月4日15:57:52 屏蔽自动弹出
end

function DivisionProxy:OnOpenFuncUpdate()
    self.isAutoOpen = self:IsAutoOpenDivisionWinUnlock()
    -- LogYqh("OnOpenFuncUpdate isAutoOpen",self.isAutoOpen)
    -- self:OnRankWindowEnterFinish()
end

function DivisionProxy:OnRoleInfoChange(data)
end

function DivisionProxy:OnRankWindowEnterFinish()
    local current = mod.RoleProxy:GetRoleData()
    self.lastDivisionDataInRankWin.lastDivision = current and current.division or 0
    self.lastDivisionDataInRankWin.lastTrophy = current and current.trophy or 0
end

function DivisionProxy:GetRankWinLastShowDivision()
    return self.lastDivisionDataInRankWin.lastDivision
end

function DivisionProxy:GetRankWinLastShowTrophy()
    return self.lastDivisionDataInRankWin.lastTrophy
end

function DivisionProxy:OnMainUIPanelEnterFinish()
    local current = mod.RoleProxy:GetRoleData()
    self.lastDivisionDataInMainView.lastDivision = current and current.division or 0
    self.lastDivisionDataInMainView.lastTrophy = current and current.trophy or 0
end

function DivisionProxy:GetMainUILastShowDivision()
    return self.lastDivisionDataInMainView.lastDivision
end

function DivisionProxy:GetMainUILastShowTrophy()
    return self.lastDivisionDataInMainView.lastTrophy
end

function DivisionProxy:OnMainUIFirstActive()
    -- LogYqh("OnMainUIFirstActive")
    self:OnRankWindowEnterFinish()
    self:CheckRewardUnclaimed()
    self:CheckDivisionReach()
    self:OnMainUIPanelEnterFinish()
end

function DivisionProxy:OnMainUIActive()
    -- LogYqh("OnMainUIActive")
    self:CheckRewardUnclaimed()
    self:CheckDivisionChange()
    self:CheckDivisionReach()
end

function DivisionProxy:OnBattleExit()
    self.isAutoOpen = self:IsAutoOpenDivisionWinUnlock()
    -- LogYqh("OnBattleExit isAutoOpen",self.isAutoOpen)
    -- self:CheckRewardUnclaimed()
    -- self:CheckDivisionChange()
    -- self:CheckDivisionReach()
end

--段位升级是一个瞬间，触发后就要把数据更到最新
function DivisionProxy:CheckDivisionChange()
    local current = mod.RoleProxy:GetRoleData()
    local lastDivision = self.lastDivisionDataInMainView.lastDivision
    if lastDivision and current.division ~= lastDivision then
        mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_division_change, lastDivision, current.division)
        self:OnMainUIPanelEnterFinish()
    end
end

function DivisionProxy:CheckDivisionReach()
    local current = mod.RoleProxy:GetRoleData()
    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_division_reach, current.division)
end

function DivisionProxy:CheckRewardUnclaimed()
    local rewardIndex,rewardId = self:GetUnclaimedRewardItemIndex()
    -- LogYqh("检测段位奖励是否可领",rewardIndex)
    if rewardIndex > 0 then
        mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_division_reward_uncliamed)
    end
end

function DivisionProxy:TryAutoOpenDivisionWindow()
    if RunWorld then
        return
    end
    if not self.isAutoOpen then
        return
    end
    self.isAutoOpen = false
    local lastDivision = self:GetRankWinLastShowDivision()
    local currentDivision = self:GetPlayerDivision()
    local isOpen = self:IsAutoOpenRankWindow(lastDivision, currentDivision)
    -- LogYqh("TryAutoOpenDivisionWindow lastDivision,currentDivision,isOpen",lastDivision,currentDivision,isOpen)
    if isOpen then
        ViewManager.Instance:OpenWindow(RankWindow)
    end
end

function DivisionProxy:Send_11300(...)
    local data = {type_list = {...}}
    LogTable("发送11300",data)
    return data
end

function DivisionProxy:Recv_11300(data)
    LogTable("接收11300",data)
    local offsetTrophy = 10 --分差
    local tempMap = {}
    for _, list in pairs(data.list) do
        tempMap[list.type] = {}
        for _, sc in pairs(list.role_info_list) do
            local item = {}
            item.rank = sc.rank
            for key, value in pairs(sc.role_info) do
                item[key] = value
            end
            table.insert(tempMap[list.type], item)
        end
        table.sort(tempMap[list.type], function (a,b)
            return a.trophy > b.trophy
        end)
    end
    for tpe, list in pairs(tempMap) do
        self.rankList[tpe] = {}
        local baseTrophy
        for _, item in ipairs(list) do
            if not baseTrophy or (baseTrophy - item.trophy > offsetTrophy) then
                baseTrophy = item.trophy
            end
            if not self.rankList[tpe][baseTrophy] then
                self.rankList[tpe][baseTrophy] = {}
            end
            table.insert(self.rankList[tpe][baseTrophy], item)
        end
    end
    mod.DivisionFacade:SendEvent(RankWindow.Event.RefreshRankStyle)

    for _, sc in ipairs(data.list) do
        table.sort(sc.role_info_list, function (a,b)
            return a.rank < b.rank
        end)
        self.tbRankData[sc.type] = sc.role_info_list
    end
    mod.RankListFacade:SendEvent(RankListFacade.Event.RefreshPlayerList)
end