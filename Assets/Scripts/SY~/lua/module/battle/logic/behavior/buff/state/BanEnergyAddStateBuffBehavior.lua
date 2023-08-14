BanEnergyAddStateBuffBehavior = BaseClass("BanEnergyAddStateBuffBehavior",BuffBehavior)

function BanEnergyAddStateBuffBehavior:__Init()
    self.addState = false
end

function BanEnergyAddStateBuffBehavior:__Delete()

end

function BanEnergyAddStateBuffBehavior:OnExecute()
    if not self.addState then
        self.addState = true
        self.entity.BuffComponent:AddState(BattleDefine.BuffState.ban_energy_add)
    end
    return true
end

function BanEnergyAddStateBuffBehavior:OnDestroy()
    if self.addState then
        self.addState = false
        self.entity.BuffComponent:RemoveState(BattleDefine.BuffState.ban_energy_add)
    end
end