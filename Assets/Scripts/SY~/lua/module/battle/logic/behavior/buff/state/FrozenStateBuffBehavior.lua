FrozenStateBuffBehavior = BaseClass("FrozenStateBuffBehavior",BuffBehavior)

function FrozenStateBuffBehavior:__Init()
    self.addState = false
end

function FrozenStateBuffBehavior:__Delete()

end

function FrozenStateBuffBehavior:OnExecute()
    if not self.addState then
        self.addState = true
        self.entity.BuffComponent:AddState(BattleDefine.BuffState.frozen)

        if self.entity.SkillComponent then
            self.entity.SkillComponent:Break()
        end
    end
    return true
end

function FrozenStateBuffBehavior:OnDestroy()
    if self.addState then
        self.addState = false
        self.entity.BuffComponent:RemoveState(BattleDefine.BuffState.frozen)
    end
end