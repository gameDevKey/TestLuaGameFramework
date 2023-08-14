BTSequence = BaseClass("BTSequence",BTComposite)

function BTSequence:__Init()
    self.curChildIndex = 1
    self.curChildTask = nil
    self.executionStatus = BTTaskStatus.Inactive
end

function BTSequence:__Delete()
end

function BTSequence:OnStart()
    self.curChildIndex = 1
    self.curChildTask = self:GetChild(self.curChildIndex)
    self.executionStatus = BTTaskStatus.Inactive
end

function BTSequence:OnUpdate(deltaTime)
    if not self:HasChild() then
        return BTTaskStatus.Success
    end

    while (self.curChildTask) do
        self.executionStatus = self.curChildTask:Update(deltaTime)
        if self.executionStatus == BTTaskStatus.Failure then
            return BTTaskStatus.Failure
        elseif self.executionStatus == BTTaskStatus.Running then
            return BTTaskStatus.Running
        else
            self.curChildTask = self:GetNextChild()
        end
    end
    self.executionStatus = BTTaskStatus.Success
    return BTTaskStatus.Success
end

 --获取下一个要执行的子节点
 function BTSequence:GetNextChild()
    if self.curChildIndex + 1 <= self:GetChildNum() then
        self.curChildIndex = self.curChildIndex + 1
        return self.childTasks[self.curChildIndex]
    else
        return nil
    end
end