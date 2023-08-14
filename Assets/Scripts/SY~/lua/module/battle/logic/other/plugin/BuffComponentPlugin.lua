BuffComponentPlugin = BaseClass("BuffComponentPlugin",SECBPlugin)
BuffComponentPlugin.NAME = "BuffComp"

BuffComponentPlugin.BuffStateMapping =
{
    [BattleDefine.BuffState.ban_rel_skill] = "ActiveRelSkill",
}

function BuffComponentPlugin:__Init()

end

function BuffComponentPlugin:__Delete()

end

function BuffComponentPlugin:ActiveBuffState(entity,state,flag)
    local funName = BuffComponentPlugin.BuffStateMapping[state]
    if funName then
        self[funName](self,entity,flag)
    end
end

function BuffComponentPlugin:ActiveRelSkill(entity,flag)
    if entity then
        if flag then
            entity.SkillComponent:Break()
        end
        entity.SkillComponent:SetEnable(not flag)
        entity.AIComponent:SetEnable(not flag)
    end
end