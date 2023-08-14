FriendApplyListView = BaseClass("FriendApplyListView",ExtendView)

function FriendApplyListView:__Init()
    self.viewActive = false
end

function FriendApplyListView:__CacheObject()
    self.view = self:Find("main/views/friend_apply_view").gameObject
    self.scrollview = self:Find("main/views/friend_apply_view/sv",ScrollRect)
    self.objEmptyTips = self:Find("main/views/friend_apply_view/empty_tips").gameObject
    self.txtEmptyTips = self:Find("main/views/friend_apply_view/empty_tips/txt_tips",Text)
    self.template = self:Find("main/views/friend_apply_view/sv/Viewport/Content/friend_apply_item").gameObject
    self.template:SetActive(false)
end

function FriendApplyListView:__Create()
    self.txtEmptyTips.text = TI18N("暂无好友申请")
end

function FriendApplyListView:__BindListener()
end

function FriendApplyListView:__BindEvent()
    self:BindEvent(FriendFacade.Event.ActiveApplyListView)
    self:BindEvent(FriendFacade.Event.AddApply)
    self:BindEvent(FriendFacade.Event.UpdateApply)
    self:BindEvent(FriendFacade.Event.RemoveApply)
end

function FriendApplyListView:__Show()
end

function FriendApplyListView:__Hide()
    self:OnExitView()
end

function FriendApplyListView:ActiveApplyListView(active)
    self.viewActive = active
    if active then
        self:OnEnterView()
    else
        self:OnExitView()
    end
end

function FriendApplyListView:OnEnterView()
    self.view:SetActive(true)
    self:RefreshAll()
end

function FriendApplyListView:OnExitView()
    self.view:SetActive(false)
    self:DeleteLoopScrollView()
end

function FriendApplyListView:RefreshAll()
    self:InitLoopScrollView()
    self:RefreshEmptyTips()
end

function FriendApplyListView:RefreshEmptyTips()
    local isEmpty = TableUtils.IsEmpty(mod.FriendProxy.tbApply)
    self.objEmptyTips:SetActive(isEmpty)
end

function FriendApplyListView:InitLoopScrollView()
    self:DeleteLoopScrollView()
    self.loopSv = self:GetLoopScrollView()
    local datas = {}
    for _, data in pairs(mod.FriendProxy.tbApply or {}) do
        table.insert(datas, {data=data})
    end
    self.loopSv:SetDatas(datas, true)
    self:SortList()
end

function FriendApplyListView:SortList()
    --TODO 申请时间近 > 申请时间远
    -- local datas = self.loopSv:GetAllData()
    -- table.sort(datas, function (a,b)
    --     return a.data.last_logout_time < b.data.last_logout_time
    -- end)
    -- self.loopSv:SetDatas(datas, true)
end

function FriendApplyListView:GetLoopScrollView()
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

function FriendApplyListView:DeleteLoopScrollView()
    if self.loopSv then
        self.loopSv:Delete()
        self.loopSv = nil
    end
end

function FriendApplyListView:OnItemCreate(index,data)
    return FriendApplyListItem.Create(self.template)
end

function FriendApplyListView:OnItemRender(item, index, data)
    item:SetData(data.data, index, self.MainView)
end

function FriendApplyListView:OnItemRecycle(item)
    item:OnRecycle()
end

function FriendApplyListView:AddApply(data)
    if not self.viewActive then
        return
    end
    self.loopSv:AddData({data=data},true)
    self:SortList()
    self:RefreshEmptyTips()
end

function FriendApplyListView:UpdateApply(data)
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

function FriendApplyListView:RemoveApply(uid)
    if not self.viewActive then
        return
    end
    self.loopSv:RemoveDataByFunc(function (data,index)
        if data.data.role_uid == uid then
            return true
        end
    end,true)
    self:RefreshEmptyTips()
end