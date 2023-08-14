TweenBase = BaseClass("TweenBase")

function TweenBase:__Init(...)
    self.onComplete = nil
    self.onCompleteArgs = nil
    self.onAfterComplete = nil
    self.onAfterCompleteArgs = nil
end

function TweenBase:__Delete()
    self:Kill()
end

function TweenBase:SetComplete(cb,args)
    self.onComplete = cb
    self.onCompleteArgs = args
end

function TweenBase:SetAfterComplete(cb,args)
    self.onAfterComplete = cb
    self.onAfterCompleteArgs = args
end

function TweenBase:CallComplete()
    if self.onComplete then
        self.onComplete(self.onCompleteArgs)
    end
    if self.onAfterComplete then
        self.onAfterComplete(self.onAfterCompleteArgs)
    end
end

function TweenBase:IsFinish()
    return false
end

function TweenBase:Play()
end

function TweenBase:Stop()
end

function TweenBase:Kill()
end

function TweenBase:OnPlay()
end

function TweenBase:OnStop()
end

function TweenBase:OnComplete()
end