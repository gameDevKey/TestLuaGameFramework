TimerManager = SingleClass("TimerManager")

function TimerManager:__Init( )
    self.uniqueId = 0
    self.nextFrameTimerList = List.New()
    self.timerList = List.New()
    self.timerDict = {}
    self.pushTimers = {}
end

--@count 次数，无限次则填0
--@time 单位：秒
function TimerManager:AddTimer(count,time,callback,timerId)
    local timer = self:GetTimer(timerId)
    if timer then return timer end
    local timer = self:CreateTimer(count,time,callback,timerId)
    self.timerList:Push(timer,timer.id)
    self.timerDict[timer.id] = timer
    return timer
end

function TimerManager:AddTimerByNextFrame(count,time,callback,timerId)
    local timer = self:GetTimer(timerId)
    if timer then return timer end
    local timer = self:CreateTimer(count,time,callback)
    self.nextFrameTimerList:Push(timer,timer.id)
    self.timerDict[timer.id] = timer
    return timer
end

function TimerManager:GetTimer(timerId)
    if not timerId then return nil end
    if not self.timerDict[timerId] then return nil end
    return self.timerDict[timerId]
end

function TimerManager:CreateTimer(count,time,callback,timerId)
    local timerAction = PoolManager.Instance:Pop(PoolType.class,TimerAction.poolKey) or TimerAction.New()
    timerAction:Init(count,time,callback)
    timerAction.id = timerId or self:GetUniqueId()
    return timerAction
end

function TimerManager:RemoveTimer(timer)
    if not timer or not self.timerDict[timer.id] then 
        return
    end

    local timerId = timer.id

    timer:SetCancel(true)

    self.timerDict[timerId] = nil

    if self.nextFrameTimerList:ExistIndex(timerId) then
        self.nextFrameTimerList:RemoveByIndex(timerId)
    elseif self.timerList:ExistIndex(timerId) then
        self.timerList:RemoveByIndex(timerId)
    end

    table.insert(self.pushTimers,timer)

    --PoolManager.Instance:Push(PoolType.class,TimerAction.poolKey,timer)
end

function TimerManager:RemoveTimerByGroup(group)
    for k,v in pairs(self.timerDict) do
        if v.group == group then self:RemoveTimer(v) end
    end
end

function TimerManager:CheckoukRemove(timer)
    if not self.removeTimerDict[timer.id] then return false end
    self.removeTimerDict[timer.id] = nil
    self.timerDict[timer.id] = nil
    return true
end

function TimerManager:RemoveAllTimer()
    for k,v in pairs(self.timerDict) do self:RemoveTimer(v) end
end

function TimerManager:Update(delta)
    local nowFrame = Time.frameCount
    for item in self.nextFrameTimerList:Items() do
        local timer = item.value
        if timer.createFrame ~= nowFrame then
            self.timerList:Push(timer,timer.id)
            self.nextFrameTimerList:Remove(item)
        end
    end

    for i=#self.pushTimers,1,-1 do
        PoolManager.Instance:Push(PoolType.class,TimerAction.poolKey,self.pushTimers[i])
        table.remove(self.pushTimers,i)
    end

    for item in self.timerList:Items() do 
        self:RunTimer(item.value,delta) 
    end
end

function TimerManager:RunTimer(timer,delta)
    if timer.cancel then 
        return 
    end

    local flag = timer:Run(delta)
    if not flag then
        self:RemoveTimer(timer)
    end
end

function TimerManager:GetUniqueId()
    self.uniqueId = self.uniqueId + 1
    return self.uniqueId
end
