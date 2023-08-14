FriendProxy = BaseClass("FriendProxy",Proxy)

function FriendProxy:__Init()
    self.tbFriend = {}
    self.tbApply = {}
    self.tbBlack = {}
    self.searchData = {}
    self.recommendData = {}
    self.tbTempSendApply = {} --临时记录一下向哪些玩家发起过好友申请

    self.recommendIndex = 1
    self.maxFriendAmount = Config.FriendData.data_const_info.friend_num.num
end

function FriendProxy:__InitProxy()
    self:BindMsg(11900) --所有好友信息
    self:BindMsg(11901) --搜索好友信息
    self:BindMsg(11902) --请求-添加好友
    self:BindMsg(11903) --返回-好友列表增加
    self:BindMsg(11904) --请求、返回-删除好友
    self:BindMsg(11905) --请求、返回好友申请列表处理(批量)
    self:BindMsg(11906) --返回-好友申请列表增加
    self:BindMsg(11907) --请求、返回-添加黑名单
    self:BindMsg(11908) --请求、返回-好友推荐
    self:BindMsg(11909) --返回-更新好友信息
    self:BindMsg(11910) --请求、返回-好友申请处理(单个)
    self:BindMsg(11911) --请求、返回-删除黑名单
end

function FriendProxy:__InitComplete()
end

function FriendProxy:IsFriend(id)
    return self.tbFriend[id] ~= nil
end

function FriendProxy:IsBlackList(id)
    return self.tbBlack[id] ~= nil
end

function FriendProxy:IsLocal(id)
    return id == mod.RoleProxy:GetRoleData().role_uid
end

function FriendProxy:GetOnlineAmount()
    local count = 0
    for _, sc in pairs(self.tbFriend) do
        if sc.is_online == FriendDefine.OnlineState.Online then
            count = count + 1
        end
    end
    return count
end

function FriendProxy:Recv_11900(data)
    LogTable("接收到11900",data)
    self.tbFriend = {}
    for _, sc in ipairs(data.friend_list) do
        self:AddFriend(sc,false)
    end

    self.tbApply = {}
    for _, sc in ipairs(data.apply_list) do
        self:AddApply(sc,false)
    end

    self.tbBlack = {}
    for _, sc in ipairs(data.blacklist) do
        self:AddBlack(sc,false)
    end
end

function FriendProxy:Send_11901(search,index)
    local data = {}
    data.search_info = search
    data.page = index
    LogTable("发送11901",data)
    return data
end

function FriendProxy:Recv_11901(data)
    LogTable("接收到11901",data)
    if self.searchData.search_info ~= data.search_info then
        self:ResetSearchData()
        mod.FriendFacade:SendEvent(FriendFacade.Event.ClearSearchList)
    end
    if not self.searchData.pages then
        self.searchData.pages = {}
    end
    self.searchData.search_info = data.search_info
    local newList = {}
    local updateList = {}
    for _, sc in ipairs(data.friend_list) do
        local last = self.searchData.pages[sc.role_uid]
        self.searchData.pages[sc.role_uid] = sc
        if last then
            updateList[sc.role_uid] = sc
        else
            table.insert(newList, sc)
        end
    end
    mod.FriendFacade:SendEvent(FriendFacade.Event.RefreshSearchList, newList, updateList)
end

function FriendProxy:Send_11902(uid)
    local data = {}
    data.role_uid = uid
    LogTable("发送11902",data)
    return data
end

function FriendProxy:Recv_11902(data)
    LogTable("接收到11902",data)
    if data.err_code == 0 then
        SystemMessage.Show(TI18N("申请成功"))
        self:SaveTempApplyUid(data.role_uid)
    elseif data.err_code == 10010 then
        mod.FriendCtrl:ReqDelBlackAndAddFriendByDialog(data.role_uid)
    else
        self:ShowErrorTips(data.err_code)
    end
end

function FriendProxy:Recv_11903(data)
    LogTable("接收到11903",data)
    self:AddFriend(data.friend,true)
end

function FriendProxy:Send_11904(uid)
    local data = {}
    data.role_uid = uid
    LogTable("发送11904",data)
    return data
end

function FriendProxy:Recv_11904(data)
    LogTable("接收到11904",data)
    self:RemoveFriend(data.role_uid,true)
end

function FriendProxy:Send_11905(agree_list, refuse_list)
    local data = {}
    data.agree_list = agree_list or {}
    data.refuse_list = refuse_list or  {}
    LogTable("发送11905",data)
    return data
end

function FriendProxy:Recv_11905(data)
    LogTable("接收到11905",data)
    for _, uid in ipairs(data.dealt_list) do
        self:RemoveApply(uid,true)
    end
end

function FriendProxy:Recv_11906(data)
    LogTable("接收到11906",data)
    self:AddApply(data.apply_role,true)
end

function FriendProxy:Send_11907(uid)
    local data = {}
    data.blacklist = {uid}
    LogTable("发送11907",data)
    return data
end

function FriendProxy:Recv_11907(data)
    LogTable("接收到11907",data)
    for _, sc in ipairs(data.blacklist) do
        self:AddBlack(sc,true)
    end
end

function FriendProxy:Send_11908(page)
    local data = {}
    data.page = self.recommendIndex
    LogTable("发送11908",data)
    return data
end

function FriendProxy:Recv_11908(data)
    LogTable("接收到11908",data)
    self:ResetRecommendData()
    local newList = {}
    local updateList = {}
    for _, sc in ipairs(data.recommend_list) do
        local last = self.recommendData[sc.role_uid]
        self.recommendData[sc.role_uid] = sc
        if last then
            updateList[sc.role_uid] = sc
        else
            table.insert(newList, sc)
        end
    end
    mod.FriendFacade:SendEvent(FriendFacade.Event.ClearSearchList)
    mod.FriendFacade:SendEvent(FriendFacade.Event.RefreshSearchList, newList, updateList)
end

function FriendProxy:Recv_11909(data)
    LogTable("接收到11909",data)
    self:AddFriend(data.info,true)
end

function FriendProxy:Send_11910(uid, isAgree)
    local data = {}
    data.uid = uid
    data.type = isAgree and 1 or 2
    LogTable("发送11910",data)
    return data
end

function FriendProxy:Recv_11910(data)
    LogTable("接收到11910",data)
    if data.err_code == 10002 then
        self:RemoveApply(data.uid,true)
        SystemMessage.Show(TI18N("已同意申请"))
    elseif data.err_code == 10005 then
        self:RemoveApply(data.uid,true)
        SystemMessage.Show(TI18N("已拒绝申请"))
    else
        self:ShowErrorTips(data.err_code)
    end
end

function FriendProxy:Send_11911(uid)
    local data = {}
    data.uid = uid
    LogTable("发送11911",data)
    return data
end

function FriendProxy:Recv_11911(data)
    LogTable("接收到11911",data)
    self:RemoveBlack(data.uid,true)
end

function FriendProxy:AddFriend(data,refresh)
    local last = self.tbFriend[data.role_uid]
    self.tbFriend[data.role_uid] = data
    if refresh then
        if last then
            mod.FriendFacade:SendEvent(FriendFacade.Event.UpdateFriend, data)
        else
            mod.FriendFacade:SendEvent(FriendFacade.Event.AddFriend, data)
        end
        mod.PersonalInfoFacade:SendEvent(PersonalInfoFacade.Event.ShowOtherPersonalInfo, data.role_uid)
    end
    -- self:RemoveApply(data.role_uid,refresh)
    -- self:RemoveBlack(data.role_uid,refresh)
end

function FriendProxy:RemoveFriend(id,refresh)
    local last = self.tbFriend[id]
    self.tbFriend[id] = nil
    if last and refresh then
        mod.FriendFacade:SendEvent(FriendFacade.Event.RemoveFriend, id)
        mod.PersonalInfoFacade:SendEvent(PersonalInfoFacade.Event.ShowOtherPersonalInfo, id)
    end
end

function FriendProxy:AddApply(data,refresh)
    local last = self.tbApply[data.role_uid]
    self.tbApply[data.role_uid] = data
    if refresh then
        if last then
            mod.FriendFacade:SendEvent(FriendFacade.Event.UpdateApply, data)
        else
            mod.FriendFacade:SendEvent(FriendFacade.Event.AddApply, data)
        end
    end
end

function FriendProxy:RemoveApply(id,refresh)
    local last = self.tbApply[id]
    self.tbApply[id] = nil
    if last and refresh then
        mod.FriendFacade:SendEvent(FriendFacade.Event.RemoveApply, id)
    end
end

function FriendProxy:AddBlack(data,refresh)
    local last = self.tbBlack[data.role_uid]
    self.tbBlack[data.role_uid] = data
    if refresh then
        if last then
            mod.FriendFacade:SendEvent(FriendFacade.Event.UpdateBlack, data)
        else
            mod.FriendFacade:SendEvent(FriendFacade.Event.AddBlack, data)
        end
        mod.PersonalInfoFacade:SendEvent(PersonalInfoFacade.Event.ShowOtherPersonalInfo, data.role_uid)
    end
end

function FriendProxy:RemoveBlack(id,refresh)
    local last = self.tbBlack[id]
    self.tbBlack[id] = nil
    if last and refresh then
        mod.FriendFacade:SendEvent(FriendFacade.Event.RemoveBlack, id)
        mod.PersonalInfoFacade:SendEvent(PersonalInfoFacade.Event.ShowOtherPersonalInfo, id)
    end
end

function FriendProxy:ResetSearchData()
    self.searchData = {}
    self.tbTempSendApply = {}
end

function FriendProxy:ResetRecommendData()
    self.recommendData = {}
    self.recommendIndex = 1
    self.tbTempSendApply = {}
end

function FriendProxy:ResetReqData()
    self:ResetSearchData()
    self:ResetRecommendData()
end

function FriendProxy:SaveTempApplyUid(uid)
    self.tbTempSendApply[uid] = true
    local updateList = {}
    updateList[uid] = self.recommendData[uid] or self.searchData.pages[uid]
    mod.FriendFacade:SendEvent(FriendFacade.Event.RefreshSearchList, {}, updateList)
end

--[[
    离线时长＜24小时，显示【X小时前】
    24小时≤离线时长＜3天，显示【X天前】
    离线时长≥3天，统一显示【3天以上】
]]--
function FriendProxy.GetLogoutShowStr(logoutTimestamp)
    local diff = os.time() - logoutTimestamp
    if diff <= 0 then
        return TI18N("离线")
    end
    local day = math.floor(diff / 86400)
    if day >= 1 then
        if day >= 3 then
            return TI18N("3天以上")
        end
        return TI18N(day.."天前")
    end
    local lessT = math.floor(diff % 86400)
    local hour = math.floor(lessT / 3600)
    if hour >= 1 then
        return TI18N(hour.."小时前")
    end
    lessT = math.floor(diff % 3600)
    local min = math.floor(lessT / 60)
    if min >= 1 then
        return TI18N(min.."分钟前")
    end
    return TI18N(lessT.."秒前")
end

function FriendProxy.GetLoginStateShowStr(state,logoutTimestamp)
    return state == FriendDefine.OnlineState.Online
        and TI18N("在线")
        or FriendProxy.GetLogoutShowStr(logoutTimestamp)
end

--TODO 之后换成多语言接口
function FriendProxy:GetMultiLang(id)
    local conf = Config.TextTemplateData.data_text_info[id]
    return conf and conf.simplified_chinese_content
end

function FriendProxy:ShowErrorTips(errCode)
    local tips = self:GetMultiLang(errCode)
    if not tips then
        tips = TI18N("发生未知错误:"..errCode)
    end
    SystemMessage.Show(tips)
end