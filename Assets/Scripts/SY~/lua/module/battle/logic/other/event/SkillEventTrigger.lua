SkillEventTrigger = BaseClass("SkillEventTrigger",SECBEventTrigger)

function SkillEventTrigger:__Init()

end

function SkillEventTrigger:__Delete()
    
end

function SkillEventTrigger:OnRegister()
    self:AddHandler(BattleEvent.rel_skill,self:ToFunc("RelSkillEvent"))
    self:AddHandler(BattleEvent.skill_hit,self:ToFunc("SkillHit"))
    self:AddHandler(BattleEvent.skill_kill_unit,self:ToFunc("SkillKillUnit"))
    self:AddHandler(BattleEvent.skill_hit_check_crit,self:ToFunc("SkillHitCheckCrit"))
    self:AddHandler(BattleEvent.change_hit_result_val,self:ToFunc("ChangeHitResultVal"))
    self:AddHandler(BattleEvent.change_do_hit_result_val,self:ToFunc("ChangeDoHitResultVal"))
    self:AddHandler(BattleEvent.absorb_hit_dmg,self:ToFunc("AbsorbHitDmg"))
    self:AddHandler(BattleEvent.share_do_hit_result_val_in_range,self:ToFunc("ShareDoHitResultValInRange"))
    self:AddHandler(BattleEvent.change_hit_result_id,self:ToFunc("ChangeHitResultId"))
    self:AddHandler(BattleEvent.unit_be_hit,self:ToFunc("UnitBeHit"))
    self:AddHandler(BattleEvent.skill_hit_complete,self:ToFunc("SkillHitComplete"))
    self:AddHandler(BattleEvent.unit_try_to_dodge_hit_result,self:ToFunc("UnitTryToDodgeHitResult"))
    self:AddHandler(BattleEvent.unit_dodge,self:ToFunc("UnitDodge"))
    self:AddHandler(BattleEvent.try_to_rel_skill,self:ToFunc("TryToRelSkill"))

    self:AddHandler(BattleEvent.skill_ready_hit,self:ToFunc("SkillReadyHit"))

    self:AddHandler(BattleEvent.skill_complete,self:ToFunc("SkillComplete"))
end

function SkillEventTrigger:RelSkillEvent(listeners,entity,skillUid,skillId,skillLev,relUid)
    local params = {}
    params.fromEntityUid = entity.uid
    params.skillUid = skillUid
    params.relUid = relUid

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"entityUid",entity.uid) and self:CheckSkill(args.skillId,args.skillLev,skillId,skillLev) then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function SkillEventTrigger:SkillHit(listeners,fromEntityUid,targetEntityUid,skillId,skillLev,relUid,hitUid,hitType,resultVal)
    local params = {}
    params.fromEntityUid = fromEntityUid
    params.targetEntityUids = {targetEntityUid}
    params.resultVal = resultVal
    params.hitType = hitType
    params.skillId = skillId
    params.relUid = relUid

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"entityUid",fromEntityUid)
            and self:CheckNum(args,false,"hitUid",hitUid)
            and self:CheckSkill(args.skillId,args.skillLev,skillId,skillLev) then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function SkillEventTrigger:SkillReadyHit(listeners,fromEntityUid,targetEntityUid,skillId,skillLev,relUid,hitUid,hitType,hitResultUid)
    local params = {}
    params.fromEntityUid = fromEntityUid
    params.targetEntityUids = {targetEntityUid}
    params.hitType = hitType
    params.skillId = skillId
    params.skillLev = skillLev
    params.relUid = relUid
    params.hitResultUid = hitResultUid

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"entityUid",fromEntityUid)
            and self:CheckNum(args,false,"hitUid",hitUid)
            and self:CheckNum(args,false,"hitType",hitType)
            and self:CheckSkill(args.skillId,args.skillLev,skillId,skillLev) then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end


function SkillEventTrigger:SkillKillUnit(listeners,fromEntityUid,targetEntityUid,skillId,skillLev,hitUid)
    local params = {}
    params.fromEntityUid = fromEntityUid
    params.targetEntityUids = {targetEntityUid}

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"entityUid",fromEntityUid)
            and self:CheckNum(args,false,"hitUid",hitUid)
            and self:CheckSkill(args.skillId,args.skillLev,skillId,skillLev) then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end


function SkillEventTrigger:SkillHitCheckCrit(listeners,fromEntityUid,targetEntityUid,skillUid,skillId,skillLev,relUid,hitUid,critInfo)
    local params = {}
    params.fromEntityUid = fromEntityUid
    params.targetEntityUids = {targetEntityUid}
    params.critInfo = critInfo
    params.skillUid = skillUid
    params.relUid = relUid

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"entityUid",fromEntityUid)
            and self:CheckNum(args,false,"hitUid",hitUid)
            and self:CheckSkill(args.skillId,args.skillLev,skillId,skillLev) then
            iter.value.callBack(params,iter.value.uid)
            if params.critInfo.flag then
                return
            end
        end
    end
end

function SkillEventTrigger:ChangeHitResultVal(listeners,fromEntityUid,targetEntityUid,hitType,skillUid,skillId,skillLev,relUid,hitUid,hitDisType,dmgType,calcResultVal)
    local curCalcResultVal = calcResultVal

    local params = {}
    params.fromEntityUid = fromEntityUid
    params.targetEntityUids = {targetEntityUid}
    params.hitType = hitType
    params.hitDisType = hitDisType
    params.dmgType = dmgType
    params.curCalcResultVal = curCalcResultVal
    params.skillUid = skillUid
    params.relUid = relUid

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"entityUid",fromEntityUid)
            and self:CheckNum(args,false,"hitUid",hitUid)
            and self:CheckSkill(args.skillId,args.skillLev,skillId,skillLev) then
            local val = iter.value.callBack(params,iter.value.uid)
            if val then
                curCalcResultVal = curCalcResultVal + val
                params.curCalcResultVal = curCalcResultVal
            end
        end
    end
    return curCalcResultVal
end


function SkillEventTrigger:ChangeDoHitResultVal(listeners,fromEntityUid,targetEntityUid,hitType,hitDisType,dmgType,calcResultVal)
    local curCalcResultVal = calcResultVal

    local params = {}
    params.fromEntityUid = fromEntityUid
    params.targetEntityUids = {targetEntityUid}
    params.hitType = hitType
    params.hitDisType = hitDisType
    params.dmgType = dmgType
    params.curCalcResultVal = curCalcResultVal

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"entityUid",targetEntityUid) then
            local val = iter.value.callBack(params,iter.value.uid)
            if val then
                curCalcResultVal = curCalcResultVal + val
                params.curCalcResultVal = curCalcResultVal
            end
        end
    end
    return curCalcResultVal
end

function SkillEventTrigger:ShareDoHitResultValInRange(listeners,fromEntityUid,targetEntityUid,hitType,hitDisType,dmgType,calcResultVal)
    local curCalcResultVal = calcResultVal

    local params = {}
    params.fromEntityUid = fromEntityUid
    params.targetEntityUids = {targetEntityUid}
    params.hitType = hitType
    params.hitDisType = hitDisType
    params.dmgType = dmgType
    params.curCalcResultVal = curCalcResultVal
    params.srcCalcResultVal = calcResultVal

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"entityUid",fromEntityUid) then
            local val = iter.value.callBack(params,iter.value.uid)
            if val then
                curCalcResultVal = curCalcResultVal + val
                params.curCalcResultVal = curCalcResultVal
            end
        end
    end
    return curCalcResultVal
end

function SkillEventTrigger:AbsorbHitDmg(listeners,fromEntityUid,targetEntityUid,calcResultVal)
    local curCalcResultVal = calcResultVal

    local params = {}
    params.fromEntityUid = fromEntityUid
    params.targetEntityUids = {targetEntityUid}
    params.fromCalcResultVal = calcResultVal
    params.curCalcResultVal = curCalcResultVal
    
    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"entityUid",targetEntityUid) then
            local val = iter.value.callBack(params,iter.value.uid)
            if val then
                curCalcResultVal = curCalcResultVal + val
                params.curCalcResultVal = curCalcResultVal
            end
        end
    end
    return curCalcResultVal
end


function SkillEventTrigger:ChangeHitResultId(listeners,fromEntityUid,targetEntityUid,skillId,skillLev,hitResultId,hitResultUid)
    local curCalcResultVal = calcResultVal

    local params = {}
    params.fromEntityUid = fromEntityUid
    params.targetEntityUids = {targetEntityUid}
    params.hitResultId = hitResultId
    params.hitResultUid = hitResultUid

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"entityUid",fromEntityUid) 
            and self:CheckSkill(args.skillId,args.skillLev,skillId,skillLev) then
            local newHitResultId = iter.value.callBack(params,iter.value.uid)
            if newHitResultId then
                return newHitResultId
            end
        end
    end
end

function SkillEventTrigger:UnitBeHit(listeners,fromEntityUid,beHitEntityUid,skillId,skillLev,beHitValue,dmgType)
    if not skillId then
        return
    end
    local conf = self.world.BattleConfSystem:SkillData_data_skill_base(skillId)
    local hitDistType = conf.hit_dist_type

    local params = {}
    params.fromEntityUid = fromEntityUid
    params.beHitEntityUid = beHitEntityUid
    params.hitDistType = hitDistType
    params.beHitValue = beHitValue
    
    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"hitDistType",hitDistType)
            and self:CheckNum(args,false,"dmgType",dmgType)
            and self:CheckEntity(args,fromEntityUid,beHitEntityUid) then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function SkillEventTrigger:SkillHitComplete(listeners,fromEntityUid,targetEntitysUid,hitUid,totalHitResult)
    local params = {}
    params.fromEntityUid = fromEntityUid
    params.targetEntitysUid = targetEntitysUid
    params.totalHitResult = totalHitResult

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"entityUid",fromEntityUid) 
            and self:CheckNum(args,false,"hitUid",hitUid) then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function SkillEventTrigger:UnitTryToDodgeHitResult(listeners,fromEntityUid,targetEntityUid,hitResultId)
    local params = {}
    params.fromEntityUid = fromEntityUid
    params.targetEntityUids = {targetEntityUid}
    params.hitResultId = hitResultId

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"entityUid",targetEntityUid) then
            local dodgeFlag = iter.value.callBack(params,iter.value.uid)
            return dodgeFlag
        end
    end
end

function SkillEventTrigger:UnitDodge(listeners,fromEntityUid,targetEntityUid,hitResultId)
    local params = {}
    params.fromEntityUid = fromEntityUid
    params.targetEntityUids = {targetEntityUid}
    params.hitResultId = hitResultId

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"entityUid",targetEntityUid) then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function SkillEventTrigger:TryToRelSkill(listeners,fromEntityUid,skill)
    local params = {}
    params.skill = skill

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"entityUid",fromEntityUid) then
            local isnotNormalAttack = iter.value.callBack(params,iter.value.uid)
            return isnotNormalAttack
        end
    end
end


function SkillEventTrigger:CheckSkill(skillId,skillLev,checkSkillId,checkSkillLev)
    if not skillId or skillId == 0 then
        return true
    end

    local conf = self.world.BattleConfSystem:SkillData_data_skill_base(checkSkillId)

    local flag = false
    if skillId == checkSkillId then
        flag = true
    elseif skillId == -1 and conf.type == SkillDefine.SkillType.normal_atk then
        flag = true
    end

    if not flag then
        return false
    elseif not skillLev or skillLev == 0 then
        return true
    else
        return skillLev == checkSkillLev
    end
end


function SkillEventTrigger:SkillComplete(listeners,fromEntityUid,skillId,skillLev,relUid)
    local params = {}
    params.fromEntityUid = fromEntityUid
    params.skillId = skillId
    params.skillLev = skillLev
    params.relUid = relUid

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"entityUid",fromEntityUid)
            and self:CheckNum(args,false,"relUid",relUid)
            and self:CheckSkill(args.skillId,args.skillLev,skillId,skillLev) then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end
