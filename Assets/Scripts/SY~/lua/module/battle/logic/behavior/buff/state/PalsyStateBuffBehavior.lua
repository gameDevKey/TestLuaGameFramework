PalsyStateBuffBehavior = BaseClass("PalsyStateBuffBehavior",BuffBehavior)

function PalsyStateBuffBehavior:__Init()
    self.addState = false
end

function PalsyStateBuffBehavior:__Delete()

end

function PalsyStateBuffBehavior:OnExecute()
    if not self.addState then
        self.addState = true
        self.entity.BuffComponent:AddState(BattleDefine.BuffState.palsy)
    end
    return true
end

function PalsyStateBuffBehavior:OnDestroy()
    if self.addState then
        self.addState = false
        self.entity.BuffComponent:RemoveState(BattleDefine.BuffState.palsy)
    end
end