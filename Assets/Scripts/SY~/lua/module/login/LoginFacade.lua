LoginFacade = BaseClass("LoginFacade",Facade)

function LoginFacade:__Init()

end

function LoginFacade:__InitFacade()
    self:BindCtrl(LoginCtrl)
    self:BindCtrl(EnterProcessCtrl)
    self:BindCtrl(ReconnectCtrl)
    
    self:BindProxy(LoginProxy)
end
