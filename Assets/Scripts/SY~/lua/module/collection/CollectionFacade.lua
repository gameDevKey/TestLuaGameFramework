CollectionFacade = BaseClass("CollectionFacade",Facade)
CollectionFacade.Event = EventEnum.New(
    "CollectionoCancelOperate"
)

function CollectionFacade:__Init()
end

function CollectionFacade:__InitFacade()
    self:BindCtrl(CollectionCtrl)

    self:BindProxy(CollectionProxy)
end