TweenParallelAnim = BaseClass("TweenParallelAnim",TweenBase)

---同时执行多个动画
---@param anims table List<TweenBase>
function TweenParallelAnim:__Init(anims)
    self.tbAnim = anims
    self.animNum = #self.tbAnim
    self.tbComplete = {}
    self.isComplete = false
    for i, anim in ipairs(self.tbAnim or {}) do
        anim:SetAfterComplete(self:ToFunc("OnComplete"),i)
    end
end

function TweenParallelAnim:__Delete()
end

function TweenParallelAnim:SetEase(ease)
    for _, tween in ipairs(self.tbAnim) do
        tween:SetEase(ease)
    end
    return self
end

function TweenParallelAnim:Play()
    self.tbComplete = {}
    self.isComplete = false
    for i, anim in ipairs(self.tbAnim or {}) do
        anim:Play()
    end
    self:OnPlay()
end

function TweenParallelAnim:Stop()
    for i, anim in ipairs(self.tbAnim or {}) do
        anim:Stop()
    end
    self:OnStop()
end

function TweenParallelAnim:Kill()
    for i, anim in ipairs(self.tbAnim or {}) do
        anim:Delete()
    end
end

function TweenParallelAnim:IsFinish()
    return self.isComplete
end

function TweenParallelAnim:OnComplete(index)
    self.tbComplete[index] = true
    if TableUtils.GetTableLength(self.tbComplete) == self.animNum then
        self.isComplete = true
        self:CallComplete()
    end
end