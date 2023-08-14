RelSkillAIAction = BaseClass("RelSkillAIAction",BTAction)

function RelSkillAIAction:__Init()

end

function RelSkillAIAction:__Delete()

end

function RelSkillAIAction:OnStart()

end

function RelSkillAIAction:OnUpdate(deltaTime)
    local castParams = {}
    castParams.priorityEntityUid = self.owner.entity.KvDataComponent:GetData(BattleDefine.EntityKvType.last_select_target)
    castParams.checkCampSort = true

    local skill,entitys,castArgs = self.owner.world.BattleCastSkillSystem:GetCastSkill(self.owner.entity,castParams)
    if skill then
        self.owner.entity.SkillComponent:RelSkill(skill.skillId,entitys)
        return BTTaskStatus.Failure
    else
        self.owner:SetCacheData("skill_cast_args",castArgs)
        return BTTaskStatus.Success
    end
end