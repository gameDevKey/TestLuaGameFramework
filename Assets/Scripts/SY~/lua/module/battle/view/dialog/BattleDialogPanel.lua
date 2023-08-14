BattleDialogPanel = BaseClass("BattleDialogPanel",ExtendView)

BattleDialogPanel.Event = EventEnum.New(
    "ActiveDialog"
)

function BattleDialogPanel:__Init()
    self.canClose = false
end

function BattleDialogPanel:__CacheObject()
    self.node = self:Find("dialog_panel",Text).gameObject
    self.msgText =  self:Find("dialog_panel/Main/contenText",Text)
    self.confirmText =  self:Find("dialog_panel/Main/confirmBtn/Text",Text)
    self.cancelText =  self:Find("dialog_panel/Main/cancelBtn/Text",Text)
end

function BattleDialogPanel:__BindListener()
    self:Find("dialog_panel/Main/confirmBtn",Button):SetClick(self:ToFunc("OnConfirmClick"))
    self:Find("dialog_panel/Main/cancelBtn",Button):SetClick(self:ToFunc("OnCancelClick"))
end

function BattleDialogPanel:__BindEvent()
    self:BindEvent(BattleDialogPanel.Event.ActiveDialog)
end

function BattleDialogPanel:__Hide()
    self:ActiveDialog(false)
end

function BattleDialogPanel:ActiveDialog(flag,args)
    self.node:SetActive(flag)
    if not flag then
        return
    end

    self.msgText.text = args.msg
    self.cancelText.text = args.cancelText
    self.confirmText.text = args.confirmText
    self.confirmCallback = args.confirmCallback
    self.cancelCallback = args.cancelCallback
    self.closeCallback = args.closeCallback
    self.canClose = args.canClose ~= nil and self.canClose or true
end

function BattleDialogPanel:CloseDialog(isClick)
    self:ActiveDialog(false)
    
    if isClick and self.closeCallback then
        self.closeCallback()
    end
    self.closeCallback = nil
end

function BattleDialogPanel:OnCancelClick()
    self:CloseDialog()
    if self.cancelCallback then
        self.cancelCallback()
        self.cancelCallback = nil
    end
end

function BattleDialogPanel:OnConfirmClick()
    self:CloseDialog()
    if self.confirmCallback then
        self.confirmCallback()
        self.confirmCallback = nil
    end
end