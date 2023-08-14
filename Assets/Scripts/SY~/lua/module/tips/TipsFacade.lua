TipsFacade = BaseClass("TipsFacade",Facade)

function TipsFacade:__Init()

end

function TipsFacade:__InitFacade()
    self:BindProxy(TipsProxy)
end