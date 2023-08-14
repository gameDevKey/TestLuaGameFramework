AddSkillBehavior = BaseClass("AddSkillBehavior",MagicEventBehavior)

function AddSkillBehavior:__Init()
end

function AddSkillBehavior:__Delete()
end

function AddSkillBehavior:OnInit()
end

function AddSkillBehavior:OnDestroy()
end

function AddSkillBehavior:OnExecute()
    local from = self.event.from
    local actionArgs = self.event.conf.action_args
    local entity = self.world.EntitySystem:GetEntity(from.entityUid)
    if entity then
        local skill = entity.SkillComponent:GetSkill(actionArgs.skillId)
        local skillLev = actionArgs.skillLev
        if skill then
            skillLev = skillLev + skill.skillLev
        end
        entity.SkillComponent:RepSkill(actionArgs.skillId,skillLev,true)
        entity.SkillComponent:SortSkill()
    end

    return true
end