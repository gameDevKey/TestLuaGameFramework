--新手引导Timeline，阻塞式运行，管理多个Clip
GuideTimeline = Class("GuideTimeline", GuideModuleBase)

function GuideTimeline:OnInit(unit, clips, triggerResult, callback)
    self.unit = unit
    self.clips = clips
    self.triggerResult = triggerResult
    self.callback = callback
    self.clipIndex = 0
    self.clipAmount = #self.clips
    PrintGuide("Timeline开始")
    self:NextClip()
end

function GuideTimeline:OnUpdate(deltaTime)
    if self.curClip then
        self.curClip:Update(deltaTime)
    end
end

function GuideTimeline:OnDelete()
    if self.curClip then
        self.curClip:Delete()
        self.curClip = nil
    end
end

function GuideTimeline:NextClip()
    if self.curClip then
        self.curClip:Delete()
        self.curClip = nil
    end
    self.clipIndex = self.clipIndex + 1
    if self.clipIndex > self.clipAmount then
        self:Finish()
        return
    end
    PrintGuide("进入下一个片段", self.clipIndex)
    local data = self.clips[self.clipIndex]
    self.curClip = self:CreateClip(data)
end

function GuideTimeline:CreateClip(data)
    local clip = GuideClip.New(self, data, self:ToFunc("NextClip"))
    clip:SetFacade(self.facade)
    clip:InitComplete()
    return clip
end

function GuideTimeline:Finish()
    PrintGuide("Timeline结束")
    _ = self.callback and self.callback()
end

return GuideTimeline
