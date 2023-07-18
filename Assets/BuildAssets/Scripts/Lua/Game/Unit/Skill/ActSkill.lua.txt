--主动技能，CD好了直接释放
ActSkill = Class("ActSkill",SkillBase)

function ActSkill:OnInit()
end

function ActSkill:OnDelete()
end

function ActSkill:OnUpdate(deltaTime)
    if self:IsReleasing() then
        return
    end
    if not self:IsCD() then
        self:Rel()
    else
        self:UpdateCD(deltaTime)
    end
end

return ActSkill