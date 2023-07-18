--处理界面相关逻辑
TemplateViewCtrl = SingletonClass("TemplateViewCtrl",ViewCtrlBase)

function TemplateViewCtrl:OnInitComplete()
    self:BindEvents()
end

function TemplateViewCtrl:BindEvents()
    self:AddListenerWithSelfFunc(ETemplateModule.ViewEvent.ActiveTemplateView, "SetActiveTemplateView", false)
end

function TemplateViewCtrl:SetActiveTemplateView(data)
    self:EnterView(UIDefine.ViewType.TemplateView,data)
end

return TemplateViewCtrl