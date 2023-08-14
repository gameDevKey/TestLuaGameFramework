LockScreenGuideNode = BaseClass("LockScreenGuideNode",BaseGuideNode)

function LockScreenGuideNode:__Init()
    self.lockScreenUid = nil
end

function LockScreenGuideNode:OnInit()
    --mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.LockScreen,self.actionParam.flag)
    self.lockScreenUid = mod.PlayerGuideCtrl:LockScreen()
end

function LockScreenGuideNode:OnDestroy()
    --mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.LockScreen,not self.actionParam.flag)
    if self.lockScreenUid then
        mod.PlayerGuideCtrl:CancelLockScreen(self.lockScreenUid)
        self.lockScreenUid = nil
    end
end