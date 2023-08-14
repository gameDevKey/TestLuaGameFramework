FriendAddAndSearchView = BaseClass("FriendAddAndSearchView",ExtendView)

function FriendAddAndSearchView:__Init()
    self.viewActive = false
    self.searchDeltaTime = Config.FriendData.data_const_info.search_time_limit.num / 1000
    self.lastSearchTime = 0
end

function FriendAddAndSearchView:__CacheObject()
    self.view = self:Find("main/views/friend_add_view").gameObject
    self.scrollview = self:Find("main/views/friend_add_view/sv",ScrollRect)
    self.btnSearch = self:Find("main/views/friend_add_view/search_input/btn_search",Button)
    self.inputfield = self:Find("main/views/friend_add_view/search_input",InputField)
    self.btnRefresh = self:Find("main/views/friend_add_view/btn_refresh",Button)
    self.txtPlaceholder = self:Find("main/views/friend_add_view/search_input/txt_placeholder",Text)
    self.txtTitle = self:Find("main/views/friend_add_view/txt_title",Text)
    self.objEmptyTips = self:Find("main/views/friend_add_view/empty_tips").gameObject
    self.txtEmptyTips = self:Find("main/views/friend_add_view/empty_tips/txt_tips",Text)
    self.template = self:Find("main/views/friend_add_view/sv/Viewport/Content/friend_add_item").gameObject
    self.template:SetActive(false)
end

function FriendAddAndSearchView:__Create()
    self.txtPlaceholder.text = TI18N("请输入玩家名或ID")
end

function FriendAddAndSearchView:__BindListener()
    self.inputfield:SetEndEdit(self:ToFunc("OnInputSearchKey"))
    self.btnSearch:SetClick(self:ToFunc("OnInputSearchKey"))
    self.btnRefresh:SetClick(self:ToFunc("OnRefreshBtnClick"))
end

function FriendAddAndSearchView:__BindEvent()
    self:BindEvent(FriendFacade.Event.ActiveAddListView)
    self:BindEvent(FriendFacade.Event.RefreshSearchList)
    self:BindEvent(FriendFacade.Event.ClearSearchList)
end

function FriendAddAndSearchView:__Show()
end

function FriendAddAndSearchView:__Hide()
    self:OnExitView()
end

function FriendAddAndSearchView:ActiveAddListView(active)
    self.viewActive = active
    if active then
        self:OnEnterView()
    else
        self:OnExitView()
    end
end

function FriendAddAndSearchView:OnEnterView()
    self.searchIndex = 1
    self.searchOrRecommend = false
    self.lastSearchTime = 0
    self.view:SetActive(true)
    self:RefreshAll()
    self:OnRefreshBtnClick()
end

function FriendAddAndSearchView:OnExitView()
    self.view:SetActive(false)
    self:DeleteLoopScrollView()
end

function FriendAddAndSearchView:RefreshAll()
    self:InitLoopScrollView()
end

function FriendAddAndSearchView:InitLoopScrollView()
    self:DeleteLoopScrollView()
    self.loopSv = self:GetLoopScrollView()
end

function FriendAddAndSearchView:GetLoopScrollView()
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

function FriendAddAndSearchView:DeleteLoopScrollView()
    if self.loopSv then
        self.loopSv:Delete()
        self.loopSv = nil
    end
end

function FriendAddAndSearchView:OnItemCreate(index,data)
    return FriendAddAndSearchItem.Create(self.template)
end

function FriendAddAndSearchView:OnItemRender(item, index, data)
    item:SetData(data.data, index, self.MainView)
end

function FriendAddAndSearchView:OnItemRecycle(item)
    item:OnRecycle()
end

function FriendAddAndSearchView:OnRenderNew()
    if not self.searchOrRecommend then
        return
    end
    local totalLen = #self.loopSv:GetAllData()
    self.loopSv:RangeRenderItem(function (itemData)
        local item = itemData.obj
        if item.index == totalLen then
            self:ReqNextPageSearchData()
        end
        return true -- 只看最后一个即可
    end,true)
end

function FriendAddAndSearchView:OnInputSearchKey()
    local txt = self.inputfield.text
    if StringUtils.IsEmpty(txt) then
        SystemMessage.Show(TI18N("请先输入玩家名或ID"))
        return
    end
    if not self.searchOrRecommend then
        mod.FriendProxy:ResetReqData()
    end
    self.searchOrRecommend = true
    if os.difftime(os.time(),self.lastSearchTime) < self.searchDeltaTime then
        -- SystemMessage.Show("搜索过于频繁")
        return
    end
    self.lastSearchTime = os.time()
    self.searchIndex = 1
    self:ReqNextPageSearchData()
end

function FriendAddAndSearchView:OnRefreshBtnClick()
    if self.searchOrRecommend then
        mod.FriendProxy:ResetReqData()
    end
    self.searchOrRecommend = false
    mod.FriendProxy:SendMsg(11908)
end

function FriendAddAndSearchView:ReqNextPageSearchData()
    mod.FriendProxy:SendMsg(11901,self.inputfield.text,self.searchIndex)
    self.searchIndex = self.searchIndex + 1 --TODO 根据list判断是否到底
end

function FriendAddAndSearchView:RefreshSearchList(newList, updateList)
    if not self.viewActive then
        return
    end
    for _, data in ipairs(newList or {}) do
        self.loopSv:AddData({data=data})
    end
    self.loopSv:OnDataChange()

    self.loopSv:ReplaceDataByFunc(function (oldData,itemData)
        local item = itemData.obj
        local data = updateList[item.data.role_uid]
        if data then
            item:SetData(data, item.index, item.parentWindow)
            return data
        end
    end)

    self:CheckEmpty()

    if self.searchOrRecommend then
        self.txtTitle.text = TI18N("搜索结果")
    else
        self.txtTitle.text = TI18N("好友推荐")
    end
end

function FriendAddAndSearchView:ClearSearchList()
    self.loopSv:ClearAllData(true)
end

function FriendAddAndSearchView:CheckEmpty()
    local empty = #self.loopSv:GetAllData() == 0
    self.objEmptyTips:SetActive(empty)
    if empty then
        if self.searchOrRecommend then
            self.txtEmptyTips.text = TI18N("查无此人")
        else
            self.txtEmptyTips.text = TI18N("暂无推荐")
        end
    end
end