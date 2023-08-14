ClickObjGuideNodeBase = BaseClass("ClickObjGuideNodeBase",BaseGuideNode)

function ClickObjGuideNodeBase:__Init()
    self.tipsEffect = nil
    self.tipsTimer = nil
end

function ClickObjGuideNodeBase:__Delete()
    if self.tipsEffect then
        self.tipsEffect:Delete()
        self.tipsEffect = nil
    end

    if self.tipsTimer then
        TimerManager.Instance:RemoveTimer(self.tipsTimer)
        self.tipsTimer = nil
    end
end


function ClickObjGuideNodeBase:GetClickObj(pointerData)
    if not self.timeline.targetArgs.targetObj then
        assert(false,string.format("不存在要点击的对象[引导Id:%s]",self.timeline.guideAction.guideId))
    end

    local raycastResults = CS.System.Collections.Generic.List(RaycastResult)()
    EventSystem.current:RaycastAll(pointerData,raycastResults)

    local clickObj = nil
    for i = 0, raycastResults.Count - 1 do
        local raycastObj = raycastResults[i].gameObject
        if self.timeline.targetArgs.targetObj == raycastObj then
            clickObj = raycastObj
            break
        end
    end

    return clickObj
end


function ClickObjGuideNodeBase:CheckOpenTipsEffect()
    local time = self.actionParam.tipsDelayTime
    if not time or time <= 0 then
        self:CreateTipsEffect()
    else
        self.tipsTimer = TimerManager.Instance:AddTimer(1,time,self:ToFunc("TipsTimer"))
    end
end


function ClickObjGuideNodeBase:TipsTimer()
    self.tipsTimer = nil
    self:CreateTipsEffect()
end


function ClickObjGuideNodeBase:CreateTipsEffect()
    if self.tipsEffect then
        return
    end
    local id = self.actionParam.tipsEffectId
    if not id or id == 0 then
        return
    end

    local x,y = self:GetTargetPos()

    local setting = {}
    setting.confId = id
    setting.parent = PlayerGuideDefine.contentTrans
    setting.order = ViewDefine.Layer["PlayerGuideView_Effect"]

	self.tipsEffect = UIEffect.New()
    self.tipsEffect:Init(setting)
    self.tipsEffect:SetPos(x,y)
    self.tipsEffect:Play()
end


function ClickObjGuideNodeBase:OnAutoRun()
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
    self:OnAutoRunSuccess(true)
end