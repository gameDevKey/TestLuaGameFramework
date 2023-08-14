HomeLessHpCond = BaseClass("HomeLessHpCond",PassiveCondBase)

function HomeLessHpCond:__Init()
    self.checkVal = 0
end

function HomeLessHpCond:OnInit()
    local homeUid = self.world.BattleDataSystem:GetHomeUid(self.passive.entity.CampComponent:GetCamp())
    local homeEntity = self.world.EntitySystem:GetEntity(homeUid)

    local maxHp = homeEntity.AttrComponent:GetValue(GDefine.Attr.max_hp)
    self.checkVal = self.world.PluginSystem.CalcAttr:CalcVal(maxHp,self.passive.conf.condition)

    local homeCamp = nil
    if self.passive.conf.condition.campFrom == 1 then
        homeCamp = self.passive.entity.CampComponent.camp
    elseif self.passive.conf.condition.campFrom == -1 then
        homeCamp = self.passive.entity.CampComponent:GetEnemyCamp()
    end

    local eventParam = {}
    eventParam.camp = homeCamp
    self:AddEvent(BattleEvent.be_home_hit,self:ToFunc("BeHomeHit"),eventParam)
end

function HomeLessHpCond:BeHomeHit(homeUid)
    local homeEntity = self.world.EntitySystem:GetEntity(homeUid)
    local hp = homeEntity.AttrComponent:GetValue(BattleDefine.Attr.hp)

    if hp <= self.checkVal then
        self:TriggerCond(homeUid)
    end
end