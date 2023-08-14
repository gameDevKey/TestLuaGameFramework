GuideKillUnitEventTrigger = BaseClass("GuideKillUnitEventTrigger",BaseGuideTrigger)

function GuideKillUnitEventTrigger:__Init()
    self.killNum = 0
end

function GuideKillUnitEventTrigger:OnInit()
	-- local event = PlayerGuideDefine.BattleTriggerEventIndex[self.triggerCond.type]

	-- local eventParam = {}

	-- local eventArgsIndexs = PlayerGuideDefine.BattleEventArgs[self.triggerCond.type]
	-- if eventArgsIndexs then
	-- 	for _,paramName in ipairs(eventArgsIndexs) do
	-- 		local paramVal = self.triggerCond[paramName]
	-- 		eventParam[paramName] = paramVal
	-- 	end
	-- end

	-- if self.triggerCond.roleUid then
	-- 	if self.triggerCond.roleUid == 1 then
	-- 		eventParam["roleUid"] = RunWorld.BattleDataSystem.roleUid
	-- 	end
	-- end

    local eventParam = {}
    eventParam.fromUnitId = self.triggerCond.fromUnitId
    eventParam.killUnitId = self.triggerCond.killUnitId
    self:AddEvent(PlayerGuideDefine.Event.kill_unit,self:ToFunc("OnEvent"),eventParam)
end

function GuideKillUnitEventTrigger:OnEvent(param)
    self.killNum = self.killNum + 1
    if self.killNum >= self.triggerCond.killNum then
        self:TriggerCond(param)
    end
end