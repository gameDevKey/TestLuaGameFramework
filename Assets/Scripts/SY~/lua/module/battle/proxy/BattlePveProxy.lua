BattlePveProxy = BaseClass("BattlePveProxy",Proxy)

function BattlePveProxy:__Init()
    self.worlds = {}
    RunWorld = nil
    self.readyEnterData = nil
    self.pveProgress = nil
end

function BattlePveProxy:__InitProxy()
    --TODO 绑定协议
    self:BindMsg(10900) --进入pve
    self:BindMsg(10901) --pve信息
    self:BindMsg(10910) --pve结束
    self:BindMsg(10902) --pve扫荡
    self:BindMsg(10903) --pve章节奖励
    self:BindMsg(10904) --更新当前已通关的pve_id
end

function BattlePveProxy:AddWorld(world)
    self.worlds[world.uid] = world
end

function BattlePveProxy:RemoveWorld(uid)
    self.world[uid] = nil
end

function BattlePveProxy:SetRunWorld(world)
    RunWorld = world
end

function BattlePveProxy:GetEntity(uid)
    return RunWorld.EntitySystem:GetEntity(uid)
end

function BattlePveProxy:SetReadyEnterData(data)
    self.readyEnterData = data
end

----
function BattlePveProxy:Recv_10900(data)
    LogTable("接收10900",data)
    self:SetReadyEnterData(data)

    --mod.BattleFacade:SendEvent(MatchingWindow.Event.MatchingSucceed,data)
    --ViewManager.Instance:OpenWindow(BattleLoadWindow)
    mod.BattleCtrl:EnterPve(data)
end

function BattlePveProxy:Recv_10901(data)
    LogTable("接收10901",data)
    self.pveProgress =  data
end

function BattlePveProxy:Recv_10902(data)
    LogTable("接收10902",data)
    self.pveProgress.sweep_count = data.sweep_count
    mod.MainuiFacade:SendEvent(PveEnterPanel.Event.RefreshSweepCount)

    ViewManager.Instance:OpenWindow(AwardWindow, { toRestorePanel = "PveEnterPanel", itemList = data.item_list })
end

function BattlePveProxy:Send_10903(pveId)
    local data = {}
    data.pve_id = pveId
    LogTable("发送10903",data)
    return data
end

function BattlePveProxy:Recv_10903(data)
    LogTable("接收10903",data)
    self.pveProgress.chapter_reward_top_pve_id = data.pve_id
    mod.MainuiFacade:SendEvent(PveEnterPanel.Event.RefreshChapterReward)

    ViewManager.Instance:OpenWindow(AwardWindow, { toRestorePanel = "PveEnterPanel", itemList = data.item_list })
end

function BattlePveProxy:Recv_10904(data)
    LogTable("接收10904",data)
    self.pveProgress.pve_id = data.pve_id

    mod.MainuiFacade:SendEvent(PveEnterPanel.Event.RefreshSweepCount)
end

function BattlePveProxy:Send_10910(pveUid,pveBaseId,isWin, drop_items)
    local data = {}
    data.pve_uid = pveUid
    data.pve_base_id = pveBaseId
    data.is_win = isWin
    data.drop_items = drop_items
    LogTable("发送10910",data)
    return data
end

function BattlePveProxy:Recv_10910(data)
    LogTable("接收10910",data)
    if RunWorld then
        RunWorld.BattleResultSystem:ReturnResult(data)
        --mod.BattleCtrl:ExitBattle(RunWorld)
    end
end

function BattlePveProxy:GetNextChapterRewardInfo(curChapterRewardPveId)
    local nextPveId = curChapterRewardPveId + 1
    local nextPveConf = Config.PveData.data_pve[nextPveId]

    while nextPveConf and next(nextPveConf.chapter_reward) == nil do
        nextPveId = nextPveId + 1
        nextPveConf = Config.PveData.data_pve[nextPveId]
    end

    if not nextPveConf then
        return nil,nil
    end

    return nextPveId,nextPveConf.chapter_reward
end