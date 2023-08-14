EmailProxy = BaseClass("EmailProxy",Proxy)

function EmailProxy:__Init()
    self.tbData = {}
    self.maxPage = 0
    self.totalNum = 0
    self.unreadNum = 0
    self.perPageNum = Config.ConstData.data_const_info.mail_page_num.val
end

function EmailProxy:__InitProxy()
    self:BindMsg(11700) --新邮件提醒
    self:BindMsg(11701) --查询
    self:BindMsg(11702) --查看
    self:BindMsg(11703) --删除
    self:BindMsg(11704) --领取
end

function EmailProxy:__InitComplete()
end

function EmailProxy:Recv_11700(data)
    LogTable("接收11700",data)
    self.unreadNum = self.unreadNum + 1
    mod.EmailFacade:SendEvent(EmailFacade.Event.RefreshUnreadNum, self.unreadNum)
end

function EmailProxy:Send_11701(pageStart,pageEnd)
    local data = {}
    data.page_start = pageStart
    data.page_end = pageEnd
    LogTable("发送11701",data)
    return data
end

function EmailProxy:Recv_11701(data)
    LogTable("接收11701",data)
    self.totalNum = data.num
    self.unreadNum = data.not_read
    self.maxPage = math.ceil(self.totalNum / self.perPageNum)
    local newList = {}
    local updateList = {}
    local newStr = ""
    local updateStr = ""
    for _, sc in ipairs(data.list) do
        if self.tbData[sc.id] then
            table.insert(updateList, sc)
            updateStr = updateStr .. sc.id .. ","
        else
            table.insert(newList, sc)
            newStr = newStr .. sc.id .. ","
        end
        self.tbData[sc.id] = sc
    end
    Log("11701 新增邮件",newStr)
    Log("11701 更新邮件",updateStr)
    mod.EmailFacade:SendEvent(EmailFacade.Event.RefreshEmailView, newList, updateList)
    mod.EmailFacade:SendEvent(EmailFacade.Event.RefreshUnreadNum, self.unreadNum)
end

function EmailProxy:Send_11702(id)
    local data = {}
    data.id = id
    LogTable("发送11702",data)
    return data
end

function EmailProxy:Recv_11702(data)
    LogTable("接收11702",data)
    local email = self.tbData[data.id]
    if email then
        if email.read == EmailDefine.ReadState.Unread then
            self.unreadNum = self.unreadNum - 1
        end
        email.read = EmailDefine.ReadState.Read
        mod.EmailFacade:SendEvent(EmailFacade.Event.RefreshEmailData, email, true)
        mod.EmailFacade:SendEvent(EmailFacade.Event.RefreshUnreadNum, self.unreadNum)
    end
end

function EmailProxy:Send_11703(id)
    local data = {}
    data.id = id
    LogTable("发送11703",data)
    return data
end

function EmailProxy:Recv_11703(data)
    LogTable("接收11703",data)
    local ids = {}
    for _, id in ipairs(data.id_list) do
        if self.tbData[id] and self.tbData[id].read == EmailDefine.ReadState.Unread then
            self.unreadNum = self.unreadNum - 1
        end
        self.tbData[id] = nil
        ids[id] = true
    end
    mod.EmailFacade:SendEvent(EmailFacade.Event.RemoveEmailData, ids)
    mod.EmailFacade:SendEvent(EmailFacade.Event.RefreshUnreadNum, self.unreadNum)
    --邮件过期或者被删除
end

function EmailProxy:Send_11704(id)
    local data = {}
    data.id = id
    LogTable("发送11704",data)
    return data
end

function EmailProxy:Recv_11704(data)
    LogTable("接收11704",data)
    local updateList = {}
    for _, id in ipairs(data.id_list) do
        local email = self.tbData[id]
        if email then
            email.get = EmailDefine.AwardState.Receive
            mod.EmailFacade:SendEvent(EmailFacade.Event.UpdateEmailDetailView, email)
            mod.EmailFacade:SendMsg(11702, id)
            table.insert(updateList, email)
        end
    end
    mod.EmailFacade:SendEvent(EmailFacade.Event.RefreshEmailView, {}, updateList)

    if TableUtils.IsValid(data.reward_list) then
        ViewManager.Instance:OpenWindow(AwardWindow, {itemList = data.reward_list})
    end

end