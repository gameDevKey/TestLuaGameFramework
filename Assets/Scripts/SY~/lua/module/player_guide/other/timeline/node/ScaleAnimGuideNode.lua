ScaleAnimGuideNode = BaseClass("ScaleAnimGuideNode",BaseGuideNode)

function ScaleAnimGuideNode:__Init()
    self.scaleAnimView = nil
end

function ScaleAnimGuideNode:OnStart()
    self:ShowView()
end

function ScaleAnimGuideNode:OnDestroy()
    self:RemoveView()
    self:RemoveCloseTimer()
end

function ScaleAnimGuideNode:OnCloseTimer()
    self.closeTimer = nil
    self:RemoveView()
end

function ScaleAnimGuideNode:ShowView()
    self:RemoveView()
    self.scaleAnimView = ScaleAnimGuideView.New()
    local x,y = self:GetTargetPos()
    mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.AddChildView,self.scaleAnimView,self.actionParam,x,y)

    if self.actionParam.closeTime and self.actionParam.closeTime > 0 then
        self.closeTimer = TimerManager.Instance:AddTimer(1,self.actionParam.closeTime,self:ToFunc("OnCloseTimer"))
    end
end

function ScaleAnimGuideNode:RemoveView()
    if self.scaleAnimView then
        mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.RemoveChildView,self.scaleAnimView)
        self.scaleAnimView = nil
    end
end

function ScaleAnimGuideNode:RemoveCloseTimer()
    if self.closeTimer then
        TimerManager.Instance:RemoveTimer(self.closeTimer)
        self.closeTimer = nil
    end
end