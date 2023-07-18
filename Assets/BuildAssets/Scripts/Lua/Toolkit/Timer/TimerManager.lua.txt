TimerManager = SingletonClass("TimerManager")

function TimerManager:OnInit()
    self.time = 0
    self.tbAllTimer = ListMap.New()
    self.timerKeyGenerator = GetAutoIncreaseFunc()
end

function TimerManager:OnDelete()
    if self.tbAllTimer then
        self.tbAllTimer:Range(function (iter)
            iter.value:Delete()
        end)
        self.tbAllTimer:Delete()
        self.tbAllTimer = nil
    end
end

function TimerManager:AddTimer(callback, tickTime)
    local timerId = self.timerKeyGenerator()
    self.tbAllTimer:Add(timerId,Timer.New(timerId, callback, tickTime))
    return timerId
end

function TimerManager:RemoveTimer(timerId)
    self.tbAllTimer:Remove(timerId)
end

function TimerManager:Tick(deltaTime)
    self.deltaTime = deltaTime
    self.time = self.time + deltaTime
    self.tbAllTimer:Range(self.UpdateTimer,self)
end

function TimerManager:UpdateTimer(iter)
    if iter.value:Tick(self.deltaTime) then
        self:RemoveTimer(iter.key)
    end
end

return TimerManager
