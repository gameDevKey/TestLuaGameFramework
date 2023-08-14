DelayGuideNode = BaseClass("DelayGuideNode",BaseGuideNode)

function DelayGuideNode:__Init()
    self.fallTime = nil
end

function DelayGuideNode:OnStar()
    self:Show()
end

function DelayGuideNode:OnInit()
    
end

function DelayGuideNode:__Show()
    
end