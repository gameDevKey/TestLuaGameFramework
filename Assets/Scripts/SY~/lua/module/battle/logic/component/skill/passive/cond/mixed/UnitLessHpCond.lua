UnitLessHpCond = BaseClass("UnitLessHpCond",PassiveCondBase)

function UnitLessHpCond:__Init()
    self.checkVal = 0
end

function UnitLessHpCond:OnInit()
    local maxHp = self.passive.entity.AttrComponent:GetValue(GDefine.Attr.max_hp)
    self.checkVal = self.world.PluginSystem.CalcAttr:CalcVal(maxHp,self.passive.conf.condition)

    local eventParam = {}
    eventParam.entityUid = self.passive.entity.uid
    self:AddEvent(BattleEvent.unit_be_hit,self:ToFunc("OnUnitBeHit"),eventParam)
end

function UnitLessHpCond:OnUnitBeHit(params)
    local hp = self.passive.entity.AttrComponent:GetValue(BattleDefine.Attr.hp)
    if hp <= self.checkVal then
        self:TriggerCond(params)
    end
end