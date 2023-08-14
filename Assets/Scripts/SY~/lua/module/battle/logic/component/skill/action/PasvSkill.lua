PasvSkill = BaseClass("PasvSkill",SkillBase)

function PasvSkill:__Init()

end

function PasvSkill:__Delete()
end

function PasvSkill:OnCanRel()
    if not self:IsEnable() then
        return false
    end

    if self:MaxRelNum() then
        return false
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