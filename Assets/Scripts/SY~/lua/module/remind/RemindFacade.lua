RemindFacade = BaseClass("RemindFacade",Facade)

function RemindFacade:__Init()

end

function RemindFacade:__InitFacade()
    self:BindCtrl(RemindCtrl)
    self:BindCtrl(CommanderRemindCtrl)
    self:BindCtrl(DivisionRemindCtrl)
    self:BindCtrl(DrawCardRemindCtrl)
    self:BindCtrl(BattlepassRemindCtrl)
    self:BindCtrl(TaskRemindCtrl)
    self:BindCtrl(PveRemindCtrl)
    self:BindCtrl(CollectionRemindCtrl)
    self:BindCtrl(EmailRemindCtrl)
    self:BindCtrl(ShopRemindCtrl)
    self:BindCtrl(FriendRemindCtrl)

    self:BindProxy(RemindProxy)
end