MainuiAnimProxy = BaseClass("MainuiAnimProxy",Proxy)

function MainuiAnimProxy:__Init()
    self.realData = {}
    self.showData = {}
    self.itemCheckMap = {
        [GDefine.ItemId.Gold] = GDefine.ResFloatType.Gold,
        [GDefine.ItemId.Diamond] = GDefine.ResFloatType.Diamond,
        [GDefine.ItemId.EquipChest] = GDefine.ResFloatType.EquipChest,
        [GDefine.ItemId.AdvTicket] = GDefine.ResFloatType.AdvTicket,
        [GDefine.ItemId.DrawCardTicket] = GDefine.ResFloatType.DrawCardTicket,
    }
end

function MainuiAnimProxy:__InitProxy()
end

function MainuiAnimProxy:__InitComplete()
    --数据实时更新
    EventManager.Instance:AddEvent(EventDefine.enter_mainui, self:ToFunc("OnMainUIFirstActive"))
    EventManager.Instance:AddEvent(EventDefine.refresh_role_item, self:ToFunc("OnRoleItemRefresh"))
    EventManager.Instance:AddEvent(EventDefine.update_role_info, self:ToFunc("OnRoleInfoUpdate"))
    EventManager.Instance:AddEvent(EventDefine.update_battlepass_info, self:ToFunc("OnBattleInfoUpdate"))

    --显示的触发时机
    EventManager.Instance:AddEvent(EventDefine.active_mainui, self:ToFunc("TryShowAllResAnim"))
    EventManager.Instance:AddEvent(EventDefine.active_mainui_top, self:ToFunc("TryShowAllResAnim"))
    EventManager.Instance:AddEvent(EventDefine.active_mainui_bottom, self:ToFunc("TryShowAllResAnim"))
end


function MainuiAnimProxy:OnMainUIFirstActive()
    for _, tpe in pairs(GDefine.ResFloatType) do
        self.realData[tpe] = self:GetResNum(tpe)
        self.showData[tpe] = self.realData[tpe]
    end
end

function MainuiAnimProxy:OnRoleItemRefresh(changeList, source)
    for id, tpe in pairs(self.itemCheckMap) do
        if changeList[id] then
            self.realData[tpe] = self:GetResNum(tpe)
            self:TryShowSingleResAnim(tpe)
        end
    end
end

function MainuiAnimProxy:OnRoleInfoUpdate(changeInfos)
    local info = changeInfos[GDefine.RoleInfoName[GDefine.RoleInfoType.trophy]]
    if info then
        local tpe = GDefine.ResFloatType.Trophy
        self.realData[tpe] = self:GetResNum(tpe)
    end
end

function MainuiAnimProxy:OnBattleInfoUpdate(info)
    local tpe = GDefine.ResFloatType.Battlepass
    self.realData[tpe] = self:GetResNum(tpe)
end

function MainuiAnimProxy:TryShowAllResAnim()
    for _, tpe in pairs(GDefine.ResFloatType) do
        self:TryShowSingleResAnim(tpe)
    end
end

function MainuiAnimProxy:TryShowSingleResAnim(tpe)
    local num = self.realData[tpe] or 0
    local lastNum = self.showData[tpe] or 0
    if self:ShowResFloatAnim(tpe,num,lastNum) then
        self.showData[tpe] = num
    end
end

function MainuiAnimProxy:GetResNum(tpe)
    if tpe == GDefine.ResFloatType.Trophy then
        local data = mod.RoleProxy:GetRoleData()
        return data and data.trophy or 0
    end
    if tpe == GDefine.ResFloatType.Battlepass then
        local data = mod.BattlepassProxy:GetAllData()
        return mod.BattlepassProxy:GetTotalExp(data.level,data.exp)
    end
    if tpe == GDefine.ResFloatType.Gold then
        return mod.RoleItemProxy:GetItemNum(GDefine.ItemId.Gold)
    end
    if tpe == GDefine.ResFloatType.Diamond then
        return mod.RoleItemProxy:GetItemNum(GDefine.ItemId.Diamond)
    end
    if tpe == GDefine.ResFloatType.EquipChest then
        return mod.RoleItemProxy:GetItemNum(GDefine.ItemId.EquipChest)
    end
    if tpe == GDefine.ResFloatType.AdvTicket then
        return mod.RoleItemProxy:GetItemNum(GDefine.ItemId.AdvTicket)
    end
    if tpe == GDefine.ResFloatType.DrawCardTicket then
        return mod.RoleItemProxy:GetItemNum(GDefine.ItemId.DrawCardTicket)
    end
    return 0
end

function MainuiAnimProxy:ShowResFloatAnim(tpe,num,lastNum)
    local offsetNum = num - lastNum
    if offsetNum <= 0 then
        return true
    end
    local resultArgs = {}
    local showNum = MathUtils.Clamp(offsetNum,0,8)
    mod.MainuiFacade:SendEvent(MainuiAnimEffectView.Event.ShowResFloatAnim, tpe, showNum, resultArgs)
    if tpe == GDefine.ResFloatType.Battlepass then
        if mod.OpenFuncProxy:IsFuncUnlock(GDefine.FuncUnlockId.Battlepass) then
            local rewardIndex,isVip = mod.BattlepassProxy:GetUnclaimedAwardLevel()
            if rewardIndex > 0 then
                mod.MainuiFacade:SendEvent(MainuiAnimEffectView.Event.ShowBattlepassRewardAnim, showNum)
            end
        end
    elseif tpe == GDefine.ResFloatType.Trophy then
        local rewardIndex,rewardId = mod.DivisionProxy:GetUnclaimedRewardItemIndex()
        if rewardIndex > 0 then
            mod.MainuiFacade:SendEvent(MainuiAnimEffectView.Event.ShowDivisionRewardAnim, showNum)
        end
    end
    return resultArgs.success
end