EmailView = BaseClass("EmailView",ExtendView)

function EmailView:__Init()
    self.itemAnimCtrl = self:GetAsset(AssetPath.emailItemAnimCtrl)
end

function EmailView:__Delete()
    self.itemAnimCtrl = nil
end

function EmailView:__CacheObject()
    -- self.view = self:Find("email_view").gameObject
    self.btnQuickRecv = self:Find("main/btn_get",Button)
    self.btnQuickDelete = self:Find("main/btn_delete",Button)
    self.scrollview = self:Find("main/list_sv",ScrollRect)
    self.objEmpty = self:Find("main/img_empty").gameObject
    self.objEmpty:SetActive(false)
    self.templateEmail = self:Find("main/list_sv/Viewport/Content/email_item").gameObject
    self.templateEmail:SetActive(false)
    self.canvasGroupMain = self:Find("main",CanvasGroup)
    self.rectMain = self:Find("main",RectTransform)
end

function EmailView:__Create()
end

function EmailView:__BindListener()
    self.btnQuickRecv:SetClick(self:ToFunc("OnQuickReceiveBtnClick"))
    self.btnQuickDelete:SetClick(self:ToFunc("OnQuickDeleteBtnClick"))
end

function EmailView:__BindEvent()
    -- self:BindEvent(EmailFacade.Event.ShowEmailView)
    -- self:BindEvent(EmailFacade.Event.HideEmailView)
    self:BindEvent(EmailFacade.Event.RefreshEmailView)
    self:BindEvent(EmailFacade.Event.RefreshEmailData)
    self:BindEvent(EmailFacade.Event.RemoveEmailData)
end

function EmailView:__Show()
    UnityUtils.SetLocalScale(self.rectMain,0,0,0)
    self.canvasGroupMain.alpha = 0
    self.currentEmailPage = 0
    -- self.view:SetActive(true)
    self:InitLoopScrollView()
    self:ReqNextPageData()
end

function EmailView:__Hide()
    self.viewActive = false
    self:DeleteLoopScrollView()
end

function EmailView:ReqNextPageData()
    local maxPage = mod.EmailProxy.maxPage or 0
    if self.currentEmailPage > maxPage then
        return
    end
    self.currentEmailPage = self.currentEmailPage + 1
    mod.EmailFacade:SendMsg(11701,self.currentEmailPage,self.currentEmailPage)
end

function EmailView:InitLoopScrollView()
    self:DeleteLoopScrollView()
    self.loopSv = self:GetLoopScrollView()
    local datas = mod.EmailProxy.tbData
    local list = {}
    for id, data in pairs(datas) do
        table.insert(list, {data=data})
    end
    self.loopSv:SetDatas(list,true)
    self:SortEmailView()
    self:TryShowEmptyImage()
end

function EmailView:RefreshEmailView(newList,updateList)
    for _, data in ipairs(newList) do
        self.loopSv:AddData({data=data})
    end

    for _, data in ipairs(updateList) do
        self:RefreshEmailData(data, false)
    end

    self:SortEmailView()
    self:TryShowEmptyImage()

    if not self.viewActive then
        self.viewActive = true
        self:PlayAnim("email_main_panel_open")
    end
end

function EmailView:RefreshEmailData(data, sortList)
    self.loopSv:ReplaceDataByFunc(function (oldData,itemData)
        local item = itemData.obj
        if item.data.id == data.id then
            item:SetData(data, item.index, item.parentWindow)
            return data
        end
    end)

    if sortList then
        self:SortEmailView()
    end
end

function EmailView:SortEmailView()
    local datas = self.loopSv:GetAllData()
    local unreads = {}
    local reads = {}
    for _, data in ipairs(datas) do
        if data.data.read == EmailDefine.ReadState.Read then
            table.insert(reads, data)
        else
            table.insert(unreads, data)
        end
    end
    table.sort(unreads, function (a,b)
        return a.data.send_time > b.data.send_time
    end)
    table.sort(reads, function (a,b)
        return a.data.send_time > b.data.send_time
    end)
    for _, data in ipairs(reads) do
        table.insert(unreads, data)
    end
    self.loopSv:SetDatas(unreads, true)
end

function EmailView:RemoveEmailData(ids)
    self.loopSv:RemoveDataByFunc(function (data,index)
        if ids[data.data.id] then
            return true
        end
    end,true)
    self:TryShowEmptyImage()
end

function EmailView:TryShowEmptyImage()
    local show = TableUtils.IsEmpty(mod.EmailProxy.tbData)
    self.objEmpty:SetActive(show)
end

function EmailView:OnQuickDeleteBtnClick()
    mod.EmailFacade:SendMsg(11703, 0)
end

function EmailView:OnQuickReceiveBtnClick()
    mod.EmailFacade:SendMsg(11704, 0)
end

function EmailView:GetLoopScrollView()
    local helper = VerticalLoopScrollView.New(self.scrollview, {
        paddingTop = 0,
        paddingBottom = 0,
        gapY = 10,
        alignType = LoopScrollViewDefine.AlignType.Top,
        onCreate = self:ToFunc("OnItemCreate"),
        onRender = self:ToFunc("OnItemRender"),
        onRecycle = self:ToFunc("OnItemRecycle"),
        onComplete = self:ToFunc("OnFillComplete"),
        onRenderNew = self:ToFunc("OnRenderNew"),
        itemWidth = 605,
        itemHeight = 154,
    })
    return helper
end

function EmailView:DeleteLoopScrollView()
    if self.loopSv then
        self.loopSv:Delete()
        self.loopSv = nil
    end
end

function EmailView:OnItemCreate(index,data)
    local item = EmailItem.Create(self.templateEmail)
    item:SetAnim(AssetPath.emailItemAnimCtrl, self.itemAnimCtrl)
    return item
end

function EmailView:OnItemRender(item, index, data)
    item:SetData(data.data, index, self.MainView)
end

function EmailView:OnItemRecycle(item)
    item:OnRecycle()
end

function EmailView:OnFillComplete()
    -- self:PlayAnim("email_main_panel_open")
end

function EmailView:OnRenderNew()
    local totalLen = #self.loopSv:GetAllData()
    self.loopSv:RangeRenderItem(function (itemData)
        local item = itemData.obj
        if item.index == totalLen then
            self:ReqNextPageData()
        end
        return true -- 只看最后一个即可
    end,true)
end
