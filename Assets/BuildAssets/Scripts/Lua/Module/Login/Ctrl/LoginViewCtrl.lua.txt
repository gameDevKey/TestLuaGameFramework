--处理界面相关逻辑
LoginViewCtrl = SingletonClass("LoginViewCtrl",ViewCtrlBase)

function LoginViewCtrl:OnInitComplete()
    self:BindEvents()
end

function LoginViewCtrl:BindEvents()
    self:AddGolbalListenerWithSelfFunc(EGlobalEvent.Lanuch, "ActiveLoginView",false)
end

function LoginViewCtrl:ActiveLoginView()
    self:EnterView(UIDefine.ViewType.LoginView)
end

return LoginViewCtrl