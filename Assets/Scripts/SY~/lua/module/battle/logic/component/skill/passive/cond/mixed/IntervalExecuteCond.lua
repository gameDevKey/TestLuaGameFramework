IntervalExecuteCond = BaseClass("IntervalExecuteCond",PassiveCondBase)

function IntervalExecuteCond:__Init()
    self.execIndex = 1
    self.timer = 0
    self.enable = false
end

function IntervalExecuteCond:OnInit()
    self.execIndex = 1
    self.timer = 0
    self.enable = true
    self.times = self.passive.conf.condition.times
    self.timeLen = #self.times
end

function IntervalExecuteCond:OnUpdate()
    if not self.enable then
        return
    end
    if self.passive:MaxExecNum() then
        self.enable = false
        return
    end
    self.timer = self.timer + self.world.opts.frameDeltaTime
    local timerIndex = self.execIndex <= self.timeLen and self.execIndex or self.timeLen
    local interval = self.times[timerIndex] or 0
    if self.timer >= interval then
        self:OnExec()
        self.execIndex = self.execIndex + 1
        self.timer = 0
    end
end

function IntervalExecuteCond:OnExec()
    self:TriggerCond()
end

function IntervalExecuteCond:OnDestroy()
    self.enable = false
end

