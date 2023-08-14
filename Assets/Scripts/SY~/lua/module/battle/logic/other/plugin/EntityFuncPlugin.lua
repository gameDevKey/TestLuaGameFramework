EntityFuncPlugin = BaseClass("EntityFuncPlugin",SECBPlugin)
EntityFuncPlugin.NAME = "EntityFunc"

function EntityFuncPlugin:__Init()

end

function EntityFuncPlugin:__Delete()
    
end

function EntityFuncPlugin:EntityAddBuff(entity,fromEntityUid,buffs,args)
    for _,buffId in ipairs(buffs) do
        entity.BuffComponent:AddBuff(fromEntityUid,buffId,args)
    end
end

function EntityFuncPlugin:EntityRemoveBuff(entity,buffs)
    for _,buffId in ipairs(buffs) do
        entity.BuffComponent:RemoveBuffById(buffId)
    end
end

function EntityFuncPlugin:EntityRemoveBuffByConds(entity,args)
    local toRemoveBuffs = {}
    for iter in entity.BuffComponent.buffList:Items() do
        local buff = entity.BuffComponent:GetBuffByUid(iter.value)

        if self.world.PluginSystem.CheckCond:CheckBuff(buff,args) then
            table.insert(toRemoveBuffs,iter.index)
        end

    end
    self:EntityRemoveBuff(entity,toRemoveBuffs)
end

function EntityFuncPlugin:IsSkillTarget(entity,targetEntity,skillId)
    local conf = self.world.BattleConfSystem:SkillData_data_skill_base(skillId)
    local targetArgs = self.world.BattleMixedSystem:GetTargetArgs(conf.target_cond_id)
    local flag = BattleSearchSystem:IsTargetType(entity,targetEntity,targetArgs)
    if not flag then
        return false
    end
end

function EntityFuncPlugin:RemoveEntityDisableComponent(entity)
    if entity.MoveComplete then
        entity.MoveComplete:SetEnable(false)
    end

    if entity.CollistionComponent then
        entity.CollistionComponent:SetEnable(false)
    end

    if entity.HitComponent then
        entity.HitComponent:SetEnable(false)
    end

    if entity.SkillComponent then
        entity.SkillComponent:SetEnable(false)
    end

    if entity.BuffComponent then
        entity.BuffComponent:SetEnable(false)
    end
end