BTParentTask = BaseClass("BTParentTask",BTTask)

function BTParentTask:__Init()
    self.childTasks = {}
    self.childNum = 0
end

function BTParentTask:__Delete()
end

function BTParentTask:HasChild()
    return self:GetChildNum() > 0
end

function BTParentTask:GetChildNum()
    return self.childNum
end

function BTParentTask:GetChild(index)
    return self.childTasks[index]
end

function BTParentTask:AddChild(task)
    self.childNum = self.childNum + 1
    task.parentNode = self
    task.index = self.childNum
    task.layer = self.layer + 1
    table.insert(self.childTasks,task)
end

--虚函数
function BTParentTask:MaxChildren()
    return 2147483647
end

--虚函数
function BTParentTask:CanRunParallelChildren()
    return false
end

--虚函数
function BTParentTask:CurrentChildIndex()
    return 1
end

--虚函数
function BTParentTask:CanExecute()
    return true
end

--虚函数
function BTParentTask:Decorate(status)
    return status
end

--虚函数
function BTParentTask:CanReevaluate()
    return false
end

--虚函数
function BTParentTask:OnReevaluationStarted()
    return false
end

--虚函数
function BTParentTask:OnReevaluationEnded(status)

end

--虚函数
function BTParentTask:OnChildExecuted(childStatus)
    
end

--虚函数
function BTParentTask:OnChildExecutedByIndex(childIndex,childStatus)
    
end

--虚函数
function BTParentTask:OnChildStarted()
    
end

--虚函数
function BTParentTask:OnChildStartedByIndex(childIndex)
    
end

--虚函数
function BTParentTask:OverrideStatusByStatus(status)
    return status
end

--虚函数
function BTParentTask:OverrideStatus()
    return BTTaskStatus.Running
end

--虚函数
function BTParentTask:OnConditionalAbort(childIndex)
    
end

function BTParentTask:ReplaceAddChild(child,index)
    if #self.children > 0 and index <= #self.children then
        self.children[index] = child
    else
        self:AddChild(child,index)
    end
end