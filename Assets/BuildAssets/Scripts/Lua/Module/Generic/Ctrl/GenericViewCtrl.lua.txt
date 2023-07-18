--处理界面相关逻辑
GenericViewCtrl = SingletonClass("GenericViewCtrl", ViewCtrlBase)

function GenericViewCtrl:OnInitComplete()
    self:BindEvents()
end

function GenericViewCtrl:BindEvents()
    self:AddGolbalListenerWithSelfFunc(EGlobalEvent.Lanuch, "ActiveGenericView", false)
    self:AddGolbalListenerWithSelfFunc(EGlobalEvent.ViewEnter, "OnViewEnter", false)
    self:AddGolbalListenerWithSelfFunc(EGlobalEvent.ViewExit, "OnViewExit", false)
end

function GenericViewCtrl:ActiveGenericView()
    self:EnterView(UIDefine.ViewType.GenericView)
end

function GenericViewCtrl:OnViewEnter(type, view)
    self:showCurrentViewName()
end

function GenericViewCtrl:OnViewExit(type, view)
    self:showCurrentViewName()
end

function GenericViewCtrl:showCurrentViewName()
    local view = self:GetViewByType(UIDefine.ViewType.GenericView)
    if view then
        local topview = UIManager.Instance:GetTopView()
        local name = topview and "当前是" .. topview._className .. "界面" or "无界面?"
        view:ChangeText(name)
    end
end

return GenericViewCtrl
