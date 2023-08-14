BanRelSkillStateBuffBehavior = BaseClass("BanRelSkillStateBuffBehavior",BuffBehavior)

function BanRelSkillStateBuffBehavior:__Init()
    self.addState = false
end

function BanRelSkillStateBuffBehavior:__Delete()

end

function BanRelSkillStateBuffBehavior:OnExecute()
    if not self.addState then
        self.addState = true
        self.entity.BuffComponent:AddState(BattleDefine.BuffState.ban_rel_skill)
    end
    return true
end

function BanRelSkillStateBuffBehavior:OnDestroy()
    if self.addState then
        self.addState = false
        self.entity.BuffComponent:RemoveState(BattleDefine.BuffState.ban_rel_skill)
    end
end