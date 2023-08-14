CaptureBridgeBubbleMsgGuideNode = BaseClass("CaptureBridgeBubbleMsgGuideNode",BaseGuideNode)

function CaptureBridgeBubbleMsgGuideNode:__Init()
    self.bubbleMsgGuideView = nil
end

function CaptureBridgeBubbleMsgGuideNode:OnInit()
    local triggerArgs = self.timeline.guideAction.triggerArgs

    self.bubbleMsgGuideView = BubbleMsgGuideView.New()
    local x,y = self:GetTargetPos()

    -- local roadIndex = triggerArgs.roadIndex or self.actionParam.roadIndex

    -- if triggerArgs.roadIndex == 2 then
    --     x = -x
    -- end

    mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.AddChildView,self.bubbleMsgGuideView,self.actionParam,x,y)
end

function CaptureBridgeBubbleMsgGuideNode:OnDestroy()
    mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.RemoveChildView,self.bubbleMsgGuideView)
end