--处理界面相关逻辑
GuideViewCtrl = SingletonClass("GuideViewCtrl", ViewCtrlBase)

function GuideViewCtrl:OnInitComplete()
    self:AddGolbalListenerWithSelfFunc(EGlobalEvent.Lanuch, "ActiveView", false)
    self:AddListenerWithSelfFunc(EGuideModule.Event.ActiveDialogue, "ActiveDialogue", false)
end

function GuideViewCtrl:ActiveView()
    if not GuideProxy.Instance:NeedGuide() then
        return
    end
    self:EnterView(UIDefine.ViewType.GuideView)
end

function GuideViewCtrl:ActiveDialogue(active, ...)
    local view = self:GetViewByType(UIDefine.ViewType.GuideView)
    if not view then
        return
    end
    if active then
        view.dialogue:ShowDialogue(...)
    else
        view.dialogue:HideDialogue(...)
    end
end

return GuideViewCtrl
