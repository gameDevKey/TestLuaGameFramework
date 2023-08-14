BeginGroupFinishGuideNode = BaseClass("BeginGroupFinishGuideNode",BaseGuideNode)

function BeginGroupFinishGuideNode:__Init()
	self.eventUid = nil
end

function BeginGroupFinishGuideNode:OnStart()
	local eventParam = {}
	eventParam.group = self.actionParam.group
    self.eventUid = mod.PlayerGuideEventCtrl:AddListener(PlayerGuideDefine.Event.begin_group,self:ToFunc("OnEvent"),eventParam)
end

function BeginGroupFinishGuideNode:OnEvent(param)
	self:RemoveEvent()
	self.timeline:SetForceFinish(true)
end

function BeginGroupFinishGuideNode:OnDestroy()
    self:RemoveEvent()
end

function BeginGroupFinishGuideNode:RemoveEvent()
	if self.eventUid then
		mod.PlayerGuideEventCtrl:RemoveListener(self.eventUid)
		self.eventUid = nil
	end
end