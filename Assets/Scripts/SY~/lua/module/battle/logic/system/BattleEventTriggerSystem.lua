BattleEventTriggerSystem = BaseClass("BattleEventTriggerSystem",SECBEventTriggerSystem)
BattleEventTriggerSystem.NAME = "EventTriggerSystem"

function BattleEventTriggerSystem:__Init()
end

function BattleEventTriggerSystem:__Delete()

end

function BattleEventTriggerSystem:OnInitTrigger()
    self:AddTrigger(MixedEventTrigger)
    self:AddTrigger(SkillEventTrigger)
    self:AddTrigger(UnitGridEventTrigger)
    self:AddTrigger(EntityEventTrigger)
end