TimerAction = BaseClass("TimerAction")
TimerAction.poolKey = "timer_action"
TimerAction.NOT_CLEAR = true

function TimerAction:__Init()
    self.id = nil
    self.leftTime = 0.0
    self.count = nil
    self.time = nil
    self.callback = nil
    self.args = nil
    self.onComplete = nil
    self.completeArgs = nil
    self.loop = nil
    self.clearOffset = true
    self.curTime = nil
    self.createFrame = 0
    self.runCount = 0
    self.cancel = true
    self.runError = false
end

function TimerAction:Init(count,time,callback)
    self.count = count or 0
    self.time = time or 0
    self.callback = callback
    self.loop = self.count <= 0
    --self.debug = debug.traceback()
    self.createFrame = Time.frameCount
    self.cancel = false
    self.isScale = false
end

function TimerAction:SetArgs(args)
    self.args = args
end

function TimerAction:SetDelay(delayTime)
    self.leftTime = -1 * delayTime
end

function TimerAction:SetClearOffset(clearOffset)
    self.clearOffset = clearOffset
end

function TimerAction:SetGroup(group)
    self.group = group
end

function TimerAction:SetScale(flag)
    self.isScale = flag
end

function TimerAction:SetComplete(func,args)
    self.onComplete = func
    self.completeArgs = args
end

function TimerAction:Run(delta)
    if not self.callback or self.runError or self.cancel then
        return false 
    end
    delta = self:unDeltaScale(delta)
    if not self:isExecute(delta) then return true end
    if not self.loop then self.count = self.count - 1 end
    local isFinish = not self.loop and self.count <= 0
    self.runCount = self.runCount + 1
    self.runError = true
    self.callback(self.args,isFinish,self.runCount,self.id)
    if isFinish and self.onComplete then
        self.onComplete(self.completeArgs,self.id)
    end
    self.runError = false
    return not isFinish
end

function TimerAction:unDeltaScale(delta)
    if self.isScale then 
        return delta
    else
        return Time.unscaledDeltaTime
    end
end

function TimerAction:isExecute(delta)
    self.leftTime = self.leftTime + delta
    if self.leftTime < self.time then return false end
    self.leftTime = self.clearOffset and 0 or self.leftTime - self.time
    return true
end

function TimerAction:RunCallback()
    if not self.callback or self.runError or self.cancel then return end
    self.callback(self.args)
end

function TimerAction:SetCancel(flag)
    self.cancel = flag
end

function TimerAction:OnReset()
    self.id = nil
    self.leftTime = 0.0
    self.count = nil
    self.time = nil
    self.callback = nil
    self.args = nil
    self.onComplete = nil
    self.completeArgs = nil
    self.loop = nil
    self.clearOffset = true
    self.curTime = nil
    self.createFrame = 0
    self.runCount = 0
    self.cancel = true
    self.runError = false
end
