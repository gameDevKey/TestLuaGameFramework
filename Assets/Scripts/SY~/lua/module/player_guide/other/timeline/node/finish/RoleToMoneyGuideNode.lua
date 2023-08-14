RoleToMoneyGuideNode = BaseClass("RoleToMoneyGuideNode",BaseGuideNode)

function RoleToMoneyGuideNode:__Init()
	self.eventUid = nil
end

function RoleToMoneyGuideNode:OnStart()
	local eventParam = {}
    eventParam.roleUid = RunWorld.BattleDataSystem.roleUid
	eventParam.toMoney = self.actionParam.toMoney
    self.eventUid = mod.PlayerGuideEventCtrl:AddListener(PlayerGuideDefine.Event.role_update_money,self:ToFunc("OnEvent"),eventParam)
end

function RoleToMoneyGuideNode:OnEvent(param)
	self:RemoveEvent()
	self.timeline:SetForceFinish(true)
end

function RoleToMoneyGuideNode:OnDestroy()
    self:RemoveEvent()
end

function RoleToMoneyGuideNode:RemoveEvent()
	if self.eventUid then
		mod.PlayerGuideEventCtrl:RemoveListener(self.eventUid)
		self.eventUid = nil
	end
end