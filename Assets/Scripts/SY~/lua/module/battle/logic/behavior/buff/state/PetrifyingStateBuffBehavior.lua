PetrifyingStateBuffBehavior = BaseClass("PetrifyingStateBuffBehavior",BuffBehavior)

function PetrifyingStateBuffBehavior:__Init()
    self.addState = false
end

function PetrifyingStateBuffBehavior:__Delete()

end

function PetrifyingStateBuffBehavior:OnExecute()
    if not self.addState then
        self.addState = true
        self.entity.BuffComponent:AddState(BattleDefine.BuffState.petrifying)

        if self.entity.SkillComponent then
            self.entity.SkillComponent:Break()
        end
    end
    return true
end

function PetrifyingStateBuffBehavior:OnDestroy()
    if self.addState then
        self.addState = false
        self.entity.BuffComponent:RemoveState(BattleDefine.BuffState.petrifying)
    end
end