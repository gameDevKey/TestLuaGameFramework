TweenAnimBase = BaseClass("TweenAnimBase",TweenBase)

local tunpack = unpack or table.unpack

function TweenAnimBase:__Init(...)
    self.creatArgs = {...}
    self.tween = nil
    self.ease = nil
end

function TweenAnimBase:__Delete()
end

function TweenAnimBase:SetEase(ease)
    self.ease = ease
    return self
end

function TweenAnimBase:Play()
    if not self.tween then
        self.tween = self:OnCreate(tunpack(self.creatArgs))
        if self.tween then
            if self.ease then
                self.tween:SetEase(self.ease)
            end
            self.tween:SetComplete(self:ToFunc("OnComplete"))
        end
    end

    if not self:CheckValid("播放动画失败") then
        return
    end

    self:Stop()
    if self.tween:Play() then
        self:OnPlay()
        self.tween:Update(0)
    end
end

function TweenAnimBase:Stop()
    if not self:CheckValid("停止动画失败") then
        return
    end
    if self.tween:Stop() then
        self:OnStop()
    end
end

function TweenAnimBase:Kill()
    if self.tween then
        self.tween:Kill()
        self.tween = nil
    end
end

function TweenAnimBase:IsFinish()
    if not self.tween then
        return false
    end
    return self.tween:IsFinish()
end

function TweenAnimBase:GetCurrentTime()
    if not self.tween then
        return 0
    end
    return self.tween:GetCurrentTime()
end

function TweenAnimBase:CheckValid(tips)
    if not self.tween then
        LogErrorAny(tips,"原因是Tween实例化失败 =>",self.__className)
        return false
    end
    return true
end



--#region 虚方法

function TweenAnimBase:OnCreate(...)
    LogErrorAny("未实现OnCreate函数",self.__className)
    return nil
end

function TweenAnimBase:OnPlay()
    DOTweenUpdater.Instance:AddUpdateItem(self.tween)
end

function TweenAnimBase:OnStop()
    DOTweenUpdater.Instance:RemoveUpdateItem(self.tween)
end

function TweenAnimBase:OnComplete()
    DOTweenAnimFactory.PushAnim(self.tween)
    self:CallComplete()
    self.tween = nil
end

--#endregion