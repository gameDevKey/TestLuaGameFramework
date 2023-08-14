BuffRelSkillBehavior = BaseClass("BuffRelSkillBehavior",BuffBehavior)

function BuffRelSkillBehavior:__Init()
end

function BuffRelSkillBehavior:__Delete()
end

function BuffRelSkillBehavior:OnExecute()
    local skillId = self.actionParam.skillId
	local skillLev = self.actionParam.skillLev

	local baseConf = self.world.BattleConfSystem:SkillData_data_skill_base(skillId)
	assert(baseConf,string.format("技能配置不存在[skillId:%s][技能Id:%s]",tostring(skillId),tostring(skillLev)))

    self.entity.SkillComponent:RepSkill(skillId,skillLev)
    local skill = self.entity.SkillComponent:GetSkill(skillId)

    if not skill:OnCanRel(true) then
        return false
    end

    if baseConf.rel_type == SkillDefine.RelType.trigger then
        local triggerNum = skill:GetData(SkillDefine.DataKey.trigger_num) or 0
        skill:SetData(SkillDefine.DataKey.trigger_num,triggerNum + 1)
    elseif baseConf.rel_type == SkillDefine.RelType.pasv then
        local args = nil
        local flag,entitys = self.world.BattleCastSkillSystem:CanCastSkill(self.entity,skill,nil,nil,args)
        if flag then
            self.entity.SkillComponent:RelSkill(skillId,entitys)
        end
    end
    return true
end

function BuffRelSkillBehavior:OnDestroy()
end