InputSkillRelCritBuffBehavior = BaseClass("InputSkillRelCritBuffBehavior",BuffBehavior)

function InputSkillRelCritBuffBehavior:__Init()
    self.skillRelUids = {}
end

function InputSkillRelCritBuffBehavior:__Delete()
end

function InputSkillRelCritBuffBehavior:OnInit()
    local eventParam = {}
    eventParam.entityUid = self.entity.uid
    eventParam.hitUid = 0
    eventParam.skillId = 0

    self:AddEvent(BattleEvent.skill_hit_check_crit,self:ToFunc("OnEvent"),eventParam)
end

function InputSkillRelCritBuffBehavior:AddSkillRelUid(skillUid,relUid)
    if not self.skillRelUids[skillUid] then
        self.skillRelUids[skillUid] = {}
    end
    self.skillRelUids[skillUid][relUid] = true
end

function InputSkillRelCritBuffBehavior:OnEvent(args)
    if self.skillRelUids[args.skillUid] and self.skillRelUids[args.skillUid][args.relUid] then
        args.critInfo.flag = true
    end
end