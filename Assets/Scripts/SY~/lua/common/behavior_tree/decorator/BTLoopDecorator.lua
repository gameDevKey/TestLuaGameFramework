BTLoopDecorator = BaseClass("BTLoopDecorator",BTDecorator)

function BTLoopDecorator:__Init()
    self.curLoopNum = 0
end

function BTLoopDecorator:__Delete()
end

function BTLoopDecorator:OnStart()
    self.curLoopNum = 0
end

function BTLoopDecorator:OnUpdate(deltaTime)
    if not self:HasChild() then
        return BTTaskStatus.Success
    end

    local childTask = self:GetChild(1)
    while (self.params.loopNum <= 0 or self.curLoopNum < self.params.loopNum) do
        local status = childTask:Update(deltaTime)
        if status == BTTaskStatus.Failure then
            return BTTaskStatus.Failure
        elseif self.params.loopNum <= 0 then
            return BTTaskStatus.Running
        elseif status == BTTaskStatus.Running then
            return BTTaskStatus.Running
        else
            self.curLoopNum = self.curLoopNum + 1
        end
    end
    return BTTaskStatus.Success
end