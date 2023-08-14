ObtainFacade = BaseClass("ObtainFacade",Facade)

function ObtainFacade:__Init()

end

function ObtainFacade:__InitFacade()
    self:BindProxy(ObtainProxy)
    self:BindCtrl(ObtainCtrl)
end
