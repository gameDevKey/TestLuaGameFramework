InputSkillRelChangeHitResultBuffBehavior = BaseClass("InputSkillRelChangeHitResultBuffBehavior",BuffBehavior)

function InputSkillRelChangeHitResultBuffBehavior:__Init()
    self.skillRelInfos = {}
end

function InputSkillRelChangeHitResultBuffBehavior:__Delete()

end

function InputSkillRelChangeHitResultBuffBehavior:OnInit()
    local eventParam = {}
    eventParam.entityUid = self.entity.uid
    eventParam.skillId = 0
    eventParam.hitUid = 0

    self:AddEvent(BattleEvent.change_hit_result_val,self:ToFunc("OnEvent"),eventParam)
end

function InputSkillRelChangeHitResultBuffBehavior:AddSkillRelInfo(skillUid,relUid,inputParam)
    if not self.skillRelInfos[skillUid] then
        self.skillRelInfos[skillUid] = {}
    end
    self.skillRelInfos[skillUid][relUid] = inputParam
end


function InputSkillRelChangeHitResultBuffBehavior:OnEvent(args)
    if not self.skillRelInfos[args.skillUid] or not self.skillRelInfos[args.skillUid][args.relUid] then
        return
    end

    local inputParam = self.skillRelInfos[args.skillUid][args.relUid]


    if args.hitType ~= BattleDefine.ConfHitType[inputParam.hitType] then
        return 0
    end

    if inputParam.hitDisType ~= 0 and args.hitDisType ~= inputParam.hitDisType then
        return 0
    end

    local value = self.world.PluginSystem.CalcAttr:CalcVal(args.curCalcResultVal,inputParam)
    return value
end

function InputSkillRelChangeHitResultBuffBehavior:OnDestroy()

end