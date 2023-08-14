ScrollGuideNode = BaseClass("ScrollGuideNode",BaseGuideNode)

function ScrollGuideNode:__Init()
end

function ScrollGuideNode:OnStart()
    if self.actionParam.tag == "backpack" then
        mod.BackpackFacade:SendEvent(BackpackCardView.Event.ScrollTo, self.actionParam.y, self.actionParam.time, self:ToFunc("OnScrollFinish"))
    end
end

function ScrollGuideNode:OnScrollFinish()
    self.timeline:SetForceFinish(true)
end

function ScrollGuideNode:OnDestroy()
end