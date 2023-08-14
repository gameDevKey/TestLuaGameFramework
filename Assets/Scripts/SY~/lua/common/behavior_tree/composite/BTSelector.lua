BTSelector = BaseClass("BTSelector",BTComposite)

function BTSelector:__Init()
    self.currentChildIndex = 1
    self.executionStatus = BTTaskStatus.Inactive
end

function BTSelector:__Delete()
end

function BTSelector:CurrentChildIndex()
    return self.currentChildIndex
end

function BTSelector:CanExecute()
    return self.currentChildIndex < #self.children and self.executionStatus ~= BTTaskStatus.Success
end

function BTSelector:OnChildExecuted(childStatus)
    self.currentChildIndex = self.currentChildIndex + 1
    self.executionStatus = childStatus
end

function BTSelector:OnConditionalAbort(childIndex)
    self.currentChildIndex = childIndex
    self.executionStatus = BTTaskStatus.Inactive
end

function BTSelector:OnEnd()
    self.executionStatus = BTTaskStatus.Inactive
    self.currentChildIndex = 1
end