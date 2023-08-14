PersonalInfoFacade = BaseClass("PersonalInfoFacade",Facade)

PersonalInfoFacade.Event = EventEnum.New(
    "ShowOtherPersonalInfo"
)

function PersonalInfoFacade:__Init()
end

function PersonalInfoFacade:__InitFacade()
    self:BindProxy(PersonalInfoProxy)
    self:BindCtrl(PersonalInfoCtrl)
end