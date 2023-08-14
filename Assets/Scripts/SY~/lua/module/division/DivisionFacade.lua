DivisionFacade = BaseClass("DivisionFacade",Facade)

function DivisionFacade:__Init()
end

function DivisionFacade:__InitFacade()
    self:BindCtrl(DivisionCtrl)
    self:BindProxy(DivisionProxy)
end