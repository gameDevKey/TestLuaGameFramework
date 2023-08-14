GmFacade = BaseClass("GmFacade",Facade)

function GmFacade:__Init()

end

function GmFacade:__InitFacade()
    self:BindProxy(GmProxy)

    self:BindCtrl(GmCtrl)
    self:BindCtrl(GmFunCtrl)
    self:BindCtrl(BattleFunCtrl)
end