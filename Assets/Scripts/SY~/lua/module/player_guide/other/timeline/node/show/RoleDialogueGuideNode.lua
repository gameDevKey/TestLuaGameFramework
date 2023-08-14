RoleDialogueGuideNode = BaseClass("RoleDialogueGuideNode",BaseGuideNode)

function RoleDialogueGuideNode:__Init()
    self.bubbleMsgGuideView = nil
    self.closeTimer = nil
end

function RoleDialogueGuideNode:OnStart()
    self:StartCloseTimer()
    self:ShowBubbleMsgGuideView()
end

function RoleDialogueGuideNode:OnDestroy()
    self:StopCloseTimer()
    self:RemoveBubbleMsgGuideView()
end

function RoleDialogueGuideNode:ShowBubbleMsgGuideView()
    self:RemoveBubbleMsgGuideView()
    self.bubbleMsgGuideView = RoleDialogueGuideView.New()
    local x,y = self:GetTargetPos()
    mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.AddChildView,self.bubbleMsgGuideView,self.actionParam,x,y)
end

function RoleDialogueGuideNode:RemoveBubbleMsgGuideView()
    if self.bubbleMsgGuideView then
        mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.RemoveChildView,self.bubbleMsgGuideView)
        self.bubbleMsgGuideView = nil
    end
end

function RoleDialogueGuideNode:StartCloseTimer()
    self:StopCloseTimer()
    if self.actionParam.closeTime and self.actionParam.closeTime > 0 then
        self.closeTimer = TimerManager.Instance:AddTimer(1,self.actionParam.closeTime,self:ToFunc("OnCloseTimer"))
    end
end

function RoleDialogueGuideNode:StopCloseTimer()
    if self.closeTimer then
        TimerManager.Instance:RemoveTimer(self.closeTimer)
        self.closeTimer = nil
    end
end

function RoleDialogueGuideNode:OnCloseTimer()
    self:StopCloseTimer()
    self:RemoveBubbleMsgGuideView()
end