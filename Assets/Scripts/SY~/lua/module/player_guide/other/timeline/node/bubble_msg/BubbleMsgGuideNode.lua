BubbleMsgGuideNode = BaseClass("BubbleMsgGuideNode",BaseGuideNode)

function BubbleMsgGuideNode:__Init()
    self.bubbleMsgGuideView = nil
    self.closeTimer = nil
end

function BubbleMsgGuideNode:OnInit()
    self.bubbleMsgGuideView = BubbleMsgGuideView.New()
    local x,y = self:GetTargetPos()
    mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.AddChildView,self.bubbleMsgGuideView,self.actionParam,x,y)

    if self.actionParam.closeTime and self.actionParam.closeTime > 0 then
        self.closeTimer = TimerManager.Instance:AddTimer(1,self.actionParam.closeTime,self:ToFunc("OnCloseTimer"))
    end
end

function BubbleMsgGuideNode:OnCloseTimer()
    self.closeTimer = nil
    self:RemoveBubbleMsgGuideView()
end

function BubbleMsgGuideNode:OnDestroy()
    self:RemoveCloseTimer()
    self:RemoveBubbleMsgGuideView()
end

function BubbleMsgGuideNode:RemoveBubbleMsgGuideView()
    if self.bubbleMsgGuideView then
        mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.RemoveChildView,self.bubbleMsgGuideView)
        self.bubbleMsgGuideView = nil
    end
end

function BubbleMsgGuideNode:RemoveCloseTimer()
    if self.closeTimer then
        TimerManager.Instance:RemoveTimer(self.closeTimer)
        self.closeTimer = nil
    end
end