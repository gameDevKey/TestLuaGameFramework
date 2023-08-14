SkillSwitchHitTargetCond = BaseClass("SkillSwitchHitTargetCond",PassiveCondBase)

function SkillSwitchHitTargetCond:__Init()
    self.lastTargetUid = 0
end

function SkillSwitchHitTargetCond:OnInit()
	local eventParam = {}
	eventParam.entityUid = self.passive.entity.uid
    eventParam.skillId = self.passive.conf.condition["skillId"]
    self:AddEvent(BattleEvent.skill_hit,self:ToFunc("OnEvent"),eventParam)
end

function SkillSwitchHitTargetCond:OnEvent(param)
    local lastTargetUid = self.lastTargetUid
    self.lastTargetUid = param.targetEntityUids[1]
    if lastTargetUid ~= 0 and lastTargetUid ~= self.lastTargetUid then
        self:TriggerCond(param)
    end
end