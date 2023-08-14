AnyClickBubbleMsgGuideNode = BaseClass("AnyClickBubbleMsgGuideNode",BaseGuideNode)

function AnyClickBubbleMsgGuideNode:__Init()
    self.bubbleMsgGuideView = nil
    self.bubbleViewTimer = nil
    self.listenId = nil
end

function AnyClickBubbleMsgGuideNode:OnInit()
    self.listenId = TouchManager.Instance:AddListen(TouchDefine.TouchEvent.begin,self:ToFunc("AnyClick"))
end

function AnyClickBubbleMsgGuideNode:AnyClick()
    if not self.bubbleViewTimer then
        self:CreateBubbleMsgView()
        self.bubbleViewTimer = TimerManager.Instance:AddTimer(1,self.actionParam.showTime,self:ToFunc("BubbleViewTimer"))
    end
end

function AnyClickBubbleMsgGuideNode:CreateBubbleMsgView()
    self.bubbleMsgGuideView = BubbleMsgGuideView.New()
    local x,y = self:GetTargetPos()
    mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.AddChildView,self.bubbleMsgGuideView,self.actionParam,x,y)
end

function AnyClickBubbleMsgGuideNode:BubbleViewTimer()
    self.bubbleViewTimer = nil
    self:RemoveBubbleView()
end

function AnyClickBubbleMsgGuideNode:RemoveBubbleView()
    if self.bubbleMsgGuideView then
        mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.RemoveChildView,self.bubbleMsgGuideView)
        self.bubbleMsgGuideView = nil
    end
end

function AnyClickBubbleMsgGuideNode:OnDestroy()
    if self.listenId then
        TouchManager.Instance:RemoveListen(self.listenId)
        self.listenId = nil
    end

    if self.bubbleViewTimer then
        TimerManager.Instance:RemoveTimer(self.bubbleViewTimer)
        self.bubbleViewTimer = nil
    end

    self:RemoveBubbleView()
end

function AnyClickBubbleMsgGuideNode:OnAutoRun()
    self:OnAutoRunSuccess(false)
    self:AnyClick()
end