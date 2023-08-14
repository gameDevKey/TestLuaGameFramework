DialogCtrl = BaseClass("DialogCtrl",Controller)

function DialogCtrl:__Init()

end

function DialogCtrl:__Delete()

end

function DialogCtrl:__InitComplete()
    EventManager.Instance:AddEvent(EventDefine.enter_login,self:ToFunc("EnterLogin"))
end

function DialogCtrl:EnterLogin()
    mod.DialogProxy.systemMessagePanel = SystemMessagePanel.New()
    mod.DialogProxy.systemMessagePanel:SetParent(UIDefine.canvasRoot)
    mod.DialogProxy.systemMessagePanel:Show()
end