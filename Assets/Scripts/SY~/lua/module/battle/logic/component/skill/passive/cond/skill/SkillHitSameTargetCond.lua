SkillHitSameTargetCond = BaseClass("SkillHitSameTargetCond",PassiveCondBase)

function SkillHitSameTargetCond:__Init()
    self.lastTargetUid = 0
end

function SkillHitSameTargetCond:OnInit()
	local eventParam = {}
	eventParam.entityUid = self.passive.entity.uid
    eventParam.skillId = self.passive.conf.condition["skillId"]
    self:AddEvent(BattleEvent.skill_hit,self:ToFunc("OnEvent"),eventParam)
end

function SkillHitSameTargetCond:OnEvent(param)
    local lastTargetUid = self.lastTargetUid
    self.lastTargetUid = param.targetEntityUids[1]
    if lastTargetUid ~= 0 and lastTargetUid == self.lastTargetUid then
        self:TriggerCond(param)
    end
end