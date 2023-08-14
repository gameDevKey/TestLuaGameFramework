CanRelSkillAICond = BaseClass("CanRelSkillAICond",BTConditional)

function CanRelSkillAICond:__Init()

end

function CanRelSkillAICond:__Delete()

end

function CanRelSkillAICond:OnStart()

end

function CanRelSkillAICond:OnUpdate(deltaTime)
    local flag = self.owner.world.PluginSystem.EntityStateCheck:CanRelSkill(self.owner.entity)
    return self:CheckCond(flag)
end