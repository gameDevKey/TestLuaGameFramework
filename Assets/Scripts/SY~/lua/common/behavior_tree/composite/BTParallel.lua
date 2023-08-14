BTParallel = BaseClass("BTParallel",BTComposite)

function BTParallel:__Init()
    self.completeNum = 0
    self.currentChildIndex = 1
    self.executionStatus = {}
end

function BTParallel:__Delete()
end

function BTParallel:OnAwake()
end

function BTParallel:CurrentChildIndex()
    return self.currentChildIndex
end

function BTParallel:OnStart()
    self.completeNum = 0
    self.currentChildIndex = 1
    for i=1,self:GetChildNum() do
        self.executionStatus[i] = BTTaskStatus.Inactive
    end
end

function BTParallel:OnUpdate(deltaTime)
    if not self:HasChild() then
        return BTTaskStatus.Failure
    end
    
    for i=1,self:GetChildNum() do
        local childTask = self:GetChild(i)
        local status = self.executionStatus[i]
        if status == BTTaskStatus.Inactive or status == BTTaskStatus.Running then
            self.executionStatus[i] = childTask:Update(deltaTime)
            if self.executionStatus[i] == BTTaskStatus.Failure then
                return BTTaskStatus.Failure
            elseif self.executionStatus[i] == BTTaskStatus.Success then
                self.completeNum = self.completeNum + 1
            end
        end
    end

    if self.completeNum >= self:GetChildNum() then
        return BTTaskStatus.Success
    else
        return BTTaskStatus.Running
    end
end