AnimBaseTween = BaseClass("AnimBaseTween",AnimBase)
--采用 dotween
function AnimBaseTween:__Init()
    self.tween = nil

    self.ease = DG.Tweening.Ease.Linear

    self.delay = 0

    self.loopNum = 1
    self.loopType = DG.Tweening.LoopType.Restart

    self.timeScale = false
end

function AnimBaseTween:__Delete()
    
end

function AnimBaseTween:Play()
    if self.tween then
        self.tween:Play()
    else
        self.tween = self:OnTween()
        assert(self.tween ~= nil,"没有创建tween对象")
        if self.id then self.tween:SetId(self.id) end
        if self.delay > 0 then self.tween:SetDelay(self.delay) end
        if not self.timeScale then self.tween:SetUpdate(true) end

        self.tween:SetEase(self.ease)
        self.tween:SetLoops(self.loopNum, self.loopType)
        self.tween:OnComplete(self:ToFunc("OnComplete"))
    end
end

function AnimBaseTween:OnComplete()
    self.tween:Kill()
    self.tween = nil
    TimerManager.Instance:AddTimerByNextFrame(1,0,self:ToFunc("BaseComplete"))
end

function AnimBaseTween:SetTimeScale(flag)
    self.timeScale = flag
end

function AnimBaseTween:SetDelay(delay)
    self.delay = delay
    return self
end

function AnimBaseTween:SetEase(ease)
    if not ease then return end
    self.ease = ease
end

function AnimBaseTween:SetLoop(num,type)
    if num then self.loopNum = num end
    if type then self.loopType = type end
end

--停止播放
function AnimBaseTween:Stop()
    if not self.tween then return end
    self.tween:Pause()
end

--还未播放完成,才能生效
function AnimBaseTween:Reset()
    if not self.tween then return end
    self.tween:Rewind()
end

function AnimBaseTween:Clean()
    if not self.tween then return end
    self.tween:Pause()
    self.tween:Kill()
    self.tween = nil
end

--重新启动,还未播放完成,才能生效
function AnimBaseTween:Restart(includeDelay,changeDelayTo)
    if not self.tween then return end
    self.tween:Restart(includeDelay or true,changeDelayTo or -1)
end

--配置创建会调用
function AnimBaseTween:BaseCreate(animData)
    self:SetEase(animData.ease or DG.Tweening.Ease.Linear)
    self:SetDelay(animData.delay or 0)
    self:SetLoop(animData.loopNum or 1,animData.loopType or DG.Tweening.LoopType.Restart)
    self:SetTimeScale(animData.timeScale or false)
end

function AnimBaseTween:OnTween() end