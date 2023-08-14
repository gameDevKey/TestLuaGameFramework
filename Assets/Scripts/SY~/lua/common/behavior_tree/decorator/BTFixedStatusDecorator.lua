BTFixedStatusDecorator = BaseClass("BTFixedStatusDecorator",BTDecorator)

function BTFixedStatusDecorator:__Init()
end

function BTFixedStatusDecorator:__Delete()
end

function BTFixedStatusDecorator:OnStart()
end

function BTFixedStatusDecorator:OnUpdate(deltaTime)
    if not self:HasChild() then
        return BTTaskStatus.Success
    end

    local childTask = self:GetChild(1)
    childTask:Update(deltaTime)

    return self.params.status
end