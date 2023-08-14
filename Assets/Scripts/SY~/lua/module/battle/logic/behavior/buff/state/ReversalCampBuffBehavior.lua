ReversalCampBuffBehavior = BaseClass("ReversalCampBuffBehavior",BuffBehavior)

function ReversalCampBuffBehavior:__Init()
    self.hadSetTempCamp = false
end

function ReversalCampBuffBehavior:__Delete()

end

function ReversalCampBuffBehavior:OnExecute()
    if not self.hadSetTempCamp then
        self.hadSetTempCamp = true
        self.entity.BuffComponent:AddState(BattleDefine.BuffState.reverse_camp)
        local camp = self.entity.CampComponent:GetEnemyCamp()
        self.entity.CampComponent:SetTempCamp(camp)
    end
    return true
end

function ReversalCampBuffBehavior:OnDestroy()
    if self.hadSetTempCamp then
        self.hadSetTempCamp = false
        self.entity.BuffComponent:RemoveState(BattleDefine.BuffState.reverse_camp)
        self.entity.CampComponent:SetTempCamp(nil)
    end
end