EntityStateCheckPlugin = BaseClass("EntityStateCheckPlugin",SECBPlugin)
EntityStateCheckPlugin.NAME = "EntityStateCheck"

function EntityStateCheckPlugin:__Init()

end

function EntityStateCheckPlugin:__Delete()
    
end


function EntityStateCheckPlugin:CanMove(entity)
    if entity.StateComponent and entity.StateComponent:HasMarkState(BattleDefine.MarkState.force_move) then
        return true
    end
    if entity.StateComponent and entity.StateComponent:HasMarkState(BattleDefine.MarkState.move_releasing_skill) then
        return true
    end
    if entity.StateComponent and entity.StateComponent:HasMarkState(BattleDefine.MarkState.knock_back) then
        return false
    end

    if entity.StateComponent and not entity.StateComponent:CanSwitchState() then
        return false
    end

    if entity.BuffComponent and entity.BuffComponent:HasBuffState(BattleDefine.BuffState.frozen) then
        return false
    end

    if entity.BuffComponent and entity.BuffComponent:HasBuffState(BattleDefine.BuffState.dizziness) then
        return false
    end

    if entity.BuffComponent and entity.BuffComponent:HasBuffState(BattleDefine.BuffState.petrifying) then
        return false
    end

    return true
end


function EntityStateCheckPlugin:CanRelSkill(entity)
    if entity.StateComponent and entity.StateComponent:HasMarkState(BattleDefine.MarkState.releasing_skill) then
        return false
    end

    if entity.StateComponent and entity.StateComponent:HasMarkState(BattleDefine.MarkState.move_releasing_skill) then
        return false
    end

    if entity.StateComponent and entity.StateComponent:HasMarkState(BattleDefine.MarkState.knock_back) then
        return false
    end

    if entity.StateComponent and entity.StateComponent:HasMarkState(BattleDefine.MarkState.force_move) then
        return false
    end

    if entity.StateComponent and not entity.StateComponent:CanSwitchState() then
        return false
    end

    if entity.BuffComponent and entity.BuffComponent:HasBuffState(BattleDefine.BuffState.frozen) then
        return false
    end

    if entity.BuffComponent and entity.BuffComponent:HasBuffState(BattleDefine.BuffState.dizziness) then
        return false
    end

    if entity.BuffComponent and entity.BuffComponent:HasBuffState(BattleDefine.BuffState.petrifying) then
        return false
    end

    return true
end

function EntityStateCheckPlugin:CanBeSelect(entity)
    if entity.StateComponent and entity.StateComponent:IsState(BattleDefine.EntityState.die) then
        return false
    end

    return true
end

function EntityStateCheckPlugin:IsControlState(entity)
    if entity.BuffComponent and entity.BuffComponent:HasBuffState(BattleDefine.BuffState.frozen) then
        return true
    end

    if entity.BuffComponent and entity.BuffComponent:HasBuffState(BattleDefine.BuffState.dizziness) then
        return true
    end

    if entity.BuffComponent and entity.BuffComponent:HasBuffState(BattleDefine.BuffState.petrifying) then
        return true
    end

    return false
end