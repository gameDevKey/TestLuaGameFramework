TauntPrioritySelectBuffBehavior = BaseClass("TauntPrioritySelectBuffBehavior",BuffBehavior)

function TauntPrioritySelectBuffBehavior:__Init()
end

function TauntPrioritySelectBuffBehavior:__Delete()
end

function TauntPrioritySelectBuffBehavior:OnInit()
    local eventParam = {}
    eventParam.entityUid = self.entity.uid

    self:AddEvent(BattleEvent.priority_select_unit,self:ToFunc("OnEvent"),eventParam)
    self:AddEvent(BattleEvent.try_to_rel_skill,self:ToFunc("OnTryToRelSkill"),eventParam)
end

function TauntPrioritySelectBuffBehavior:OnEvent(args)
    if args.entityDict[self.buff.fromEntityUid] then
        return self.buff.fromEntityUid
    end

    return nil
end

function TauntPrioritySelectBuffBehavior:OnTryToRelSkill(args)
    return args.skill.baseConf.type ~= SkillDefine.SkillType.normal_atk
end

function TauntPrioritySelectBuffBehavior:OnDestroy()

end