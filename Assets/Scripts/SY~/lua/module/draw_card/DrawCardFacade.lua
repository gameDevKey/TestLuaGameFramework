DrawCardFacade = BaseClass("DrawCardFacade",Facade)

function DrawCardFacade:__Init()
end

function DrawCardFacade:__InitFacade()
    self:BindCtrl(DrawCardCtrl)
    self:BindProxy(DrawCardProxy)
end