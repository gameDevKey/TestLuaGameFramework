ClickRandomUnitGuideNode = BaseClass("ClickRandomUnitGuideNode",ClickObjGuideNodeBase)

function ClickRandomUnitGuideNode:__Init()
    self.listenUid = nil
end

function ClickRandomUnitGuideNode:OnInit()
end

function ClickRandomUnitGuideNode:OnStart()
    self.listenUid = mod.PlayerGuideCtrl:ListenPointer(self:ToFunc("PointerDown"),self:ToFunc("PointerUp"),nil)

    mod.BattleFacade:SendEvent(BattleSelectHeroView.Event.EnableTips,false)

    self:CheckOpenTipsEffect()
end

function ClickRandomUnitGuideNode:PointerDown(pointerData,args)
    local clickObj = self:GetClickObj(pointerData)
    if clickObj then
        CustomUnityUtils.PointerDownHandler(clickObj,pointerData)
    else
        self:CreateTipsEffect()
    end 
end

function ClickRandomUnitGuideNode:PointerUp(pointerData,args)
    local clickObj = self:GetClickObj(pointerData)
    if clickObj then
        self.timeline:SetForceFinish(true)
    end 
end


function ClickRandomUnitGuideNode:OnDestroy()
    if self.listenUid then
        mod.PlayerGuideCtrl:CancelListenPointer(self.listenUid)
        self.listenUid = nil
    end

    mod.BattleFacade:SendEvent(BattleSelectHeroView.Event.EnableTips,true)
end

function ClickRandomUnitGuideNode:OnAutoRun()
    local obj = self.timeline.targetArgs.targetObj
    if not obj then
        self:OnAutoRunFailed("未找到目标引导位置")
        return
    end
    local data = PointerEventData(EventSystem.current)
    data.pointerId = 1
    CustomUnityUtils.PointerDownHandler(obj, data)
    CustomUnityUtils.PointerUpHandler(obj, data)
    CustomUnityUtils.PointerClickHandler(obj, data)

    local pos = BaseUtils.WorldToScreenPoint(UIDefine.uiCamera,obj.transform.position)
    local cancelData = {}
    cancelData.fingerId = 1
	cancelData.pos = pos
	cancelData.beginPos = pos
	TouchManager.Instance:NoticeListen(TouchDefine.TouchEvent.cancel,cancelData)

    self:OnAutoRunSuccess(true)
end