EmailFacade = BaseClass("EmailFacade",Facade)

EmailFacade.Event = EventEnum.New(
    -- "ShowEmailView",
    -- "HideEmailView",
    "RefreshEmailView",
    "RefreshEmailData",
    "RemoveEmailData",
    "ShowEmailDetailView",
    "UpdateEmailDetailView",
    "RefreshUnreadNum"
)

function EmailFacade:__Init()
end

function EmailFacade:__InitFacade()
    self:BindProxy(EmailProxy)
    self:BindCtrl(EmailCtrl)
end