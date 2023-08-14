ClickUnlockGridGuideNode = BaseClass("ClickUnlockGridGuideNode",ClickObjGuideNodeBase)

function ClickUnlockGridGuideNode:__Init()
    self.listenUid = nil
end

function ClickUnlockGridGuideNode:OnInit()
end

function ClickUnlockGridGuideNode:OnStart()
    self.listenUid = mod.PlayerGuideCtrl:ListenPointer(self:ToFunc("PointerDown"),nil,nil)
    self:CheckOpenTipsEffect()
end

function ClickUnlockGridGuideNode:PointerDown(pointerData,args)
    local clickObj = self:GetClickObj(pointerData)
    if clickObj then
        CustomUnityUtils.PointerDownHandler(clickObj,pointerData)
        self.timeline:SetForceFinish(true)
    else
        self:CreateTipsEffect()
    end 
end

function ClickUnlockGridGuideNode:PointerUp(pointerData,args)
    local clickObj = self:GetClickObj(pointerData)
    if clickObj then
        self.timeline:SetForceFinish(true)
    end
end

function ClickUnlockGridGuideNode:OnDestroy()
    if self.listenUid then
        mod.PlayerGuideCtrl:CancelListenPointer(self.listenUid)
        self.listenUid = nil
    end

    mod.BattleFacade:SendEvent(BattleSelectHeroView.Event.EnableTips,true)
end