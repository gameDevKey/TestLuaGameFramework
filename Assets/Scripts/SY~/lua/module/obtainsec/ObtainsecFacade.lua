ObtainsecFacade = BaseClass("ObtainsecFacade",Facade)

function ObtainsecFacade:__Init()

end

function ObtainsecFacade:__InitFacade()
    self:BindProxy(ObtainSecProxy)
    self:BindCtrl(ObtainSecCtrl)
end
