BattleFacade = BaseClass("BattleFacade",Facade)

BattleFacade.Event = EventEnum.New(
	"CancelOperate",
    "InitComplete",
    "FirstRunBattle",
    "ActiveLockScreen",
    "ActiveMainPanel",
    "PlayEnterPerform",
    "EnableSurrender",
    "AddSurrenderCallback"
)

function BattleFacade:__Init()

end

function BattleFacade:__InitFacade()
    self:BindCtrl(BattleCtrl)
    self:BindCtrl(BattlePreInitCtrl)
    self:BindCtrl(BattleTickCtrl)

    self:BindProxy(BattleProxy)
    self:BindProxy(BattlePveProxy)
    self:BindProxy(FightRewardProxy)
end