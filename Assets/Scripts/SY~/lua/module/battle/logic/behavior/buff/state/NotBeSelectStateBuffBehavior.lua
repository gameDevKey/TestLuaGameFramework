NotBeSelectStateBuffBehavior = BaseClass("NotBeSelectStateBuffBehavior",BuffBehavior)

function NotBeSelectStateBuffBehavior:__Init()
    self.addState = false
end

function NotBeSelectStateBuffBehavior:__Delete()

end

function NotBeSelectStateBuffBehavior:OnExecute()
    if not self.addState then
        self.addState = true
        self.entity.BuffComponent:AddState(BattleDefine.BuffState.not_be_select)
    end
    return true
end

function NotBeSelectStateBuffBehavior:OnDestroy()
    if self.addState then
        self.addState = false
        self.entity.BuffComponent:RemoveState(BattleDefine.BuffState.not_be_select)
    end
end