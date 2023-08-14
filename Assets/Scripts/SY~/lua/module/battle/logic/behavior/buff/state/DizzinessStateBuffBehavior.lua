DizzinessStateBuffBehavior = BaseClass("DizzinessStateBuffBehavior",BuffBehavior)

function DizzinessStateBuffBehavior:__Init()
    self.addState = false
end

function DizzinessStateBuffBehavior:__Delete()

end

function DizzinessStateBuffBehavior:OnExecute()
    if not self.addState then
        self.addState = true
        self.entity.BuffComponent:AddState(BattleDefine.BuffState.dizziness)

        if self.entity.SkillComponent then
            self.entity.SkillComponent:Break()
        end
        
        if self.entity.AnimComponent then
            self.entity.AnimComponent:PlayAnim(BattleDefine.Anim.idle)
        end
    end
    return true
end

function DizzinessStateBuffBehavior:OnDestroy()
    if self.addState then
        self.addState = false
        self.entity.BuffComponent:RemoveState(BattleDefine.BuffState.dizziness)
    end
end