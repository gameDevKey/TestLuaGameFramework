TaskRemindCtrl = BaseClass("TaskRemindCtrl",Controller)

function TaskRemindCtrl:__Init()
    self.lastTasks = {}
end

function TaskRemindCtrl:__Delete()

end

function TaskRemindCtrl:__InitComplete()

end

function TaskRemindCtrl:CheckTaskRemind(info,data,protoId)
    for taskType,tasks in pairs(self.lastTasks) do
        for i,v in ipairs(tasks) do
            if not mod.TaskProxy.taskList[v.uid] then
                local key = string.format("%s_%s",taskType,v.uid)
                info:SetFlag(false,key)
            end
        end
    end

    for k,v in pairs(mod.TaskProxy.taskTypeList) do
        if k == TaskDefine.TaskType.daily_task then
            self:CheckDailyTask(v,info,data,protoId)
        end
    end
end

function TaskRemindCtrl:CheckDailyTask(tasks,info,data,protoId)
    for i,v in ipairs(tasks) do
        self.lastTasks[v.uid] = v
        local key = string.format("%s_%s",TaskDefine.TaskType.daily_task,v.uid)
        info:SetFlag(v.state == TaskDefine.TaskState.not_received,key)
    end
end


function TaskRemindCtrl:CheckReceiveTaskRemind(info,data,protoId)
    for taskType,tasks in pairs(self.lastTasks) do
        for i,v in ipairs(tasks) do
            if not mod.TaskProxy.taskList[v.uid] then
                local key = string.format("%s_%s",taskType,v.uid)
                info:SetFlag(false,key)
            end
        end
    end

    for k,v in pairs(mod.TaskProxy.taskTypeList) do
        if k == TaskDefine.TaskType.daily_task then
            self:CheckReceiveDailyTask(v,info,data,protoId)
        end
    end
end

function TaskRemindCtrl:CheckReceiveDailyTask(tasks,info,data,protoId)
    for i,v in ipairs(tasks) do
        self.lastTasks[v.uid] = v

        local conf = mod.TaskProxy:GetTaskConfById(v.task_id)
        local val = v.progress / conf.target[#conf.target]
    
        local key = string.format("%s_%s",TaskDefine.TaskType.daily_task,v.uid)
        info:SetFlag(v.state == TaskDefine.TaskState.not_received and v.progress >= conf.target[#conf.target],key)
    end
end