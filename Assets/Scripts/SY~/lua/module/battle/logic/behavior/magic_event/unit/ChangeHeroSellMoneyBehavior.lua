ChangeHeroSellMoneyBehavior = BaseClass("ChangeHeroSellMoneyBehavior",MagicEventBehavior)

function ChangeHeroSellMoneyBehavior:__Init()
    self.toMoney = nil
end

function ChangeHeroSellMoneyBehavior:OnInit()
    self.toMoney = self.event.conf.action_args.toMoney
    local eventParam = {}
    eventParam.roleUid = self.event.from.roleUid
    eventParam.unitId = self.event.conf.action_args.unitId
    self:AddEvent(BattleEvent.sell_hero,self:ToFunc("OnHeroSell"),eventParam)
end

function ChangeHeroSellMoneyBehavior:OnHeroSell()
    return self.toMoney
end