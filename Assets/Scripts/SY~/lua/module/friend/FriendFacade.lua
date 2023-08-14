FriendFacade = BaseClass("FriendFacade",Facade)

FriendFacade.Event = EventEnum.New(
    "ActiveFriendListView",
    "ActiveAddListView",
    "ActiveApplyListView",
    "ActiveBlackListView",

    "AddFriend",
    "UpdateFriend",
    "RemoveFriend",

    "AddApply",
    "UpdateApply",
    "RemoveApply",

    "AddBlack",
    "UpdateBlack",
    "RemoveBlack",

    "RefreshSearchList",
    "ClearSearchList"
)

function FriendFacade:__Init()
end

function FriendFacade:__InitFacade()
    self:BindProxy(FriendProxy)
    self:BindCtrl(FriendCtrl)
end