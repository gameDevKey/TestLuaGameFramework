GuideEventTrigger = BaseClass("GuideEventTrigger",BaseGuideTrigger)

function GuideEventTrigger:__Init()
end

function GuideEventTrigger:OnInit()
	local event = PlayerGuideDefine.BattleTriggerEventIndex[self.triggerCond.type]

	local eventParam = {}

	local eventArgsIndexs = PlayerGuideDefine.BattleEventArgs[self.triggerCond.type]
	if eventArgsIndexs then
		for _,paramName in ipairs(eventArgsIndexs) do
			local paramVal = self.triggerCond[paramName]
			eventParam[paramName] = paramVal

			if IS_DEBUG then
				assert(paramVal ~= nil,string.format("触发器[%s]未配置字段[%s]",self.triggerCond.type,paramName))
			end
		end
	end

	if self.triggerCond.roleUid then
		if self.triggerCond.roleUid == 1 then
			eventParam["roleUid"] = RunWorld.BattleDataSystem.roleUid
		end
	end

    self:AddEvent(event,self:ToFunc("OnEvent"),eventParam)
end

function GuideEventTrigger:OnEvent(param)
	self:TriggerCond(param)
end