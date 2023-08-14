ActSkill = BaseClass("ActSkill",SkillBase)

function ActSkill:__Init()
end

function ActSkill:__Delete()

end

function ActSkill:OnUpdate()
end

function ActSkill:OnCanRel(notCheckTrigger)
    if not self:IsEnable() or self.isRemove then
        return false
    end

    if self.baseConf.rel_type == SkillDefine.RelType.manual then
        return false
    end

    if self:MaxRelNum() then
        return false
    end

    if not notCheckTrigger and self.baseConf.rel_type == SkillDefine.RelType.trigger then
        local triggerNum = self:GetData(SkillDefine.DataKey.trigger_num) or 0
        if triggerNum <= 0 then
            return false
        end
    end

    if not self:IsEnergy() then
        return false
    end

	if not self:IsCd() then
		return false
    end

    if not self:IsTimelineFinish() then
        return false
    end
    
	return true
end

function ActSkill:OnRel()
    if self.baseConf.rel_type == SkillDefine.RelType.trigger then
        local triggerNum = self:GetData(SkillDefine.DataKey.trigger_num)
        self:SetData(SkillDefine.DataKey.trigger_num,triggerNum - 1)
    end
end
