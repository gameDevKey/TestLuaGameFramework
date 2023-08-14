EventCond = BaseClass("EventCond",PassiveCondBase)

function EventCond:__Init()
	self.event = nil
end

function EventCond:OnInit()
	local event = SkillDefine.PasvCondEventIndex[self.passive.conf.condition["type"]]

	local eventParam = {}
	eventParam.entityUid = self.passive.entity.uid

	for k,v in pairs(self.passive.conf.condition) do
		local paramName = SkillDefine.PasvEventToParamName[k]
		if paramName then eventParam[paramName] = v end
	end

	if eventParam[SkillDefine.PasvEventToParamName.skillId] 
		and eventParam[SkillDefine.PasvEventToParamName.skillId] == -100 then
		eventParam[SkillDefine.PasvEventToParamName.skillId] = self.passive.skill.skillId
	end

	if eventParam[SkillDefine.PasvEventToParamName.hitFlags] then
		local params = {}
		for i,v in ipairs(eventParam[SkillDefine.PasvEventToParamName.hitFlags]) do
			params[v] = true
		end
		eventParam[SkillDefine.PasvEventToParamName.hitFlags] = params
	end

    self:AddEvent(event,self:ToFunc("OnEvent"),eventParam)
end

function EventCond:OnEvent(param)
	self:TriggerCond(param)
end