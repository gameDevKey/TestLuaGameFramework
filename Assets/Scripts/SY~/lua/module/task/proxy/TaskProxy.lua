TaskProxy = BaseClass("TaskProxy",Proxy)

function TaskProxy:__Init()
    self.taskList = {}
    self.taskConfList = {}
    self.taskTypeList = {}

    self.taskDescFormatFunc = {
        ["pvp_win"] = { fn = "FormatTaskDescCount" },
        ["pvp_join"] = { fn = "FormatTaskDescCount" },
        ["pvp_up_star"] = { fn = "FormatTaskDescCount" },
        ["pvp_wave"] = { fn = "FormatTaskDescCount" },
        ["pvp_join_job"] = { fn = "FormatTaskDescJob" },
        ["pvp_win_job"] = { fn = "FormatTaskDescJob" },
        ["pvp_join_move"] = { fn = "FormatTaskDescMove" },
        ["pvp_win_move"] = { fn = "FormatTaskDescMove" },
        ["fight_pve"] = { fn = "FormatTaskDescCount" },
        ["sweep_pve"] = { fn = "FormatTaskDescCount" },
        ["open_box"] = { fn = "FormatTaskDescCount" },
        ["unit_up_level"] = { fn = "FormatTaskDescCount" },
        ["draw_card"] = { fn = "FormatTaskDescCount" },
    }
end

function TaskProxy:__InitProxy()
    -- 绑定协议
    self:BindMsg(11500) -- 任务列表
    self:BindMsg(11501) -- 任务更新-任务列表
    self:BindMsg(11502) -- 删除任务
    self:BindMsg(11505) -- 领取任务奖励
end

function TaskProxy:__InitComplete()
end

function TaskProxy:AddTask(task)
    self.taskList[task.uid] = task
    local conf = Config.TaskData.data_task_info[task.task_id]
    self.taskConfList[task.task_id] = conf
    if not self.taskTypeList[conf.type] then
        self.taskTypeList[conf.type] = {}
    end
    table.insert(self.taskTypeList[conf.type],task)
end

function TaskProxy:RemoveTask(taskUid)
    local task = self.taskList[taskUid]
    if task then
        local taskId = task.task_id
        self.taskList[taskUid] = nil
        local taskType = self:GetTaskConfById(taskId).type
        for i, v in ipairs(self.taskTypeList[taskType]) do
            if v.uid == taskUid then
                table.remove(self.taskTypeList[taskType],i)
                return
            end
        end
    end
end

function TaskProxy:GetTaskByUid(taskUid)
    return self.taskList[taskUid]
end

function TaskProxy:GetTaskConfById(taskId)
    local conf = self.taskConfList[taskId]
    if not conf then
        conf = Config.TaskData.data_task_info[taskId]
        self.taskConfList[taskId] = conf
    end
    return conf
end

function TaskProxy:GetTaskListByType(taskType)
    return self.taskTypeList[taskType]
end

function TaskProxy:FormatTaskDesc(desc, target)
    local func = self.taskDescFormatFunc[target[1]].fn
    if func then
        return self[func](self,desc,target)
    else
        return string.format("未实现的任务描述格式化类型[%s]", target[1])
    end
end

function TaskProxy:FormatTaskDescCount(desc,target)
    local arr,placeholder = StringUtils.SplitBySharp(desc)

    for i, v in ipairs(placeholder) do
        arr[v] = target[i+1]
    end

    local str = ""
    for i, v in ipairs(arr) do
        str = str ..v
    end

    return str
end

function TaskProxy:FormatTaskDescJob(desc,target)
    local arr,placeholder = StringUtils.SplitBySharp(desc)

    for i, v in ipairs(placeholder) do
        arr[v] = self:JobListToJobStr(target[i+1])
    end

    local str = ""
    for i, v in ipairs(arr) do
        str = str ..v
    end

    return str
end

function TaskProxy:JobListToJobStr(jobs)
    if type(jobs) ~= "table" then
        return jobs
    end
    local jobStr = ""
    for ii, job in ipairs(jobs) do
        jobStr = jobStr..GDefine.JobIndexToDesc[job]
        if ii ~= #jobs then
            jobStr = jobStr.."、"
        end
    end
    return jobStr
end

function TaskProxy:FormatTaskDescMove(desc,target)
    local arr,placeholder = StringUtils.SplitBySharp(desc)

    for i, v in ipairs(placeholder) do
        arr[v] = self:MoveTypeListToMoveTypeStr(target[i+1])
    end

    local str = ""
    for i, v in ipairs(arr) do
        str = str ..v
    end

    return str
end

function TaskProxy:MoveTypeListToMoveTypeStr(moveTypes)
    if type(moveTypes) ~= "table" then
        return moveTypes
    end
    local moveTypeStr = ""
    for ii, moveType in ipairs(moveTypes) do
        moveTypeStr = moveTypeStr..GDefine.WalkTypeToDesc[moveType]
        if ii ~= #moveTypes then
            moveTypeStr = moveTypeStr.."、"
        end
    end
    return moveTypeStr
end

---
function TaskProxy:Recv_11500(data)
    LogTable("接收11500",data)
    self.taskList = {}
    self.taskTypeList = {}
    for i, v in ipairs(data.task_list) do
        self:AddTask(v)
    end
    -- LogTable("初始化任务列表",self.taskList)
    mod.TaskFacade:SendEvent(DailyTaskWindow.Event.RefreshDailyTask)
end

function TaskProxy:Recv_11501(data)
    LogTable("接收11501",data)
    -- 增量更新
    for i, v in ipairs(data.task_list) do
        local task = self.taskList[v.uid]
        if not task then
            self:AddTask(v)
        else
            task.progress = v.progress
            task.state = v.state
        end
    end
    -- LogTable("更新任务后任务列表",self.taskList)
    mod.TaskFacade:SendEvent(DailyTaskWindow.Event.RefreshDailyTask)
end

function TaskProxy:Recv_11502(data)
    LogTable("接收11502",data)
    -- 删除任务
    for i, v in ipairs(data.uid_list) do
        self:RemoveTask(v)
    end
    -- LogTable("删除任务后任务列表",self.taskList)
    mod.TaskFacade:SendEvent(DailyTaskWindow.Event.RefreshDailyTask)
end

function TaskProxy:Send_11505(uid)
    local data = {}
    data.uid = uid
    LogTable("发送11505",data)
    return data
end

function TaskProxy:Recv_11505(data)
    LogTable("接收11505",data)
    ViewManager.Instance:OpenWindow(AwardWindow, { itemList = data.item_list })
    mod.TaskFacade:SendEvent(DailyTaskWindow.Event.RefreshDailyTask)
end