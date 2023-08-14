AddSkillBuffBehavior = BaseClass("AddSkillBuffBehavior",BuffBehavior)

function AddSkillBuffBehavior:__Init()

end

function AddSkillBuffBehavior:__Delete()

end

function AddSkillBuffBehavior:OnExecute()
    self.entity.SkillComponent:AddSkill(self.actionParam.skillId,self.actionParam.skillLev)
    return true
end

function AddSkillBuffBehavior:OnDestroy()
    self.entity.SkillComponent:RemoveSKillById(self.actionParam.skillId)
end