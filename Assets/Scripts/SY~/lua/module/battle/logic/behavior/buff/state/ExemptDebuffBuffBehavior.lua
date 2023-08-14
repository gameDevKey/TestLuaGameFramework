ExemptDebuffBuffBehavior = BaseClass("ExemptDebuffBuffBehavior",BuffBehavior)

function ExemptDebuffBuffBehavior:__Init()
    self.addState = false
end

function ExemptDebuffBuffBehavior:__Delete()

end

function ExemptDebuffBuffBehavior:OnExecute()
    if not self.addState then
        self.addState = true
        self.entity.BuffComponent:AddState(BattleDefine.BuffState.exempt_debuff)
    end
    return true
end

function ExemptDebuffBuffBehavior:OnDestroy()
    if self.addState then
        self.addState = false
        self.entity.BuffComponent:RemoveState(BattleDefine.BuffState.exempt_debuff)
    end
end