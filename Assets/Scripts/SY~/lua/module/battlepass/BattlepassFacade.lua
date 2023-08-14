BattlepassFacade = BaseClass("BattlepassFacade",Facade)

function BattlepassFacade:__Init()
end

function BattlepassFacade:__InitFacade()
    self:BindCtrl(BattlepassCtrl)
    self:BindProxy(BattlepassProxy)
end