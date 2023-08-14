FriendListView = BaseClass("FriendListView",ExtendView)

function FriendListView:__Init()
    self.viewActive = false
end

function FriendListView:__CacheObject()
    self.view = self:Find("main/views/friend_list_view").gameObject
    self.txtNum = self:Find("main/views/friend_list_view/bottom/online_state/txt_total",Text)
    self.btnDelete = self:Find("main/views/friend_list_view/bottom/btn_delete",Button)
    self.txtDelete = self:Find("main/views/friend_list_view/bottom/btn_delete/txt_name",Text)
    self.btnCancelDelete = self:Find("main/views/friend_list_view/bottom/btn_cancel_del",Button)
    self.txtCancelDelete = self:Find("main/views/friend_list_view/bottom/btn_cancel_del/txt_name",Text)
    self.scrollview = self:Find("main/views/friend_list_view/sv",ScrollRect)
    self.objEmptyTips = self:Find("main/views/friend_list_view/empty_tips").gameObject
    self.txtEmptyTips = self:Find("main/views/friend_list_view/empty_tips/txt_tips",Text)
    self.template = self:Find("main/views/friend_list_view/sv/Viewport/Content/friend_list_item").gameObject
    self.template:SetActive(false)
end

function FriendListView:__Create()
    self.txtDelete.text = TI18N("删除好友")
    self.txtCancelDelete.text = TI18N("取消删除")
    self.txtEmptyTips.text = TI18N("暂无好友")
end

function FriendListView:__BindListener()
    self.btnDelete:SetClick(self:ToFunc("OnDeleteButtonClick"),true)
    self.btnCancelDelete:SetClick(self:ToFunc("OnDeleteButtonClick"),false)
end

function FriendListView:__BindEvent()
    self:BindEvent(FriendFacade.Event.ActiveFriendListView)
    self:BindEvent(FriendFacade.Event.AddFriend)
    self:BindEvent(FriendFacade.Event.UpdateFriend)
    self:BindEvent(FriendFacade.Event.RemoveFriend)
end

function FriendListView:__Show()
end

function FriendListView:__Hide()
    self:OnExitView()
end

function FriendListView:ActiveFriendListView(active)
    self.viewActive = active
    if active then
        self:OnEnterView()
    else
        self:OnExitView()
    end
end

function FriendListView:OnEnterView()
    self.isDeleteMode = false
    self.view:SetActive(true)
    self:RefreshAll()
end

function FriendListView:OnExitView()
    self.view:SetActive(false)
    self.isDeleteMode = false
    self:DeleteLoopScrollView()
end

function FriendListView:RefreshAll()
    self:InitLoopScrollView()
    self.btnDelete.gameObject:SetActive(not self.isDeleteMode)
    self.btnCancelDelete.gameObject:SetActive(self.isDeleteMode)
    self:RefreshAmount()
    self:RefreshEmptyTips()
end

function FriendListView:RefreshEmptyTips()
    local isEmpty = TableUtils.IsEmpty(mod.FriendProxy.tbFriend)
    self.objEmptyTips:SetActive(isEmpty)
end

function FriendListView:RefreshAmount()
    self.txtNum.text = string.format("%d/%d", TableUtils.GetTableLength(mod.FriendProxy.tbFriend), mod.FriendProxy.maxFriendAmount)
end

function FriendListView:InitLoopScrollView()
    self:DeleteLoopScrollView()
    self.loopSv = self:GetLoopScrollView()
    local datas = {}
    for uid, data in pairs(mod.FriendProxy.tbFriend or {}) do
        data.isDeleteMode = self.isDeleteMode
        table.insert(datas, {data=data})
    end
    self.loopSv:SetDatas(datas, true)
    self:SortList()
end

--排序，在线在前，离线在后
function FriendListView:SortList()
    local datas = self.loopSv:GetAllData()
    local onlines = {}
    local offlines = {}
    for _, sc in ipairs(datas) do
        if sc.data.is_online == FriendDefine.OnlineState.Online then
            table.insert(onlines, sc)
        else
            table.insert(offlines, sc)
        end
    end
    table.sort(onlines, function (a,b)
        return a.data.role_uid < b.data.role_uid
    end)
    table.sort(offlines, function (a,b)
        return a.data.last_logout_time > b.data.last_logout_time
    end)
    for _, sc in ipairs(offlines) do
        table.insert(onlines, sc)
    end
    self.loopSv:SetDatas(onlines, true)
end

function FriendListView:GetLoopScrollView()
    local helper = VerticalLoopScrollView.New(self.scrollview, {
        paddingTop = 0,
        paddingBottom = 0,
        gapY = -4,
        alignType = LoopScrollViewDefine.AlignType.Top,
        onCreate = self:ToFunc("OnItemCreate"),
        onRender = self:ToFunc("OnItemRender"),
        onRecycle = self:ToFunc("OnItemRecycle"),
        itemWidth = 605,
        itemHeight = 154,
    })
    return helper
end

function FriendListView:DeleteLoopScrollView()
    if self.loopSv then
        self.loopSv:Delete()
        self.loopSv = nil
    end
end

function FriendListView:OnItemCreate(index,data)
    return FriendListItem.Create(self.template)
end

function FriendListView:OnItemRender(item, index, data)
    item:SetData(data.data, index, self.MainView)
end

function FriendListView:OnItemRecycle(item)
    item:OnRecycle()
end

function FriendListView:OnDeleteButtonClick(delete)
    self.isDeleteMode = delete
    self:RefreshAll()
end

function FriendListView:AddFriend(data)
    if not self.viewActive then
        return
    end
    self.loopSv:AddData({data=data},true)
    self:SortList()
    self:RefreshAmount()
    self:RefreshEmptyTips()
end

function FriendListView:UpdateFriend(data)
    if not self.viewActive then
        return
    end
    self.loopSv:ReplaceDataByFunc(function (oldData,itemData)
        local item = itemData.obj
        if item.data.role_uid == data.role_uid then
            data.isDeleteMode = self.isDeleteMode
            item:SetData(data, item.index, item.parentWindow)
            return data
        end
    end)
    self:SortList()
    self:RefreshAmount()
end

function FriendListView:RemoveFriend(uid)
    if not self.viewActive then
        return
    end
    self.loopSv:RemoveDataByFunc(function (data,index)
        if data.data.role_uid == uid then
            return true
        end
    end,true)
    self:RefreshAmount()
    self:RefreshEmptyTips()
end