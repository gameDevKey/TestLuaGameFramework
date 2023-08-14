RelSkillBehavior = BaseClass("RelSkillBehavior",MagicEventBehavior)

function RelSkillBehavior:__Init()
end

function RelSkillBehavior:__Delete()
end

function RelSkillBehavior:OnInit()
end

function RelSkillBehavior:OnDestroy()
end

function RelSkillBehavior:OnExecute()
    local from = self.event.from
    local actionArgs = self.event.conf.action_args
    local entity = self.world.EntitySystem:GetEntity(from.entityUid)
    if entity then
        local skillId = actionArgs.skillId
        local skillLev = actionArgs.skillLev

        local baseConf = self.world.BattleConfSystem:SkillData_data_skill_base(skillId)
        assert(baseConf,string.format("技能配置不存在[skillId:%s][技能Id:%s]",tostring(skillId),tostring(skillLev)))

        entity.SkillComponent:RepSkill(skillId,skillLev)
        local skill = entity.SkillComponent:GetSkill(skillId)
        if not skill:OnCanRel(true) then
            return false
        end

        if baseConf.rel_type == SkillDefine.RelType.trigger then
            local triggerNum = skill:GetData(SkillDefine.DataKey.trigger_num) or 0
            skill:SetData(SkillDefine.DataKey.trigger_num,triggerNum + 1)
        elseif baseConf.rel_type ~= SkillDefine.RelType.pasv then
            local args = nil
            local flag,entitys = self.world.BattleCastSkillSystem:CanCastSkill(entity,skill,nil,nil,args)
            if flag then
                entity.SkillComponent:RelSkill(skillId,entitys)
            end
        end
    end
    return true
end