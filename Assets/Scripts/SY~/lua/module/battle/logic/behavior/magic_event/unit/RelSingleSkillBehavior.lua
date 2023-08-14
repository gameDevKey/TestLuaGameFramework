RelSingleSkillBehavior = BaseClass("RelSingleSkillBehavior",MagicEventBehavior)

function RelSingleSkillBehavior:__Init()
end

function RelSingleSkillBehavior:__Delete()
end

function RelSingleSkillBehavior:OnInit()
end

function RelSingleSkillBehavior:OnDestroy()
end

function RelSingleSkillBehavior:OnExecute()
    local from = self.event.from
    local actionArgs = self.event.conf.action_args
    local entity = self.world.EntitySystem:GetEntity(from.entityUid)
    if entity then
        local skillId = actionArgs.skillId
        local skillLev = actionArgs.skillLev

        local targets = nil
        local transInfo = nil

        local flag = false
        if from.useInfo then
            targets = from.useInfo.targets
            transInfo = from.useInfo.transInfo
            flag = true
        else
            local baseConf = self.world.BattleConfSystem:SkillData_data_skill_base(skillId)
            local levConf = self.world.BattleConfSystem:SkillData_data_skill_lev(skillId,skillLev)
            local params = {}
            params.entity = entity
            params.range = levConf.atk_range
            local entitys,_ = self.world.BattleCastSkillSystem:SkillConfSearchEntity(baseConf,levConf,params)
            flag = baseConf.no_target_rel == 1 or #entitys > 0
            targets = entitys
        end
        if flag then
            entity.SkillComponent:RelSingleSkill(skillId,skillLev,targets,transInfo)
        else
            return false
        end
    else
        return false
    end
    return true
end