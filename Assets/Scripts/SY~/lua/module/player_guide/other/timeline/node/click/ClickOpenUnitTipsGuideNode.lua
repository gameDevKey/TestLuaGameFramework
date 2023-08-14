ClickOpenUnitTipsGuideNode = BaseClass("ClickOpenUnitTipsGuideNode",ClickObjGuideNodeBase)

function ClickOpenUnitTipsGuideNode:__Init()
    self.eventUid = nil
    self.listenUid = nil
end

function ClickOpenUnitTipsGuideNode:OnInit()
    local eventParam = {}
    self.eventUid = mod.PlayerGuideEventCtrl:AddListener(PlayerGuideDefine.Event.open_unit_tips,self:ToFunc("OnEvent"),eventParam)
end

function ClickOpenUnitTipsGuideNode:OnStart()
    self.listenUid = mod.PlayerGuideCtrl:ListenPointer(self:ToFunc("PointerDown"),nil,nil)

    mod.BattleFacade:SendEvent(BattleSelectHeroView.Event.EnableSelect,false)

    self:CheckOpenTipsEffect()
end

function ClickOpenUnitTipsGuideNode:PointerDown(pointerData,args)
    local clickObj = self:GetClickObj(pointerData)
    if clickObj then
        CustomUnityUtils.PointerDownHandler(clickObj,pointerData)
    else
        self:CreateTipsEffect()
    end
end

function ClickOpenUnitTipsGuideNode:OnEvent(param)
	self:RemoveEvent()
	self.timeline:SetForceFinish(true)
end

function ClickOpenUnitTipsGuideNode:RemoveEvent()
	if self.eventUid then
		mod.PlayerGuideEventCtrl:RemoveListener(self.eventUid)
		self.eventUid = nil
	end
end

function ClickOpenUnitTipsGuideNode:OnDestroy()
    if self.listenUid then
        mod.PlayerGuideCtrl:CancelListenPointer(self.listenUid)
        self.listenUid = nil
    end
    
    mod.BattleFacade:SendEvent(BattleSelectHeroView.Event.EnableSelect,true)
end