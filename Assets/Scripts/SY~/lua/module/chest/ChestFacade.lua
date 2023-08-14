ChestFacade = BaseClass("ChestFacade",Facade)
ChestFacade.Event = EventEnum.New(
    "RefreshRemoteTime"
)
function ChestFacade:__Init()

end

function ChestFacade:__InitFacade()
    self:BindCtrl(ChestCtrl)
    self:BindProxy(ChestProxy)
end