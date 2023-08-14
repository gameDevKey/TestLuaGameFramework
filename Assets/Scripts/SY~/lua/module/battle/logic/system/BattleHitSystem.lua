BattleHitSystem = BaseClass("BattleHitSystem",SECBEntitySystem)

function BattleHitSystem:__Init()
    self.calcfInfo =
    {
        [BattleDefine.HitCalc.attr] = { fn = "CalcByAttr" },
        [BattleDefine.HitCalc.fixed] = { fn = "CalcByFixed" },
        [BattleDefine.HitCalc.seckill] = { fn = "CalcBySeckill" },
        [BattleDefine.HitCalc.args_val] = { fn = "CalcByArgsVal" },
        [BattleDefine.HitCalc.original] = { fn = "DoNotCalc"},
        [BattleDefine.HitCalc.commander_attr] = { fn = "CalcByCommanderAttr"},
        [BattleDefine.HitCalc.skill_hit_result] = { fn = "CalcBySkillHitResult"},
        [BattleDefine.HitCalc.be_hit_value] = { fn = "CalcByBeHitValue"},
    }
    self.attachCoefInfo = --TODO 附加系数计算
    {
        [BattleDefine.AttachCoefMod.fixed] = { fn = "AttachCoefByFixed"},
        [BattleDefine.AttachCoefMod.distance] = { fn = "AttachCoefByDistance"},
        [BattleDefine.AttachCoefMod.hitNum] = { fn = "AttachCoefByHitNum"},
        [BattleDefine.AttachCoefMod.targetBuffOverlay] = { fn = "TargetBuffOverlay"},
        [BattleDefine.AttachCoefMod.debuffKindCount] = { fn = "AttachCoefByDebuffKindCount" }
    }

    self.hitNumUid = 0
    self.hitResultUid = 0 --命中结算唯一id,每进行一次HitResult调用自增，用于实现针对本次结算产生的作用
end

function BattleHitSystem:__Delete()

end

function BattleHitSystem:OnInitSystem()

end

function BattleHitSystem:OnLateInitSystem()

end

function BattleHitSystem:HitResult(hitFrom,fromEntityUid,hitEntityUid,hitResultId,args,hitNumUid)
    local hitEntity = self.world.EntitySystem:GetEntity(hitEntityUid)
    if not hitEntity then
        return
    end

    if not hitEntity.HitComponent then
        return
    end

    if hitEntity.StateComponent:IsState(BattleDefine.EntityState.die) then
        return
    end


    self.hitResultUid = self.hitResultUid + 1

    local fromEntity = self.world.EntitySystem:GetEntity(fromEntityUid)

    local hitConf = nil
    if hitResultId == 0 then
        if args.calcVal == 0 then
            return
        end
        hitConf = {
            type = args.HitType,
            calc_type = BattleDefine.HitCalc.original,
            from_add_buffs={},
            hit_add_buffs={},
            can_be_dodge= BattleDefine.hitResultCanBeDodge.canNotBeDodge -- 分担伤害buff造成的命中结算不可被闪避
        }
    else
        if hitFrom == BattleDefine.HitFrom.skill then
            local curHitConf = self.world.BattleConfSystem:HitResultData_data_hit_result(hitResultId)
            if not curHitConf then
                assert(false,string.format("命中结算配置不存在[skillId:%s][skillLev:%s][hitResultId:%s]",args.skillId,args.skillLev,hitResultId))
            end
            self.world.EventTriggerSystem:Trigger(BattleEvent.skill_ready_hit,fromEntityUid,hitEntity.uid
                ,args.skillId,args.skillLev,args.relUid,args.hitUid,curHitConf.type,self.hitResultUid)

            local newHitResultId = self.world.EventTriggerSystem:Trigger(BattleEvent.change_hit_result_id,fromEntityUid,hitEntity.uid
                ,args.skillId,args.skillLev,hitResultId,self.hitResultUid)
            if newHitResultId then
                hitResultId = newHitResultId
            end
        end
            
        hitConf = self.world.BattleConfSystem:HitResultData_data_hit_result(hitResultId)
        if not hitConf then
            assert(false,string.format("命中结算配置不存在[结算Id:%s]",tostring(hitResultId)))
        end
    end

    if hitConf.type == BattleDefine.HitType.energy and hitEntity.AttrComponent:GetValue(GDefine.Attr.max_energy) == 0 then
        -- 命中类型为能量 但目标无能量条
        return
    end

    local missHit = self.world.EventTriggerSystem:Trigger(BattleEvent.check_miss_hit,fromEntityUid,hitEntity.uid,hitResultId)
    if missHit then
        return
    end

    if hitFrom == BattleDefine.HitFrom.skill then
        local skill = args.skill
        local key = args.skillId.."_"..args.relUid
        local val = skill:GetData(key)
        if not val then
            val = {}
            val.hitNumUids = {}
            val.hitNumUids[hitNumUid] = true
            val.hitNum = 1
            skill:SetData(key,val)
        elseif not val.hitNumUids[hitNumUid] then
            val.hitNumUids[hitNumUid] = true
            val.hitNum = val.hitNum + 1
        end
    end

    if BattleDefine.hitResultCanBeDodgeToBool[hitConf.can_be_dodge] then
        -- 命中结算可被闪避，触发尝试闪避命中结算事件
        local isDodge = self.world.EventTriggerSystem:Trigger(BattleEvent.unit_try_to_dodge_hit_result,fromEntityUid,hitEntity.uid,hitResultId)
        if isDodge then
            self.world.EventTriggerSystem:Trigger(BattleEvent.unit_dodge,fromEntityUid,hitEntity.uid,hitResultId)
        else
            isDodge = self.world.PluginSystem.CheckCond:Prob(nil,{prob = hitEntity.AttrComponent:GetValue(GDefine.Attr.dodge)})
            if isDodge then
                self.world.EventTriggerSystem:Trigger(BattleEvent.unit_dodge,fromEntityUid,hitEntity.uid,hitResultId)
                self.world.ClientIFacdeSystem:Call("SendEvent","FlyingTextView","ShowFlyingText",BattleDefine.FlyingText.state,
                    {state = BattleDefine.FlyingTextState.dodge,uid = hitEntity.uid})
            end
        end

        if isDodge then
            return
        end
    end

    local calcResultVal,flag = nil,true

    if hitConf.type ~= BattleDefine.HitType.assist then
        local calc = self.calcfInfo[hitConf.calc_type]
        if not calc then
            assert(false,string.format("未知的命中结算类型[%s][proxy:nil]",tostring(hitConf.calc_type)))
        else
            calcResultVal,flag = self[calc.fn](self,hitConf,fromEntityUid,hitEntity,args)
            if calcResultVal == nil then
                assert(false,string.format("命中结算[%s]命中类型不为[辅助]但计算结果为空，请检查字段[计算公式][命中值列表]是否漏填或错填！",hitResultId))
            end
        end
        if hitConf.cal_result_modify_by_attach_coef and next(hitConf.cal_result_modify_by_attach_coef) ~= nil then
            for i, v in ipairs(hitConf.cal_result_modify_by_attach_coef) do
                if not v.ignoreCommander or
                    not hitEntity.TagComponent:IsTag(BattleDefine.EntityTag.home) then
                    local attachCoefFunc = self.attachCoefInfo[BattleDefine.ConfAttachCoefMod[v.mod]]
                    if not attachCoefFunc then
                        assert(false,string.format("未知的附加系数修改类型[%s]",tostring(v.mod)))
                    else
                        calcResultVal = self[attachCoefFunc.fn](self,calcResultVal,v,fromEntityUid,hitEntity,args)
                    end
                end
            end
        end
    end

    if hitConf.type ~= BattleDefine.HitType.assist and hitFrom == BattleDefine.HitFrom.skill then
        if flag then
            calcResultVal = self:SkillLateCalcResultVal(hitConf,fromEntityUid,hitEntity,args,calcResultVal)
        end
    end

    if args.maxHitVal and calcResultVal > args.maxHitVal then
        calcResultVal = args.maxHitVal
    end

    if hitEntity.ObjectDataComponent.unitConf.type == BattleDefine.UnitType.home 
        and hitConf.commander_hit.mode ~= nil then
        calcResultVal = self.world.PluginSystem.CalcAttr:CalcVal(calcResultVal,hitConf.commander_hit)
    end

    if hitConf.type ~= BattleDefine.HitType.assist and hitFrom == BattleDefine.HitFrom.skill then
        self:SkillHit(hitConf,fromEntityUid,hitEntity,args,calcResultVal,isCrit)
    elseif hitConf.type ~= BattleDefine.HitType.assist and hitFrom == BattleDefine.HitFrom.buff then
        self:BuffHit(hitConf,fromEntityUid,hitEntity,args,calcResultVal)
    elseif hitConf.type ~= BattleDefine.HitType.assist and hitFrom == BattleDefine.HitFrom.other then
        self:OtherHit(hitConf,fromEntityUid,hitEntity,args,calcResultVal)
    end


    if hitConf.type == BattleDefine.HitType.dmg and args then
        self.world.EventTriggerSystem:Trigger(BattleEvent.unit_be_hit,fromEntityUid,hitEntity.uid,args.skillId,args.skillLev,calcResultVal,hitConf.dmg_type)
    end

    if fromEntity then
        self.world.PluginSystem.EntityFunc:EntityAddBuff(fromEntity,fromEntityUid,hitConf.from_add_buffs)
    end
    self.world.PluginSystem.EntityFunc:EntityAddBuff(hitEntity,fromEntityUid,hitConf.hit_add_buffs)

    self:CheckDie(hitFrom,fromEntityUid,hitConf.flag,hitEntity,args)

    if hitConf.target_add_energy.mode ~= nil and not hitEntity.StateComponent:IsState(BattleDefine.EntityState.die) then
        local maxEnergy = hitEntity.AttrComponent:GetValue(GDefine.Attr.max_energy)
        local addEnergy = self.world.PluginSystem.CalcAttr:CalcVal(maxEnergy,hitConf.target_add_energy)
        hitEntity.AttrComponent:AddValue(BattleDefine.Attr.energy,addEnergy)
    end

    self:AddHeroOutput(hitConf.type,fromEntityUid,hitEntity,calcResultVal)

    return calcResultVal
end

function BattleHitSystem:CheckHitFactor(fromEntityUid,calcResultVal)
    if self.world.worldType ~= BattleDefine.WorldType.pve then
        return calcResultVal
    end

    local ratio = self.world.BattleCommanderSystem.changeHitFactor
    if ratio == 0 then
        return calcResultVal
    end

    local roleUid = self.world.BattleDataSystem.roleUid
    local entity = self.world.EntitySystem:GetRoleCommander(roleUid)
    if entity.uid ~= fromEntityUid then
        return calcResultVal
    end

    return calcResultVal + FPMath.Divide(calcResultVal * ratio,BattleDefine.AttrRatio)
end

--统计数据，非客户端情况下不需要
function BattleHitSystem:AddHeroOutput(hitType,fromEntityUid,hitEntity,calcResultVal)
    if not self.world.opts.isClient then
        return nil
    end

    if fromEntityUid == hitEntity.uid then
        return
    end

    local fromRoleUid = self.world.EntitySystem:GetEntityRoleUid(fromEntityUid,true)
    local hitRoleUid = hitEntity.ObjectDataComponent.roleUid

    --伤害、治疗统计
    local ownerFromEntityUid = self.world.EntitySystem:GetEntityOwnerUid(fromEntityUid) or fromEntityUid
    local ownerFromUnitId = self.world.EntitySystem:GetEntityUnitId(ownerFromEntityUid)
    local ownerFromUnitConf = self.world.BattleConfSystem:UnitData_data_unit_info(ownerFromUnitId)

    --如果最根源不是hero，不记录
    if ownerFromUnitConf.type == BattleDefine.UnitType.hero then
        --local heroConf = self.world.BattleConfSystem:HeroData_data_hero_info(ownerFromUnitConf.base_id)
        if hitType == BattleDefine.HitType.dmg then --heroConf.output_type == BattleDefine.OutputType.atk then
            self.world.BattleStatisticsSystem:AddUnitOutput(fromRoleUid,ownerFromUnitConf.base_id,calcResultVal,BattleDefine.OutputType.atk)
        elseif hitType == BattleDefine.HitType.heal then --heroConf.output_type == BattleDefine.OutputType.heal
            self.world.BattleStatisticsSystem:AddUnitOutput(fromRoleUid,ownerFromUnitConf.base_id,calcResultVal,BattleDefine.OutputType.heal)
        end
    end

    --承受伤害是自己的英雄
    if hitType == BattleDefine.HitType.dmg then
        local ownerHitEntityUid = self.world.EntitySystem:GetEntityOwnerUid(hitEntity.uid) or hitEntity.uid
        local ownerHitUnitId = self.world.EntitySystem:GetEntityUnitId(ownerHitEntityUid)
        local ownerHitUnitConf = self.world.BattleConfSystem:UnitData_data_unit_info(ownerHitUnitId)

        if ownerHitUnitConf.type == BattleDefine.UnitType.hero then
            -- local heroConf = self.world.BattleConfSystem:HeroData_data_hero_info(ownerHitUnitConf.base_id)
            -- if heroConf.output_type == BattleDefine.OutputType.def then
            --     self.world.BattleDataSystem:AddHeroOutput(ownerHitUnitConf.base_id,calcResultVal)
            -- end
            self.world.BattleStatisticsSystem:AddUnitOutput(hitRoleUid,ownerHitUnitConf.base_id,calcResultVal,BattleDefine.OutputType.def)
        end
    end
end

function BattleHitSystem:SkillHit(hitConf,fromEntityUid,hitEntity,args,calcResultVal,isCrit)
    if hitConf.type == BattleDefine.HitType.dmg then
        self:DoSkillDmg(fromEntityUid,hitEntity,calcResultVal,isCrit,hitConf)
    elseif hitConf.type == BattleDefine.HitType.heal then
        self:DoSkillHeal(fromEntityUid,hitEntity,calcResultVal,isCrit,hitConf)
    elseif hitConf.type == BattleDefine.HitType.energy then
        self:DoSkillHitEnergy(fromEntityUid,hitEntity,calcResultVal,isCrit,hitConf)
    end
    self.world.EventTriggerSystem:Trigger(BattleEvent.skill_hit,
        fromEntityUid,hitEntity.uid,args.skillId,args.skillLev,args.relUid,args.hitUid,hitConf.type,calcResultVal)
end

function BattleHitSystem:SkillLateCalcResultVal(hitConf,fromEntityUid,hitEntity,args,calcResultVal)
    local skill = args.skill
    local skillBaseConf = self.world.BattleConfSystem:SkillData_data_skill_base(args.skillId)
    local isCrit,critCalcResultVal = self:CheckCrit(calcResultVal,fromEntityUid,hitEntity,args)
    calcResultVal = critCalcResultVal

    local changeCalcResultVal = self.world.EventTriggerSystem:Trigger(BattleEvent.change_hit_result_val
        ,fromEntityUid,hitEntity.uid,hitConf.type,skill.uid,args.skillId,args.skillLev,args.relUid,args.hitUid,skillBaseConf.hit_dist_type,hitConf.dmg_type,calcResultVal)
    calcResultVal = changeCalcResultVal

    local doChangeCalcResultVal = self.world.EventTriggerSystem:Trigger(BattleEvent.change_do_hit_result_val
        ,fromEntityUid,hitEntity.uid,hitConf.type,skillBaseConf.hit_dist_type,hitConf.dmg_type,calcResultVal)
    calcResultVal = doChangeCalcResultVal

    --TODO 触发分摊伤害buff
    doChangeCalcResultVal = self.world.EventTriggerSystem:Trigger(BattleEvent.share_do_hit_result_val_in_range
        ,fromEntityUid,hitEntity.uid,hitConf.type,skillBaseConf.hit_dist_type,hitConf.dmg_type,calcResultVal)
    calcResultVal = doChangeCalcResultVal

    if hitConf.type == BattleDefine.HitType.dmg then
        local doAbsorbCalcResultVal = self.world.EventTriggerSystem:Trigger(BattleEvent.absorb_hit_dmg,fromEntityUid,hitEntity.uid,calcResultVal)
        calcResultVal = doAbsorbCalcResultVal
    end

    return calcResultVal
end


function BattleHitSystem:CheckCrit(calcResultVal,fromEntityUid,hitEntity,args)
    local isCrit = false

    local skill = args.skill

    local critInfo = {flag = false}
    self.world.EventTriggerSystem:Trigger(BattleEvent.skill_hit_check_crit,fromEntityUid,hitEntity.uid,skill.uid,args.skillId,args.skillLev,args.relUid,args.hitUid,critInfo)
    isCrit = critInfo.flag

    if not isCrit then
        local critRate = hitEntity.AttrComponent:GetValue(GDefine.Attr.crit_rate)
        if critRate >= BattleDefine.AttrRatio then
            isCrit = true
        else
            isCrit = self.world.BattleRandomSystem:Random(1,BattleDefine.AttrRatio) <= critRate
        end
    end

    if isCrit then
        local critDmgRatio = hitEntity.AttrComponent:GetValue(GDefine.Attr.crit_dmg)
        return true,FPMath.Divide(calcResultVal * critDmgRatio,BattleDefine.AttrRatio)
    else
        return false,calcResultVal
    end
end

function BattleHitSystem:CheckChange(fromEntityUid,hitEntity,args,calcResultVal)
    if hitConf.type == BattleDefine.HitType.dmg then
        --self:DoSkillDmg(fromEntityUid,hitEntity,calcResultVal)
    elseif hitConf.type == BattleDefine.HitType.heal then
        --self:DoSkillHeal(fromEntityUid,hitEntity,calcResultVal)
    end
    return calcResultVal
end

function BattleHitSystem:DoSkillDmg(fromEntityUid,hitEntity,dmgVal,isCrit,hitConf)
    hitEntity.HitComponent:HitDmgHp(dmgVal,isCrit)
    if hitConf and hitConf.show_fly_text == 1 then
        self.world.ClientIFacdeSystem:Call("SendEvent","FlyingTextView","ShowFlyingText",BattleDefine.FlyingText.hp,
            {value = -dmgVal,isCrit = isCrit,uid = hitEntity.uid})
    end
end

function BattleHitSystem:DoSkillHeal(fromEntityUid,hitEntity,healVal,isCrit,hitConf)
    hitEntity.HitComponent:HitHealHp(healVal,isCrit)
    if hitConf and hitConf.show_fly_text == 1 then
        self.world.ClientIFacdeSystem:Call("SendEvent","FlyingTextView","ShowFlyingText",BattleDefine.FlyingText.hp,
            {value = healVal,isCrit = isCrit,uid = hitEntity.uid})
    end
end

function BattleHitSystem:DoSkillHitEnergy(fromEntityUid,hitEntity,energyVal,isCrit,hitConf)
    hitEntity.HitComponent:HitEnergy(energyVal,isCrit)
    if hitConf and hitConf.show_fly_text == 1 then
        self.world.ClientIFacdeSystem:Call("SendEvent","FlyingTextView","ShowFlyingText",BattleDefine.FlyingText.energy,
            {value = energyVal,uid = hitEntity.uid})
    end
end

function BattleHitSystem:BuffHit(hitConf,fromEntityUid,hitEntity,args,calcResultVal)
    if hitConf.type == BattleDefine.HitType.dmg then
        self:DoBuffDmg(fromEntityUid,hitEntity,calcResultVal)
    elseif hitConf.type == BattleDefine.HitType.heal then
        self:DoBuffHeal(fromEntityUid,hitEntity,calcResultVal)
    elseif hitConf.type == BattleDefine.HitType.energy then
        self:DoBuffHitEnergy(fromEntityUid,hitEntity,calcResultVal)
    end
end

function BattleHitSystem:DoBuffDmg(fromEntityUid,hitEntity,dmgVal)
    hitEntity.HitComponent:HitDmgHp(dmgVal,false)
end

function BattleHitSystem:DoBuffHeal(fromEntityUid,hitEntity,healVal)
    hitEntity.HitComponent:HitHealHp(healVal)
end

function BattleHitSystem:DoBuffHitEnergy(fromEntityUid,hitEntity,energyVal)
    hitEntity.HitComponent:HitEnergy(energyVal)
end

function BattleHitSystem:OtherHit(hitConf,fromEntityUid,hitEntity,args,calcResultVal)
    if hitConf.type == BattleDefine.HitType.dmg then
        self:DoOtherDmg(fromEntityUid,hitEntity,calcResultVal)
    elseif hitConf.type == BattleDefine.HitType.heal then
        self:DoOtherHeal(fromEntityUid,hitEntity,calcResultVal)
    elseif hitConf.type == BattleDefine.HitType.energy then
        self:DoOtherHitEnergy(fromEntityUid,hitEntity,calcResultVal)
    end
end

function BattleHitSystem:DoOtherDmg(fromEntityUid,hitEntity,dmgVal)
    hitEntity.HitComponent:HitDmgHp(dmgVal,false)
    -- self.world.ClientIFacdeSystem:Call("SendEvent","FlyingTextView","ShowFlyingText",BattleDefine.FlyingText.hp,
    --     {value = -dmgVal,isCrit = false,uid = hitEntity.uid})
end

function BattleHitSystem:DoOtherHeal(fromEntityUid,hitEntity,healVal)
    hitEntity.HitComponent:HitHealHp(healVal)
end

function BattleHitSystem:DoOtherHitEnergy(fromEntityUid,hitEntity,energyVal)
    hitEntity.HitComponent:HitEnergy(energyVal)
end

function BattleHitSystem:ImmedDie(entity)
    if entity.StateComponent:IsState(BattleDefine.EntityState.die) then
        return
    end

    local hp = entity.AttrComponent:GetValue(BattleDefine.Attr.hp)
    entity.HitComponent:HitDmgHp(hp,false)

    self:CheckDie(BattleDefine.HitFrom.other,entity.uid,0,entity,nil)
end

function BattleHitSystem:CheckDie(hitFrom,fromEntityUid,hitFlag,hitEntity,args)
    if hitEntity.StateComponent:IsState(BattleDefine.EntityState.die) then
        return
    end

    local hp = hitEntity.AttrComponent:GetValue(BattleDefine.Attr.hp)
    if hp > 0 then
        return
    end

    hitEntity:CallClientComponentFunc("EffectComponent","CleanEffect")

    self.world.EventTriggerSystem:Trigger(BattleEvent.unit_ready_die,fromEntityUid,hitEntity.uid,hitFlag)

    if hitEntity.StateComponent:HasMarkState(BattleDefine.MarkState.delay_die) then
        return
    end

    hitEntity.StateComponent:SetState(BattleDefine.EntityState.die)

    self.world.PluginSystem.EntityFunc:RemoveEntityDisableComponent(hitEntity)

    self.world.ClientIFacdeSystem:Call("ForceActiveEntityTop",hitEntity.uid,false)

    if hitFrom == BattleDefine.HitFrom.skill then
        self.world.EventTriggerSystem:Trigger(BattleEvent.skill_kill_unit,fromEntityUid,hitEntity.uid,args.skillId,args.skillLev,args.hitUid)
	end

    self.world.EventTriggerSystem:Trigger(BattleEvent.unit_die,fromEntityUid,hitEntity.uid)

    self.world.ClientIFacdeSystem:Call("SendGuideEvent","PlayerGuideDefine","kill_unit",fromEntityUid,hitEntity.uid)
end

function BattleHitSystem:HitEntitys(fromUid,entitys,hitArgs,hitResultId,hitEffectId)
    self.hitNumUid = self.hitNumUid + 1
    local totalHitResult = 0
    for _,entityUid in ipairs(entitys) do
        local targetEntity = self.world.EntitySystem:GetEntity(entityUid)
        if targetEntity then
            self.world.BattleAssetsSystem:PlayHitEffect(entityUid,hitEffectId)
            local hitResult = self:HitResult(BattleDefine.HitFrom.skill,fromUid,targetEntity.uid,hitResultId,hitArgs,self.hitNumUid) or 0
            totalHitResult = totalHitResult + hitResult
        end
    end
    self.world.EventTriggerSystem:Trigger(BattleEvent.skill_hit_complete,fromUid,entitys,hitArgs.hitUid,totalHitResult)
end

function BattleHitSystem:CalcByAttr(hitConf,fromEntityUid,hitEntity)
    local resultVal = 0
    for i,v in ipairs(hitConf.hit_vals) do
        local attrType = BattleUtils.GetConfAttr(v.attr)
        if not attrType then
            assert(false,string.format("命中结算属性类型异常[命中Id:%s][属性:%s]",hitConf.id,tostring(v.attr)))
        end
        local value = self.world.PluginSystem.CalcAttr:CalcAttr(fromEntityUid,hitEntity.uid,v.mode,attrType,v)
        resultVal = resultVal + value
    end
    return resultVal,true
end

function BattleHitSystem:CalcByFixed(hitConf,fromEntityUid,hitEntity,args)
    local resultVal = self.world.PluginSystem.CalcAttr:CalcAttr(fromEntityUid,hitEntity.uid,"固定值",nil,hitConf.hit_vals[1])
    return resultVal,true
end

function BattleHitSystem:CalcBySeckill(hitConf,fromEntityUid,hitEntity,args)
    local resultVal = 99999
    return resultVal,false
end

function BattleHitSystem:CalcByArgsVal(hitConf,fromEntityUid,hitEntity,args)
    local resultVal = self.world.PluginSystem.CalcAttr:CalcVal(args.calcVal,hitConf.hit_vals[1],args.mode,args.factor,args)
    return resultVal,true
end

function BattleHitSystem:DoNotCalc(hitConf,fromEntityUid,hitEntity,args)
    return args.calcVal,false
end

function BattleHitSystem:CalcByCommanderAttr(hitConf,fromEntityUid,hitEntity)
    local resultVal = 0
    for i,v in ipairs(hitConf.hit_vals) do
        local attrType = BattleUtils.GetConfAttr(v.attr)
        local value = self.world.PluginSystem.CalcAttr:CalcCommanderAttr(fromEntityUid,hitEntity.uid,v.mode,attrType,v)
        resultVal = resultVal + value
    end
    return resultVal,true
end

function BattleHitSystem:CalcBySkillHitResult(hitConf,fromEntityUid,hitEntity,args)
    local resultVal = 0
    local entity = self.world.EntitySystem:GetEntity(fromEntityUid)
    local skill = entity.SkillComponent:GetSkill(args.skillId)
    local hitResult = skill:GetData(SkillDefine.DataKey.skill_hit_result)
    resultVal = self.world.PluginSystem.CalcAttr:CalcVal(hitResult,hitConf.hit_vals[1])
    return resultVal,true
end

function BattleHitSystem:CalcByBeHitValue(hitConf,fromEntityUid,hitEntity,args)
    local resultVal = 0
    local entity = self.world.EntitySystem:GetEntity(fromEntityUid)
    local skill = entity.SkillComponent:GetSkill(args.skillId)
    local hitResult = skill:GetData(SkillDefine.DataKey.be_hit_value)
    resultVal = self.world.PluginSystem.CalcAttr:CalcVal(hitResult,hitConf.hit_vals[1])
    return resultVal,true
end

function BattleHitSystem:AttachCoefByFixed(calcResultVal,attachCoef,fromEntityUid,hitEntity,args)
    if not attachCoef.coef then
        assert(false,"固定值附加系数为空")
    else
        local newVal = calcResultVal + attachCoef.coef
        return newVal
    end
end

function BattleHitSystem:AttachCoefByDistance(calcResultVal,attachCoef,fromEntityUid,hitEntity,args)
    local attrType = BattleUtils.GetConfAttr(attachCoef.attr)
    local attrValue = self.world.PluginSystem.CalcAttr:GetAttr(fromEntityUid,attrType,attachCoef.attrMode)
    local attrCoef = attrValue * attachCoef.coef

    local entity = self.world.EntitySystem:GetEntity(fromEntityUid)
    local skill = entity.SkillComponent:GetSkill(args.skillId)
    local relPos = skill:GetData(SkillDefine.DataKey.rel_pos)
    local hitPos = hitEntity.TransformComponent:GetPos()
    local dir = hitPos - relPos
    local dis = dir.magnitude
    local disCoef = dis * attrCoef

    local modifiedVal = FPMath.Divide(disCoef,BattleDefine.AttrRatio)

    local newVal = calcResultVal + modifiedVal

    local limitVal = calcResultVal * attachCoef.limitRate
    limitVal = FPMath.Divide(limitVal,BattleDefine.AttrRatio)
    if attachCoef.coef < 0 then  -- 衰减
        if newVal < calcResultVal - limitVal then
            newVal = calcResultVal - limitVal
        end
    elseif attachCoef.coef > 0 then  -- 增幅
        if newVal > calcResultVal + limitVal then
            -- Log("zzz<<< newVal"..newVal," calcResultVal"..calcResultVal.."+limitVal"..limitVal.."= "..calcResultVal + limitVal)
            newVal = calcResultVal + limitVal
        end
    end
    return newVal
end

function BattleHitSystem:AttachCoefByHitNum(calcResultVal,attachCoef,fromEntityUid,hitEntity,args)
    local fromEntity = self.world.EntitySystem:GetEntity(fromEntityUid)
    local skill = fromEntity.SkillComponent:GetSkill(args.skillId)
    local key = args.skillId.."_"..args.relUid
    local val = skill:GetData(key)
    local hitNum = val.hitNum
    local coef = attachCoef.coef
    local hitNumCoef = (hitNum - 1) * coef

    if math.abs(hitNumCoef) > attachCoef.limitRate then
        if coef < 0 then
            hitNumCoef = -attachCoef.limitRate
        else
            hitNumCoef = attachCoef.limitRate
        end
    end

    local modifiedVal = calcResultVal * hitNumCoef
    modifiedVal = FPMath.Divide(modifiedVal,BattleDefine.AttrRatio)

    local newVal = calcResultVal + modifiedVal

    return newVal
end

function BattleHitSystem:TargetBuffOverlay(calcResultVal,attachCoef,fromEntityUid,hitEntity,args)
    local buff = hitEntity.BuffComponent:GetBuffById(attachCoef.buffId)
    if not buff then
        return calcResultVal
    end

    local overlayNum = buff:GetOverlay()
    local modifiedVal = self.world.PluginSystem.CalcAttr:CalcVal(calcResultVal,attachCoef,nil,overlayNum)

    return calcResultVal + modifiedVal
end

function BattleHitSystem:AttachCoefByDebuffKindCount(calcResultVal,attachCoef,fromEntityUid,hitEntity,args)
    local debuffList = {}
    local conds = {
        buffId = 0,     -- -1 所有buff; 0不匹配buffID,进入下一级判断; 大于0 指定的buff
        kind = 0,       --  0 不匹配buff类型,进入下一级判断; 大于0 指定的buff类型
        resultType = 2, --  0 不匹配buff效果,进入下一级判断; 1 所有增益buff; 2 所有减益buff
        tag = 1,        --  指定的buffTag
        overlay = 0,    --  叠加层数  0 不检测
        overlayOp = ''
    }
    for iter in hitEntity.BuffComponent.buffList:Items() do
        local buff = hitEntity.BuffComponent:GetBuffByUid(iter.value)
        if self.world.PluginSystem.CheckCond:CheckBuff(buff,conds) then
            if not debuffList[buff.conf.kind] then
                debuffList[buff.conf.kind] = {}
            end
            table.insert(debuffList[buff.conf.kind],buff.uid)
        end
    end

    local count = #debuffList
    local modifiedVal = self.world.PluginSystem.CalcAttr:CalcVal(calcResultVal,attachCoef,nil,count)
    -- Log("zzz>>AttachCoefByDebuffKindCount>>>","count"..count,calcResultVal,modifiedVal)
    return calcResultVal + modifiedVal
end