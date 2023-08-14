AwardWindow = BaseClass("AwardWindow",BaseWindow)
AwardWindow.__showMainui = true
-- AwardWindow.__topInfo = true
-- AwardWindow.__bottomTab = true
AwardWindow.notTempHide = true

AwardWindow.Event = EventEnum.New(
)

function AwardWindow:__Init()
    self:SetAsset("ui/prefab/reward/award_window.prefab",AssetType.Prefab)
    self:AddAsset(AssetPath.awardItemAnimCtrl,AssetType.Object)
    self.tbItem = {}

    self.restorePanelInfo = {
        ["PveEnterPanel"] = { fn = "RestorePveEnterPanel" },
    }
end

function AwardWindow:__CacheObject()
    self.btnClose = self:Find("btn_close",Button)
    self.transContent = self:Find("main/view/content")
    self.template = self:Find("main/view/content/award_item").gameObject
    self.template:SetActive(false)
end

function AwardWindow:__BindListener()
    self.btnClose:SetClick(self:ToFunc("OnCloseButtonClick"))
end

function AwardWindow:__BindEvent()
end

function AwardWindow:__Create()
    self:SetOrder()
end

function AwardWindow:__Show()
    self:RefreshAward()
    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_open, "award")
    AudioManager.Instance:PlayUI(3)
end

function AwardWindow:__RepeatShow()
    self:RefreshAward()
end

function AwardWindow:RefreshAward()
    self:RecycleAllItem()
    local anim = self:GetAsset(AssetPath.awardItemAnimCtrl)
    for i, sc in ipairs(self.args.itemList or {}) do
        local item = AwardItem.Create(self.template)
        item.transform:SetParent(self.transContent)
        item.transform.localScale = Vector3.one
        item:SetAnim(AssetPath.awardItemAnimCtrl, anim)
        item:SetData(sc, i, self)
        table.insert(self.tbItem, item)
    end
end

function AwardWindow:RecycleAllItem()
    for _, item in ipairs(self.tbItem or {}) do
        item:OnRecycle()
        item:Destroy()
    end
    self.tbItem = {}
end

function AwardWindow:OnCloseButtonClick()
    self:RecycleAllItem()
    ViewManager.Instance:CloseWindow(AwardWindow)
    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_close, "award")
    self:RestorePanel()
end

function AwardWindow:RestorePanel()
    if not self.args.toRestorePanel then
        return
    end
    local func = self.restorePanelInfo[self.args.toRestorePanel].fn
    self[func](self)
end

function AwardWindow:RestorePveEnterPanel()
    mod.MainuiFacade:SendEvent(MainuiPanel.Event.ActivePveEnterPanel,true)
end