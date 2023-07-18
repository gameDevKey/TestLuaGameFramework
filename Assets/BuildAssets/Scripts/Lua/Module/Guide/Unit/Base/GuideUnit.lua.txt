--新手引导管理类，串通(监听器 --> 查找器 --> Timeline)
GuideUnit = Class("GuideUnit", GuideModuleBase)

function GuideUnit:OnInit(data, callback)
    self.data = data
    self.callback = callback
    if self.data.Listen and self.data.Listen.Type then
        self:CreateTrigger(
            EGuideModule.ListenMap[self.data.Listen.Type],
            self.data.Listen.Args
        )
    else
        self:FinishTrigger()
    end
end

function GuideUnit:OnUpdate(deltaTime)
    if self.trigger then
        self.trigger:Update(deltaTime)
    end
    if self.timeline then
        self.timeline:Update(deltaTime)
    end
end

function GuideUnit:OnDelete()
    self.passData = nil
    if self.trigger then
        self.trigger:Delete()
        self.trigger = nil
    end
    if self.timeline then
        self.timeline:Delete()
        self.timeline = nil
    end
end

function GuideUnit:CreateTrigger(type, args)
    PrintGuide("创建触发器 类型", type, "参数", args)
    self.trigger = _G[type].New(self, args, self:ToFunc("FinishTrigger"))
    self.trigger:SetFacade(self.facade)
    self.trigger:InitComplete()
end

function GuideUnit:FinishTrigger(result)
    PrintGuide("完成触发器", self.trigger._className)
    if self.trigger then
        self.trigger:Delete()
        self.trigger = nil
    end
    self:CreateTimeline(self.data.Clips, result)
end

function GuideUnit:CreateTimeline(clips, triggerResult)
    self.timeline = GuideTimeline.New(self, clips, triggerResult, self:ToFunc("FinishTimeline"))
    self.timeline:SetFacade(self.facade)
    self.timeline:InitComplete()
end

function GuideUnit:FinishTimeline()
    if self.timeline then
        self.timeline:Delete()
        self.timeline = nil
    end
    self:Finish()
end

function GuideUnit:Finish()
    _ = self.callback and self.callback(self)
end

return GuideUnit
