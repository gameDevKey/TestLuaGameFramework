RankListFacade = BaseClass("RankListFacade",Facade)

RankListFacade.Event = EventEnum.New(
    "ShowPlayerList",
    "RefreshPlayerList",
    "HidePlayerList"
)

function RankListFacade:__Init()
end

function RankListFacade:__InitFacade()
    self:BindProxy(RankListProxy)
    self:BindCtrl(RankListCtrl)
end