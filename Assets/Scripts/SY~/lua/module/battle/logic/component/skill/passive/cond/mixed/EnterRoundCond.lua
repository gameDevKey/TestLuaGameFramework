EnterRoundCond = BaseClass("EnterRoundCond",PassiveCondBase)

function EnterRoundCond:__Init()

end

function EnterRoundCond:OnInit()
    self:AddEvent(BattleEvent.enter_round,self:ToFunc("OnEvent"))
end

function EnterRoundCond:OnEvent(param)
    if self.passive.conf.condition.rem 
        and self.passive.conf.condition.rem > 1 
        and param.round % self.passive.conf.condition.rem ~= 0 then
        return
    end

    if self.passive.conf.condition.round 
        and param.round ~= self.passive.conf.condition.round then
        return
    end

    self:TriggerCond(param)
end