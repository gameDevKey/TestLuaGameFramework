TweenSequenceAnim = BaseClass("TweenSequenceAnim",TweenBase)

---先后执行多个动画
---@param anims table List<TweenBase>
function TweenSequenceAnim:__Init(anims)
    self.tbAnim = anims
    self.animNum = #self.tbAnim
    self.animIndex = 1
    self.isComplete = false
    for i, anim in ipairs(self.tbAnim or {}) do
        anim:SetAfterComplete(self:ToFunc("OnComplete"),i)
    end
end

function TweenSequenceAnim:__Delete()
end

function TweenSequenceAnim:SetEase(ease)
    for _, tween in ipairs(self.tbAnim) do
        tween:SetEase(ease)
    end
    return self
end

function TweenSequenceAnim:Play()
    self.animIndex = 1
    self.tbAnim[self.animIndex]:Play()
    self:OnPlay()
end

function TweenSequenceAnim:Stop()
    self.tbAnim[self.animIndex]:Stop()
    self:OnStop()
end

function TweenSequenceAnim:Kill()
    for i, anim in ipairs(self.tbAnim or {}) do
        anim:Delete()
    end
end

function TweenSequenceAnim:IsFinish()
    return self.isComplete
end

function TweenSequenceAnim:OnComplete(index)
    if self.animIndex == self.animNum then
        self.isComplete = true
        self:CallComplete()
        return
    end
    self.animIndex = self.animIndex + 1
    self.tbAnim[self.animIndex]:Play()
end