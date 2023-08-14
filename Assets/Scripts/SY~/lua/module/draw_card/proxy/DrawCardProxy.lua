DrawCardProxy = BaseClass("DrawCardProxy",Proxy)

function DrawCardProxy:__Init()
    self.addUpTicketPerCostNum = nil
    self.selectHeroData = nil
    self.accRewardState = {}
    self.drawCardTicketCostNum = nil
end

function DrawCardProxy:__InitProxy()
    self:BindMsg(11200)
    self:BindMsg(11201)
    self:BindMsg(11202)
    self:BindMsg(11203)
end

function DrawCardProxy:__InitComplete()
end

function DrawCardProxy:Send_11201(draw_id,consume_type)
    local data =  {
        draw_id = draw_id,
        consume_type = consume_type
    }
    LogTable("发送11201",data)
    return data
end

function DrawCardProxy:Recv_11201(data)
    LogTable("接收11201",data)
    ViewManager.Instance:OpenWindow(DrawCardShowWindow, data)
end

function DrawCardProxy:Recv_11200(data)
    LogTable("接收11200",data)
    for _, reward in ipairs(data.acc_reward_list) do
        self:OnRecvAccRewardData(reward)
    end
end

function DrawCardProxy:Recv_11203(data)
    LogTable("接收11203",data)
    for _, reward in ipairs(data.acc_reward_list) do
        self:OnRecvAccRewardData(reward)
    end
    mod.DrawCardFacade:SendEvent(DrawCardWindow.Event.RefreshProgressStyle)
end

function DrawCardProxy:Send_11202()
    if not self.selectHeroData then
        return
    end
    LogTable("发送11202",self.selectHeroData)
    return self.selectHeroData
end

function DrawCardProxy:Recv_11202(data)
    LogTable("接收11202",data)
    self:ClearSelectHeroData()
    ViewManager.Instance:OpenWindow(AwardWindow, {itemList = data.item_list})
end

function DrawCardProxy:SetSelectHeroData(rewardId, grade, itemId)
    self.selectHeroData = {
        acc_reward_id = rewardId,
        grade = grade,
        choose_item_id = itemId
    }
end

function DrawCardProxy:ClearSelectHeroData()
    self.selectHeroData = nil
end

function DrawCardProxy:OnRecvAccRewardData(reward)
    local id = reward.acc_reward_id
    if not self.accRewardState[id] then
        self.accRewardState[id] = {}
    end
    self.accRewardState[id].value = reward.acc_reward_value
    self.accRewardState[id].state = MathUtils.DecToBin(reward.grade_state_mask,32,false)
end

function DrawCardProxy:IsAccRewardRecv(rewardId, grade)
    local data = self.accRewardState[rewardId]
    return data and data.state[#data.state - grade + 1] == 1 or false
end

-- 获得累抽每次消耗数量
function DrawCardProxy:GetAddupTicketPerCostNum()
    if not self.addUpTicketPerCostNum then
        local conf = Config.DrawCardData.data_card_pool[GDefine.DrawCardType.Progress]
        local consume = conf.consume_1[1]
        self.addUpTicketPerCostNum = consume[2]
    end
    return self.addUpTicketPerCostNum
end

--是否包含传奇卡
function DrawCardProxy:ContainQuailtyCard(list,quality)
    for _, data in ipairs(list) do
        local itemConf = Config.ItemData.data_item_info[data.item_id]
        if itemConf.quality == quality then
            return true
        end
    end
    return false
end

--获得累抽奖励id
function DrawCardProxy:GetAccDrawId(drawId)
    local conf = Config.DrawCardData.data_card_pool[drawId]
    return conf and conf.acc_draw_reward and conf.acc_draw_reward[1][1]
end

function DrawCardProxy:GetDrawCardTicketCost()
    if not self.drawCardTicketCostNum then
        local pools = {GDefine.DrawCardType.Multi,GDefine.DrawCardType.Single}
        for _, poolId in ipairs(pools) do
            local conf = Config.DrawCardData.data_card_pool[poolId]
            local consumes = {conf.consume_1,conf.consume_2}
            for i, _list in ipairs(consumes) do
                for _, data in ipairs(_list) do
                    local id = data[1]
                    local num = data[2]
                    if id == GDefine.ItemId.DrawCardTicket then
                        self.drawCardTicketCostNum = num
                        return self.drawCardTicketCostNum
                    end
                end
            end
        end
        self.drawCardTicketCostNum = -1
    end
    return self.drawCardTicketCostNum
end