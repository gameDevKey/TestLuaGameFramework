CommanderFacade = BaseClass("CommanderFacade",Facade)

CommanderFacade.Event = EventEnum.New(
    "RefreshCommanderAttr"
)


function CommanderFacade:__Init()

end

function CommanderFacade:__InitFacade()
    self:BindCtrl(CommanderCtrl)

    self:BindProxy(CommanderProxy)
    self:BindProxy(TreasureChestProxy)
end