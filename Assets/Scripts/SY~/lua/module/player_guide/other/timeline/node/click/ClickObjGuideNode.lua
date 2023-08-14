ClickObjGuideNode = BaseClass("ClickObjGuideNode",ClickObjGuideNodeBase)

function ClickObjGuideNode:__Init()
    self.tipsTimer = nil
    self.tipsEffect = nil
    self.listenUid = nil
end

function ClickObjGuideNode:OnStart()
    self.listenUid = mod.PlayerGuideCtrl:ListenPointer(nil,nil,self:ToFunc("PointerClick"))
    self:CheckOpenTipsEffect()
end

function ClickObjGuideNode:PointerClick(pointerData,args)
    local clickObj = self:GetClickObj(pointerData)
    if clickObj then
        CustomUnityUtils.PointerClickHandler(clickObj,pointerData)
        self.timeline:SetForceFinish(true)
    else
        self:OnClickOtherArea()
    end
end

function ClickObjGuideNode:CreateTimeline(id)
    local actConf = Config["PlayerGuide"..tostring(id)]
    assert(actConf,string.format("找不到引导行为配置[引导Id:%s]",id))
    local guideTimeline = GuideTimeline.New()
    guideTimeline:Init(actConf)
    guideTimeline:Start()
    return guideTimeline
end

function ClickObjGuideNode:OnClickOtherArea()
    self:CreateTipsEffect()
    for _, timelineId in ipairs(self.actionParam.clickOther or {}) do
       self:CreateTimeline(timelineId)
    end
    --内置逻辑，当点击了目标区域外的地方，重新执行之前执行过的scale_anim，后面可以扩展一下
    self:RestartAction("scale_anim")
end

function ClickObjGuideNode:RestartAction(tpe)
    self.timeline:RestartNode(tpe)
end

function ClickObjGuideNode:OnDestroy()
    if self.listenUid then
        mod.PlayerGuideCtrl:CancelListenPointer(self.listenUid)
        self.listenUid = nil
    end
end