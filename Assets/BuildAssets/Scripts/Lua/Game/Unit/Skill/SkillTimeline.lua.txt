SkillTimeline = Class("SkillTimeline",TimelineBase,{IWorld})

function SkillTimeline:OnInit()
end

function SkillTimeline:OnDelete()
end

function SkillTimeline:BindSkill(skill)
    self.skill = skill
end

function SkillTimeline:Shot(action,args)
    --TODO test
    local uids = args.targetUids
    for _, uid in ipairs(uids or NIL_TABLE) do
        local entity = self.world.EntitySystem:GetEntity(uid)
        if entity and entity.SkinComponent then
            entity.SkinComponent.meshRenderer.material.color = Color(0.5,0.5,0.5,1)
        end
    end
end

return SkillTimeline