EmailPanel = BaseClass("EmailPanel",BaseWindow)
EmailPanel.__showMainui = true
EmailPanel.__topInfo = true
EmailPanel.__bottomTab = true
EmailPanel.notTempHide = true

function EmailPanel:__Init()
    self:SetAsset("ui/prefab/email/email_main_panel.prefab",AssetType.Prefab)
    self:AddAsset(AssetPath.emailItemAnimCtrl,AssetType.Object)
    -- self.remindItems = {}
end

function EmailPanel:__Delete()
    -- for _, item in ipairs(self.remindItems) do
    --     item:Destroy()
    -- end
    -- self.remindItems = {}
end

function EmailPanel:__CacheObject()
    self.btnClose = self:Find("main/btn_close",Button)
    self.btnBgClose = self:Find("btn_bg_close",Button)
    self.graphicRaycaster = self:Find(nil,GraphicRaycaster)

    -- self.tabConf = {
    --     [EmailDefine.TabType.Info] = {
    --         -- root = self:Find("email_view").gameObject,
    --         tab = self:Find("tab1",Button),
    --         select = self:Find("tab1/select").gameObject,
    --     },
    --     [EmailDefine.TabType.Email] = {
    --         root = self:Find("email_view").gameObject,
    --         tab = self:Find("tab2",Button),
    --         select = self:Find("tab2/select").gameObject,
    --         onShow = EmailFacade.Event.ShowEmailView,
    --         onHide = EmailFacade.Event.HideEmailView,
    --         reddot = self:Find("tab2/reddot").gameObject,
    --         reddotText = self:Find("tab2/reddot/num",Text),
    --         remindIds = RemindDefine.RemindId.email_unread,
    --     },
    --     [EmailDefine.TabType.Friend] = {
    --         -- root = self:Find("email_view").gameObject,
    --         tab = self:Find("tab3",Button),
    --         select = self:Find("tab3/select").gameObject,
    --     },
    -- }
end

function EmailPanel:__ExtendView()
    self:ExtendView(EmailView)
    self:ExtendView(EmailDetailView)
end

function EmailPanel:__Create()
    -- for tpe, conf in pairs(self.tabConf) do
    --     if conf.reddot and conf.remindIds then
    --         local remindItem = CustomRemindItem.New(conf.reddot)
    --         table.insert(self.remindItems,remindItem)
    --         remindItem:SetRemindId(conf.remindIds)
    --     end
    -- end
end

function EmailPanel:__BindListener()
    self.btnClose:SetClick(self:ToFunc("OnCloseBtnClick"))
    self.btnBgClose:SetClick(self:ToFunc("OnCloseBtnClick"))
    -- for tpe, conf in pairs(self.tabConf) do
    --     conf.tab:SetClick(self:ToFunc("OnTabClick"),tpe)
    -- end
end

function EmailPanel:__BindEvent()
    -- self:BindEvent(EmailFacade.Event.RefreshUnreadNum)
end

function EmailPanel:__Show()
    self.graphicRaycaster.enabled = true
    --TODO 按优先级打开页签
    -- self:OnTabClick(EmailDefine.TabType.Email)
    -- self:RefreshUnreadNum()
end

function EmailPanel:__Hide()
end

-- function EmailPanel:RefreshUnreadNum()
--     local conf = self.tabConf[EmailDefine.TabType.Email]
--     if conf.reddotText then
--         local num = mod.EmailProxy.unreadNum
--         if num > 99 then
--             num = "99+"
--         end
--         conf.reddotText.text = num
--     end
-- end

-- function EmailPanel:OnTabClick(type)
--     for tpe, conf in pairs(self.tabConf) do
--         if tpe == type then
--             conf.select:SetActive(true)
--             if conf.root then
--                 conf.root:SetActive(true)
--             end
--             if conf.onShow then
--                 mod.EmailFacade:SendEvent(conf.onShow)
--             end
--         else
--             conf.select:SetActive(false)
--             if conf.root then
--                 conf.root:SetActive(false)
--             end
--             if conf.onHide then
--                 mod.EmailFacade:SendEvent(conf.onHide)
--             end
--         end
--     end
-- end

function EmailPanel:OnCloseBtnClick()
    self.graphicRaycaster.enabled = false -- 防止重复点击关闭按钮
    self:PlayAnim("email_main_panel_close",-1,self:ToFunc("OnPlayCloseAnimFinish"))
end

function EmailPanel:OnPlayCloseAnimFinish()
    ViewManager.Instance:CloseWindow(EmailPanel)
end