FriendBlackListView = BaseClass("FriendBlackListView",ExtendView)

function FriendBlackListView:__Init()
    self.viewActive = false
end

function FriendBlackListView:__CacheObject()
    self.view = self:Find("main/views/black_list_view").gameObject
    self.scrollview = self:Find("main/views/black_list_view/sv",ScrollRect)
    self.objEmptyTips = self:Find("main/views/black_list_view/empty_tips").gameObject
    self.txtEmptyTips = self:Find("main/views/black_list_view/empty_tips/txt_tips",Text)
    self.template = self:Find("main/views/black_list_view/sv/Viewport/Content/black_list_item").gameObject
    self.template:SetActive(false)
end

function FriendBlackListView:__Create()
    self.txtEmptyTips.text = TI18N("黑名单为空")
end

function FriendBlackListView:__BindListener()
end

function FriendBlackListView:__BindEvent()
    self:BindEvent(FriendFacade.Event.ActiveBlackListView)
    self:BindEvent(FriendFacade.Event.AddBlack)
    self:BindEvent(FriendFacade.Event.UpdateBlack)
    self:BindEvent(FriendFacade.Event.RemoveBlack)
end

function FriendBlackListView:__Show()
end

function FriendBlackListView:__Hide()
    self:OnExitView()
end

function FriendBlackListView:ActiveBlackListView(active)
    self.viewActive = active
    if active then
        self:OnEnterView()
    else
        self:OnExitView()
    end
end

function FriendBlackListView:OnEnterView()
    self.view:SetActive(true)
    self:RefreshAll()
end

function FriendBlackListView:OnExitView()
    self.view:SetActive(false)
    self:DeleteLoopScrollView()
end

function FriendBlackListView:RefreshAll()
    self:InitLoopScrollView()
    self:RefrehsEmptyTips()
end

function FriendBlackListView:RefrehsEmptyTips()
    local isEmpty = TableUtils.IsEmpty(mod.FriendProxy.tbBlack)
    self.objEmptyTips:SetActive(isEmpty)
end

function FriendBlackListView:InitLoopScrollView()
    self:DeleteLoopScrollView()
    self.loopSv = self:GetLoopScrollView()
    local datas = {}
    for _, data in pairs(mod.FriendProxy.tbBlack or {}) do
        table.insert(datas, {data=data})
    end
    self.loopSv:SetDatas(datas, true)
    self:SortList()
end

function FriendBlackListView:SortList()
    local datas = self.loopSv:GetAllData()
    table.sort(datas, function (a,b)
        return a.data.last_logout_time < b.data.last_logout_time
    end)
    self.loopSv:SetDatas(datas, true)
end

function FriendBlackListView:GetLoopScrollView()
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

function FriendBlackListView:DeleteLoopScrollView()
    if self.loopSv then
        self.loopSv:Delete()
        self.loopSv = nil
    end
end

function FriendBlackListView:OnItemCreate(index,data)
    return FriendBlackListItem.Create(self.template)
end

function FriendBlackListView:OnItemRender(item, index, data)
    item:SetData(data.data, index, self.MainView)
end

function FriendBlackListView:OnItemRecycle(item)
    item:OnRecycle()
end

function FriendBlackListView:AddBlack(data)
    if not self.viewActive then
        return
    end
    self.loopSv:AddData({data=data},true)
    self:SortList()
    self:RefrehsEmptyTips()
end

function FriendBlackListView:UpdateBlack(data)
    if not self.viewActive then
        return
    end
    self.loopSv:ReplaceDataByFunc(function (oldData,itemData)
        local item = itemData.obj
        if item.data.role_uid == data.role_uid then
            item:SetData(data, item.index, item.parentWindow)
            return data
        end
    end)
    self:SortList()
end

function FriendBlackListView:RemoveBlack(uid)
    if not self.viewActive then
        return
    end
    self.loopSv:RemoveDataByFunc(function (data,index)
        if data.data.role_uid == uid then
            return true
        end
    end,true)
    self:RefrehsEmptyTips()
end