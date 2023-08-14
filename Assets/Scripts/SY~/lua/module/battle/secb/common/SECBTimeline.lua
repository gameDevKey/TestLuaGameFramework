SECBTimeline = BaseClass("SECBTimeline",SECBBase)

function SECBTimeline:__Init()
    self.actionFuncs = {}

    self.lockUid = 0
    self.lockNum = 0
    self.lockInfos = {}

    self.runTime = 0
    self.runIndex = 0
    self.isFinish = true

    self.rate = 10000
    

    self.conf = nil
    self.length = 0

    self.duration = nil

    self.onComplete = nil
end

function SECBTimeline:__Delete()

end

function SECBTimeline:SetHandler(handler)
    for key, funcName in pairs(handler or {}) do
        self.actionFuncs[key] = self:ToFunc(funcName)
    end
end

function SECBTimeline:Init(conf,...)
    self.conf = conf
    self.length = #conf.Event

    assert(conf.Duration,"SECBTimeline配置不存在持续时间")

    self:OnInit(...)
end

function SECBTimeline:IsFinish()
    return self.isFinish
end

function SECBTimeline:SetRate(rate)
    self.rate = rate
end

function SECBTimeline:Start(...)
    self.runTime = 0    
    self.runIndex = 1
    self.rate = 10000
    self.isFinish = false

    self:OnStart(...)

    self:Update(0)
end

function SECBTimeline:Update(deltaTime)
    if self.isFinish then
        return
    end

    deltaTime = FPMath.Divide(deltaTime * self.rate,10000)

    self.runTime = self.runTime + deltaTime

    while self.runIndex <= self.length do
        local info = self.conf.Event[self.runIndex]
        if self.runTime < info.time then
            break
        end

        self.runIndex = self.runIndex + 1
        self:DoActions(info.action)
    end

    self:CheckFinish() 
end

function SECBTimeline:DoActions(action)
    for _,v in ipairs(action) do
        local func = self.actionFuncs[v.type]
        assert(func, string.format("未知的Timeline行为类型[%s]",tostring(v.type)))
        func(v)
    end
end

function SECBTimeline:SetComplete(onComplete)
    self.onComplete = onComplete
end

function SECBTimeline:Lock()
    self.lockUid = self.lockUid + 1
    self.lockNum = self.lockNum + 1
    self.lockInfos[self.lockUid] = {}--可记录堆栈信息
    return self.lockUid
end

function SECBTimeline:Unlock(lockUid)
    if self.lockInfos[lockUid] then
        self.lockNum = self.lockNum - 1
        self.lockInfos[lockUid] = nil
        self:CheckFinish()
    end
end

function SECBTimeline:CheckFinish()
    if self.isFinish then
        return
    end

    local duration = self.duration or self.conf.Duration

    if self.runTime >= duration and self.lockNum <= 0 then
        self.isFinish = true
        if self.onComplete then
            self.onComplete()
        end
        self:OnFinish()
    end
end

function SECBTimeline:SetDuration(duration)
    self.duration = duration
end

function SECBTimeline:Abort()
    self.isFinish = true
    self:OnAbort()
end

function SECBTimeline:OnInit()
end

function SECBTimeline:OnStart()
end

function SECBTimeline:OnAbort()
end

function SECBTimeline:OnFinish()
end