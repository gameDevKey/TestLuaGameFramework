ScreenAnyClickGuideNode = BaseClass("ScreenAnyClickGuideNode",BaseGuideNode)

function ScreenAnyClickGuideNode:__Init()
    self.listenId = nil
end

function ScreenAnyClickGuideNode:OnInit()
    self.listenId = TouchManager.Instance:AddListen(TouchDefine.TouchEvent.begin,self:ToFunc("AnyClick"))
end

function ScreenAnyClickGuideNode:AnyClick()
    TouchManager.Instance:RemoveListen(self.listenId)
    self.listenId = nil
    self.timeline:SetForceFinish(true)
end

function ScreenAnyClickGuideNode:OnDestroy()
    if self.listenId then
        TouchManager.Instance:RemoveListen(self.listenId)
        self.listenId = nil
    end
end

function ScreenAnyClickGuideNode:OnAutoRun()
    self:OnAutoRunSuccess(false)
    self:AnyClick()
end