TriggerGuideGuideNode = BaseClass("TriggerGuideGuideNode",BaseGuideNode)

function TriggerGuideGuideNode:__Init()
	self.eventUid = nil
end

function TriggerGuideGuideNode:OnStart()
    local guideIds = {}
    for _,v in ipairs(self.actionParam.guides) do
        guideIds[v] = true
    end

	local eventParam = {}
	eventParam.guideIds = guideIds
    self.eventUid = mod.PlayerGuideEventCtrl:AddListener(PlayerGuideDefine.Event.trigger_guide,self:ToFunc("OnEvent"),eventParam)
end

function TriggerGuideGuideNode:OnEvent(param)
	self:RemoveEvent()
	self.timeline:SetForceFinish(true)
end

function TriggerGuideGuideNode:OnDestroy()
    self:RemoveEvent()
end

function TriggerGuideGuideNode:RemoveEvent()
	if self.eventUid then
		mod.PlayerGuideEventCtrl:RemoveListener(self.eventUid)
		self.eventUid = nil
	end
end