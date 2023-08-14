PasvActionPlugin = BaseClass("PasvActionPlugin",SECBPlugin)
PasvActionPlugin.NAME = "PasvAction"

function PasvActionPlugin:__Init()
    self.actionHandles = {}
	self.actionHandles["释放技能"] = self:ToFunc("RelSkill")
    self.actionHandles["目标位置-释放技能"] = self:ToFunc("TargetPosRelSkill")
    self.actionHandles["释放技能-命中值作为参数"] = self:ToFunc("RelSkillByResultVal")
    self.actionHandles["释放技能-被命中值作为参数"] = self:ToFunc("RelSkillByBeHitVal")
    self.actionHandles["释放技能-触发者作为目标"] = self:ToFunc("RelSkillByFromTarget")
    self.actionHandles["释放技能-目标作为目标"] = self:ToFunc("RelSkillByTargetToTarget")
	self.actionHandles["添加Buff"] = self:ToFunc("AddBuff")
    self.actionHandles["移除Buff"] = self:ToFunc("RemoveBuff")
    self.actionHandles["添加Buff-目标作为触发者"] = self:ToFunc("AddBuffByTargetToFrom")
    self.actionHandles["添加Buff-命中值作为参数"] = self:ToFunc("AddBuffByResultVal")
    self.actionHandles["暴击"] = self:ToFunc("Crit")
    self.actionHandles["重置技能冷却"] = self:ToFunc("ResetSkillCD")
    self.actionHandles["本次释放技能暴击"] = self:ToFunc("TheRelSkillCrit")
    self.actionHandles["本次释放技能修改命中结算"] = self:ToFunc("TheRelSkillChangeHitResult")
    self.actionHandles["本次命中修改结算Id"] = self:ToFunc("TheHitChangeResultId")
    self.actionHandles["额外命中结算"] = self:ToFunc("ExceptHitResult")
end

function PasvActionPlugin:__Delete()
    
end


function PasvActionPlugin:ExecAction(passive,entity,actions,execParam)
    for i,v in ipairs(actions) do
        local handle = self.actionHandles[v.type]
        if handle then
            handle(passive,entity,v,execParam)
        else
            LogErrorf("未实现的被动效果[被动ID:%s][效果:%s]",passive.pasvId,tostring(v.type))
        end
    end
end

function PasvActionPlugin:RelSkill(passive,entity,confParam,execParam)
    local skillId = confParam.skillId
	local skillLev = confParam.skillLev ~= -1 and confParam.skillLev or passive.skill.skillLev

	local baseConf = self.world.BattleConfSystem:SkillData_data_skill_base(skillId)
	assert(baseConf,string.format("技能配置不存在[被动Id:%s][技能Id:%s]",passive.pasvId,tostring(skillId)))

    entity.SkillComponent:RepSkill(skillId,skillLev)
    local skill = entity.SkillComponent:GetSkill(skillId)

    self:CheckRelSkill(entity,skill)
end

function PasvActionPlugin:RelSkillByFromTarget(passive,entity,confParam,execParam)
    local skillId = confParam.skillId
	local skillLev = confParam.skillLev ~= -1 and confParam.skillLev or passive.skill.skillLev

	local baseConf = self.world.BattleConfSystem:SkillData_data_skill_base(skillId)
	assert(baseConf,string.format("技能配置不存在[被动Id:%s][技能Id:%s]",passive.pasvId,tostring(skillId)))

    entity.SkillComponent:RepSkill(skillId,skillLev)
    local skill = entity.SkillComponent:GetSkill(skillId)

    self:CheckRelSkill(entity,skill,nil,nil,{execParam.fromEntityUid})
end

function PasvActionPlugin:RelSkillByTargetToTarget(passive,entity,confParam,execParam)
    local skillId = confParam.skillId
	local skillLev = confParam.skillLev ~= -1 and confParam.skillLev or passive.skill.skillLev

	local baseConf = self.world.BattleConfSystem:SkillData_data_skill_base(skillId)
	assert(baseConf,string.format("技能配置不存在[被动Id:%s][技能Id:%s]",passive.pasvId,tostring(skillId)))

    entity.SkillComponent:RepSkill(skillId,skillLev)
    local skill = entity.SkillComponent:GetSkill(skillId)

    self:CheckRelSkill(entity,skill,nil,nil,execParam.targetEntityUids)
end

function PasvActionPlugin:ExceptHitResult(passive,entity,confParam,execParam)
    -- LogYqh("ExceptHitResult confParam=",confParam,'execParam=',execParam)
    self.world.BattleHitSystem:HitResult(BattleDefine.HitFrom.other,
        execParam.fromEntityUid,execParam.targetEntityUids[1],confParam.hitResultId,execParam)
end

function PasvActionPlugin:CheckRelSkill(entity,skill,transInfo,passEntitys,entitys,execParam)
    if not skill:OnCanRel(true) then
        return
    end

    local checkRel = false
    local canRel = false

    if skill.baseConf.rel_type == SkillDefine.RelType.trigger then
        checkRel = true
        local triggerNum = skill:GetData(SkillDefine.DataKey.trigger_num) or 0
        skill:SetData(SkillDefine.DataKey.trigger_num,triggerNum + 1)
    elseif skill.baseConf.rel_type == SkillDefine.RelType.pasv then
        canRel = true
    elseif skill.baseConf.rel_type == SkillDefine.RelType.action then
        checkRel = true
    end

    if checkRel then
        local runSkill = entity.SkillComponent:GetRunSkill()
        if not runSkill and skill.baseConf.can_break == 1 then
            canRel = true
        elseif runSkill and skill.baseConf.priority > runSkill.baseConf.priority then
            canRel = true
            entity.SkillComponent:Abort()
        end
    end

    if canRel then
        if execParam and execParam.inHitResultCalVal then
            skill:SetData(SkillDefine.DataKey.skill_hit_result,execParam.inHitResultCalVal)
        end
        
        if entitys then
            entity.SkillComponent:RelSkill(skill.skillId,entitys)
        else
            local flag,entitys = self.world.BattleCastSkillSystem:CanCastSkill(entity,skill,transInfo,passEntitys,args)
            if flag then
                entity.SkillComponent:RelSkill(skill.skillId,entitys)
            end
        end
    end
end


function PasvActionPlugin:TargetPosRelSkill(passive,entity,confParam,execParam)
    local skillId = confParam.skillId
	local skillLev = confParam.skillLev ~= -1 and confParam.skillLev or passive.skill.skillLev

	local baseConf = self.world.BattleConfSystem:SkillData_data_skill_base(skillId)
	assert(baseConf,string.format("技能配置不存在[被动Id:%s][技能Id:%s]",passive.pasvId,tostring(skillId)))

    if baseConf.rel_type == SkillDefine.RelType.action then
        LogErrorf("被动无法释放主动技能[被动Id:%s][技能Id:%s]",passive.pasvId,skillId)
        return
    end

    entity.SkillComponent:RepSkill(skillId,skillLev)
    local skill = entity.SkillComponent:GetSkill(skillId)

    if not skill:OnCanRel(true) then
        return
    end

    if baseConf.rel_type == SkillDefine.RelType.trigger then
        local triggerNum = skill:GetData(SkillDefine.DataKey.trigger_num) or 0
        skill:SetData(SkillDefine.DataKey.trigger_num,triggerNum + 1)
    elseif baseConf.rel_type == SkillDefine.RelType.pasv then
        local firstTargetUid = execParam.targetEntityUids[1]
        local transInfo = nil
        if firstTargetUid then
            local pos = self.world.EntitySystem:GetEntityPos(firstTargetUid)
            transInfo = {}
            transInfo.posX = pos.x
            transInfo.posZ = pos.z
        end

        local flag,entitys = self.world.BattleCastSkillSystem:CanCastSkill(entity,skill,transInfo,{[firstTargetUid] = true},args)
        if flag then
            entity.SkillComponent:RelSkill(skillId,entitys,transInfo)
        end
    end
end

function PasvActionPlugin:RelSkillByResultVal(passive,entity,confParam,execParam)
    local skillId = confParam.skillId
	local skillLev = confParam.skillLev ~= -1 and confParam.skillLev or passive.skill.skillLev

    local baseConf = self.world.BattleConfSystem:SkillData_data_skill_base(skillId)
    assert(baseConf,string.format("技能配置不存在[被动Id:%s][技能Id:%s]",passive.pasvId,tostring(skillId)))

    if baseConf.rel_type == SkillDefine.RelType.action then
        LogErrorf("被动无法释放主动技能[被动Id:%s][技能Id:%s]",passive.pasvId,skillId)
        return
    end

    entity.SkillComponent:RepSkill(skillId,skillLev)
    local skill = entity.SkillComponent:GetSkill(skillId)

    if not skill:OnCanRel(true) then
        return
    end

    if baseConf.rel_type == SkillDefine.RelType.trigger then
        local triggerNum = skill:GetData(SkillDefine.DataKey.trigger_num) or 0
        skill:SetData(SkillDefine.DataKey.trigger_num,triggerNum + 1)
    elseif baseConf.rel_type == SkillDefine.RelType.pasv then
        skill:SetData(SkillDefine.DataKey.skill_hit_result,execParam.totalHitResult)
        local flag,entitys = self.world.BattleCastSkillSystem:CanCastSkill(entity,skill,nil,nil,args)
        if flag then
            entity.SkillComponent:RelSkill(skillId,entitys)
        end
    end
end

function PasvActionPlugin:RelSkillByBeHitVal(passive,entity,confParam,execParam)
    local skillId = confParam.skillId
	local skillLev = confParam.skillLev ~= -1 and confParam.skillLev or passive.skill.skillLev

    local baseConf = self.world.BattleConfSystem:SkillData_data_skill_base(skillId)
    assert(baseConf,string.format("技能配置不存在[被动Id:%s][技能Id:%s]",passive.pasvId,tostring(skillId)))

    if baseConf.rel_type == SkillDefine.RelType.action then
        LogErrorf("被动无法释放主动技能[被动Id:%s][技能Id:%s]",passive.pasvId,skillId)
        return
    end

    entity.SkillComponent:RepSkill(skillId,skillLev)
    local skill = entity.SkillComponent:GetSkill(skillId)

    if not skill:OnCanRel(true) then
        return
    end

    if baseConf.rel_type == SkillDefine.RelType.trigger then
        local triggerNum = skill:GetData(SkillDefine.DataKey.trigger_num) or 0
        skill:SetData(SkillDefine.DataKey.trigger_num,triggerNum + 1)
    elseif baseConf.rel_type == SkillDefine.RelType.pasv then
        skill:SetData(SkillDefine.DataKey.be_hit_value,execParam.beHitValue)
        local flag,entitys = self.world.BattleCastSkillSystem:CanCastSkill(entity,skill,nil,nil,args)
        if flag then
            entity.SkillComponent:RelSkill(skillId,entitys)
        end
    end
end

function PasvActionPlugin:AddBuff(passive,entity,confParam,execParam)
    self.world.PluginSystem.EntityFunc:EntityAddBuff(entity,execParam.fromEntityUid,confParam.buffId)
end

function PasvActionPlugin:AddBuffByTargetToFrom(passive,entity,confParam,execParam)
    self.world.PluginSystem.EntityFunc:EntityAddBuff(entity,execParam.targetEntityUids[1],confParam.buffId)
end

function PasvActionPlugin:AddBuffByResultVal(passive,entity,confParam,execParam)
    self.world.PluginSystem.EntityFunc:EntityAddBuff(entity,execParam.targetEntityUids[1],confParam.buffId,{calcVal = execParam.resultVal})
end

function PasvActionPlugin:RemoveBuff(passive,entity,confParam,execParam)
    self.world.PluginSystem.EntityFunc:EntityRemoveBuff(entity,confParam.buffId)
end

function PasvActionPlugin:Crit(passive,entity,confParam,execParam)
    execParam.critInfo.flag = true
end

function PasvActionPlugin:ResetSkillCD(passive,entity,confParam,execParam)
    if confParam.skillId == -1 then
        --重置普攻
        for _, skill in ipairs(entity.SkillComponent.actSkills) do
            if skill.baseConf.type == SkillDefine.SkillType.normal_atk then
                skill:ResetCd()
            end
        end
    elseif confParam.skillId == 0 then
        --重置所有技能
        for _, list in ipairs({entity.SkillComponent.actSkills,entity.SkillComponent.pasvSkills}) do
            for _, skill in ipairs(list) do
                skill:ResetCd()
            end
        end
    else
        --重置技能
        local skill = entity.SkillComponent:GetSkill(confParam.skillId)
        if skill then
            skill:ResetCd()
        end
    end
end

function PasvActionPlugin:TheRelSkillCrit(passive,entity,confParam,execParam)
    self.world.PluginSystem.EntityFunc:EntityAddBuff(entity,execParam.fromEntityUid,{700})
    local buff = entity.BuffComponent:GetBuffById(700)
    buff.behavior:AddSkillRelUid(execParam.skillUid,execParam.relUid)
end


function PasvActionPlugin:TheRelSkillChangeHitResult(passive,entity,confParam,execParam)
    self.world.PluginSystem.EntityFunc:EntityAddBuff(entity,execParam.fromEntityUid,{701})
    local buff = entity.BuffComponent:GetBuffById(701)
    buff.behavior:AddSkillRelInfo(execParam.skillUid,execParam.relUid,confParam)
end


function PasvActionPlugin:TheHitChangeResultId(passive,entity,confParam,execParam)
    self.world.PluginSystem.EntityFunc:EntityAddBuff(entity,execParam.fromEntityUid,{702})
    local buff = entity.BuffComponent:GetBuffById(702)
    buff.behavior:AddChangeInfo(execParam.hitResultUid,confParam)
end
