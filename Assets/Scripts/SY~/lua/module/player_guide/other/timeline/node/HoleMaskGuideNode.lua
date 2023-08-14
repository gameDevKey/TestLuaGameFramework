HoleMaskGuideNode = BaseClass("HoleMaskGuideNode",BaseGuideNode)

function HoleMaskGuideNode:OnInit()
end

function HoleMaskGuideNode:OnStart()
    local centerX,centerY = self:GetTargetPos()
    self.actionParam.centerX = centerX
    self.actionParam.centerY = centerY
    mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.ShowHoleMask,true,self.actionParam)
end

function HoleMaskGuideNode:OnDestroy()
    mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.ShowHoleMask,false)
end