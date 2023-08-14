GmCtrl = BaseClass("GmCtrl",Controller)

function GmCtrl:__Init()

end

function GmCtrl:__InitCtrl()
end

function GmCtrl:__InitComplete()
    EventManager.Instance:AddEvent(EventDefine.enter_login,self:ToFunc("EnterLogin"))
end

function GmCtrl:EnterLogin()
    mod.GmProxy.gmView = GmView.New()
    mod.GmProxy.gmView:SetParent(UIDefine.canvasRoot)
    mod.GmProxy.gmView:Show()
end