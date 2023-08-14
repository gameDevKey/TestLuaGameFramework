EmailDetailView = BaseClass("EmailDetailView",ExtendView)

function EmailDetailView:__Init()
    self.tbItem = {}
    self.data = nil
    self.viewActive = false
end

function EmailDetailView:__CacheObject()
    self.view = self:Find("email_detail_view").gameObject
    self.txtTitle = self:Find("email_detail_view/main/img_title/txt_title",Text)
    self.txtContent = self:Find("email_detail_view/main/content/sv_txt/Viewport/Content",Text)
    self.btnConfirm = self:Find("email_detail_view/main/btn_confirm",Button)
    self.btnAward = self:Find("email_detail_view/main/btn_get",Button)
    self.btnClose = self:Find("email_detail_view/main/img_title/btn_close",Button)
    self.btnBgClose = self:Find("email_detail_view/btn_bg_close",Button)
    self.contentAward = self:Find("email_detail_view/main/content/img_content/sv/Viewport/Content")
    self.objAwardRoot = self:Find("email_detail_view/main/content/img_content").gameObject
    self.objContentRoot = self:Find("email_detail_view/main/content/sv_txt").gameObject
end

function EmailDetailView:__Create()
end

function EmailDetailView:__BindListener()
    self.btnConfirm:SetClick(self:ToFunc("OnCloseButtonClick"))
    self.btnAward:SetClick(self:ToFunc("OnAwardButtonClick"))
    self.btnClose:SetClick(self:ToFunc("OnCloseButtonClick"))
    self.btnBgClose:SetClick(self:ToFunc("OnCloseButtonClick"))
end

function EmailDetailView:__BindEvent()
    self:BindEvent(EmailFacade.Event.ShowEmailDetailView)
    self:BindEvent(EmailFacade.Event.UpdateEmailDetailView)
end

function EmailDetailView:__Show()
    self:RemoveAllAwardItem()
end

function EmailDetailView:__Hide()
    self:RemoveAllAwardItem()
end

function EmailDetailView:ShowEmailDetailView(data)
    self.viewActive = true
    self.view:SetActive(true)
    self:PlayAnim("detail_view_open")
    self.data = data
    self.containAward = TableUtils.IsValid(self.data.reward_list)
    self.txtTitle.text = self.data.title
    self.txtContent.text = self.data.content

    if self.containAward then
        self.objAwardRoot:SetActive(true)
        self:LoadAllAwardItem()
    else
        self.objAwardRoot:SetActive(false)
    end

    if self.containAward and self.data.get == EmailDefine.AwardState.Unclaimed then
        -- 显示领取按钮
        self.btnAward.gameObject:SetActive(true)
        self.btnConfirm.gameObject:SetActive(false)
    else
        -- 显示确定按钮
        self.btnAward.gameObject:SetActive(false)
        self.btnConfirm.gameObject:SetActive(true)
    end
end

function EmailDetailView:UpdateEmailDetailView(data)
    if not self.data then
        return
    end
    if self.data and self.data.id ~= data.id then
        return
    end
    self:ShowEmailDetailView(data)
end

function EmailDetailView:LoadAllAwardItem()
    self:RemoveAllAwardItem()
    for _, sc in ipairs(self.data.reward_list) do
        local itemData = {}
        itemData.item_id = sc.item_id
        itemData.count = sc.count
        local propItem = PropItem.Create()
        propItem:SetParent(self.contentAward)
        propItem.transform:Reset()
        propItem:Show()
        propItem:SetData(itemData)
        table.insert(self.tbItem, propItem)
    end
end

function EmailDetailView:RemoveAllAwardItem()
    for _, item in ipairs(self.tbItem) do
        item:Destroy()
    end
    self.tbItem = {}
end

function EmailDetailView:OnCloseButtonClick()
    if not self.viewActive then
        return
    end
    self.viewActive = false
    self.data = nil
    self:RemoveAllAwardItem()
    self:PlayAnim("detail_view_close",-1,self:ToFunc("OnPlayCloseAnimFinish"))
end

function EmailDetailView:OnPlayCloseAnimFinish()
    self.view:SetActive(false)
end

function EmailDetailView:OnAwardButtonClick()
    mod.EmailFacade:SendMsg(11704, self.data.id)
end