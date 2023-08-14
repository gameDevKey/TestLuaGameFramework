SystemDialogPanel = BaseClass("SystemDialogPanel",BaseView)

SystemDialogPanel.Event = EventEnum.New(
	"ShowSystemMessage"
)

function SystemDialogPanel:__Init()
	self:SetAsset("ui/prefab/dialog/system_dialog_panel.prefab")
end

function SystemDialogPanel:__CacheObject()
    self.content = self:Find("main/content",Text)
    self.notTipsToggle = self:Find("main/not_tips/toggle",Toggle)
    self.notTipsToggleNode = self:Find("main/not_tips").gameObject
    self.txtCancel = self:Find("main/cancel_btn/name",Text)
    self.txtConfirm = self:Find("main/confirm_btn/name",Text)
end

function SystemDialogPanel:__Create()
    self:SetOrder()
end

function SystemDialogPanel:__BindListener()
    self:Find("main/confirm_btn",Button):SetClick(self:ToFunc("ConfirmClick"))
    self:Find("main/cancel_btn",Button):SetClick(self:ToFunc("CancelClick"))
end

function SystemDialogPanel:__BindEvent()

end

function SystemDialogPanel:__Show()
    self:RefreshDialog()
end

function SystemDialogPanel:__RepeatShow()
    self:RefreshDialog()
end

function SystemDialogPanel:RefreshDialog()
    self.data = self.args
    self.content.text = self.data.content

    if self.data.notShowKey then
        self.notTipsToggle.isOn = false
    end

    local tipsKeyFlag = self.data.notShowKey ~= nil and self.data.notShowKey ~= "" or false
    self.notTipsToggleNode:SetActive(tipsKeyFlag)

    self.txtConfirm.text = self.data.confirmStr or "确定"
    self.txtCancel.text = self.data.cancelStr or "取消"
end

function SystemDialogPanel:ConfirmClick()
    self:Hide()
    if self.data.notShowKey and self.notTipsToggle.isOn then
        mod.DialogProxy:SetNotShowDialogKey(self.data.notShowKey)
    end
    if self.data.onConfirm then
        self.data.onConfirm(self.data.args)
    end
end

function SystemDialogPanel:CancelClick()
    self:Hide()
    if self.data.onCancel then
        self.data.onCancel(self.data.args)
    end
end
