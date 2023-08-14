FightRewardProxy = BaseClass("FightRewardProxy",Proxy)

function FightRewardProxy:__Init()
    self.fightRewardCount = {}
end

function FightRewardProxy:__InitProxy()
    self:BindMsg(11400) -- 杯数奖励状态
    self:BindMsg(11401) -- 有额外奖励
    self:BindMsg(11402) -- 使用次数
end

function FightRewardProxy:Recv_11400(data)
    LogTable("接收11400",data)
    self.fightRewardCount[BattleDefine.BattleResult.win] = data.win_count
    self.fightRewardCount[BattleDefine.BattleResult.lose] = data.lose_count
end

function FightRewardProxy:Recv_11401(data)
    LogTable("接收11401",data)
end

function FightRewardProxy:Send_11402(type)
    local data = {}
    data.type = type
    LogTable("发送11402",data)
    return data
end

function FightRewardProxy:Recv_11402(data)
    LogTable("接收11402",data)
    self.fightRewardCount[data.type] = data.update_count

    if not TableUtils.IsEmpty(data.item_list) then
        ViewManager.Instance:OpenWindow(AwardWindow, {itemList = data.item_list})
    end
end