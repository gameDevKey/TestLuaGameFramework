TimelineBase = Class("TimelineBase")

---初始化
---@param data table { Id, Duration, Actions }
---@param setting table { actionFunc/actionHandler, finishFunc }
---@param args any 任意参数
---@param actionFunc function action处理回调(可选)
---@param actionHandler Class action处理类(可选)
---@param finishFunc function timeline结束回调
function TimelineBase:OnInit(data, setting, args)
    self.data = data
    self.setting = setting
    self.args = args
    self.duration = self.data.Duration
    self.actionFunc = self.setting.actionFunc
    self.actionHandler = self.setting.actionHandler
    self.finishFunc = self.setting.finishFunc

    self.isStart = false
    self.isFinish = false
    self.timer = 0
    self.actionIndex = 0
    self.actionAmount = #self.data.Actions
end

function TimelineBase:OnDelete()
    self.isStart = false
    self.isFinish = false
end

function TimelineBase:SetActionHandler(handler)
    self.actionHandler = handler
end

function TimelineBase:SetArgs(args)
    self.args = args
end

function TimelineBase:Start()
    self.isStart = true
    self.isFinish = false
    self.timer = 0
    self.actionIndex = 0
    self:NextStep()
end

function TimelineBase:Update(deltaTime)
    if not self.isStart or self.isFinish then
        return
    end
    self.timer = self.timer + deltaTime
    if self.duration > 0 and self.timer > self.duration then
        self:Finish()
        return
    end
    if self.actionData and self.timer >= self.nextTime then
        self:RunAction()
        self:NextStep()
    end
end

function TimelineBase:NextStep()
    self.actionIndex = self.actionIndex + 1
    if self.actionIndex > self.actionAmount then
        self.actionData = nil
        if self.duration == 0 then
            self:Finish()
        end
        return
    end
    self.actionData = self.data.Actions[self.actionIndex]
    self.nextTime = self.actionData.Time or 0
end

function TimelineBase:RunAction()
    if not self.actionData then
        return
    end
    local fn = self.actionFunc
    if not fn and self.actionHandler then
        if self.actionHandler._isInstance then
            fn = self.actionHandler:ToFunc(self.actionData.Action)
        else
            fn = self.actionHandler[self.actionData.Action]
        end
    end
    _ = fn and fn(self.actionData,self.args)
end

function TimelineBase:Finish()
    self.isFinish = true
    _ = self.finishFunc and self.finishFunc(self.data)
end

return TimelineBase