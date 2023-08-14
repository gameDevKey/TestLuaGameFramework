FriendMainPanel = BaseClass("FriendMainPanel",BaseWindow)
FriendMainPanel.__showMainui = true
FriendMainPanel.__topInfo = true
FriendMainPanel.__bottomTab = true
FriendMainPanel.__topBebind = true
FriendMainPanel.__bottomBebind = true
FriendMainPanel.notTempHide = true

FriendMainPanel.TAB_SELECT_COLOR = Color(72/255,89/255,140/255,255/255)
FriendMainPanel.TAB_UNSELECT_COLOR = Color(169/255,189/255,225/255,255/255)

function FriendMainPanel:__Init()
    self:SetAsset("ui/prefab/friend/friend_main_panel.prefab",AssetType.Prefab)
    self.tbTabs = {}
    self.remindItems = {}
end

function FriendMainPanel:__Delete()
    self:ClearAllTab()
    for i,v in ipairs(self.remindItems) do
        v:Destroy()
    end
    self.remindItems = {}
end

function FriendMainPanel:__CacheObject()
    self.btnClose = self:Find("btn_bg_close",Button)
    self.btnBgClose = self:Find("main/btn_close",Button)
    self.tabContent = self:Find("main/tabs")
    self.tabTemplate = self:Find("main/tabs/tab").gameObject
    self.tabTemplate:SetActive(false)
    self.tabConf = {
        [FriendDefine.TabType.FriendList] = {
            name = TI18N("好友列表"),
            event = FriendFacade.Event.ActiveFriendListView,
        },
        [FriendDefine.TabType.AddAndSearch] = {
            name = TI18N("添加好友"),
            event = FriendFacade.Event.ActiveAddListView,
        },
        [FriendDefine.TabType.ApplyList] = {
            name = TI18N("好友申请"),
            event = FriendFacade.Event.ActiveApplyListView,
            reddot = RemindDefine.RemindId.friend_apply
        },
        [FriendDefine.TabType.BlackList] = {
            name = TI18N("黑名单"),
            event = FriendFacade.Event.ActiveBlackListView,
        },
    }
end

function FriendMainPanel:__ExtendView()
    self:ExtendView(FriendListView)
    self:ExtendView(FriendAddAndSearchView)
    self:ExtendView(FriendApplyListView)
    self:ExtendView(FriendBlackListView)
end

function FriendMainPanel:__Create()
    self:ClearAllTab()
    for type, conf in ipairs(self.tabConf) do
        local cmp = {}
        cmp.tab = GameObject.Instantiate(self.tabTemplate)
        cmp.tab:SetActive(true)
        cmp.tab.transform:SetParent(self.tabContent)
        cmp.tab.transform:Reset()
        cmp.btn = cmp.tab:GetComponent(Button)
        cmp.txtName = cmp.tab.transform:Find("name"):GetComponent(Text)
        cmp.objSelect = cmp.tab.transform:Find("select").gameObject
        cmp.transReddot = cmp.tab.transform:Find("reddot")
        cmp.btn:SetClick(self:ToFunc("OnTabClick"), type)
        cmp.txtName.text = conf.name
        self.tbTabs[type] = cmp

        if conf.reddot then
            local remind = NormalRemindItem.New()
            remind:SetParent(cmp.transReddot)
            remind:SetRemindId(conf.reddot)
            table.insert(self.remindItems,remind)
        end
    end

end

function FriendMainPanel:__BindListener()
    self.btnClose:SetClick(self:ToFunc("OnCloseBtnClick"))
    self.btnBgClose:SetClick(self:ToFunc("OnCloseBtnClick"))
end

function FriendMainPanel:__BindEvent()
end

function FriendMainPanel:__Show()
    self:OnTabClick(FriendDefine.TabType.FriendList)
end

function FriendMainPanel:__Hide()
    mod.FriendProxy:ResetReqData()
end

function FriendMainPanel:OnCloseBtnClick()
    ViewManager.Instance:CloseWindow(FriendMainPanel)
end

function FriendMainPanel:OnTabClick(tpe)
    for type, cmp in pairs(self.tbTabs) do
        local conf = self.tabConf[type]
        if type == tpe then
            cmp.objSelect:SetActive(true)
            cmp.txtName.color = FriendMainPanel.TAB_SELECT_COLOR
            mod.FriendFacade:SendEvent(conf.event, true)
        else
            cmp.objSelect:SetActive(false)
            cmp.txtName.color = FriendMainPanel.TAB_UNSELECT_COLOR
            mod.FriendFacade:SendEvent(conf.event, false)
        end
    end
end

function FriendMainPanel:ClearAllTab()
    for _, cmp in pairs(self.tbTabs) do
        GameObject.Destroy(cmp.tab)
    end
    self.tbTabs = {}
end