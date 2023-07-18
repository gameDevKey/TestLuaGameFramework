Timer = Class("Timer")

function Timer:OnInit(timerId, callback, tickTime)
    self.timerId = timerId
    self.callback = callback
    self.tickTime = tickTime
    self.timeCounter = 0
end

function Timer:OnDelete()
end

function Timer:Tick(deltaTime)
    if not self.callback then
        return true
    end
    self.timeCounter = self.timeCounter + deltaTime
    if self.timeCounter >= self.tickTime then
        self.timeCounter = 0
        return self.callback()
    end
end

return Timer
