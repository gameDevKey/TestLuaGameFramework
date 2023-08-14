DailyTaskWindow = BaseClass("DailyTaskWindow",BaseWindow)
DailyTaskWindow.Event = EventEnum.New(
    "RefreshDailyTask"
)
DailyTaskWindow.__showMainui = true
DailyTaskWindow.__topInfo = true
DailyTaskWindow.__bottomTab = true

function DailyTaskWindow:__Init()
    self:SetAsset("ui/prefab/task/daily_task_window.prefab",AssetType.Prefab)
    self.taskItems = {}
    self.dailyTaskCount = Config.TaskData.data_task_const_info["daily_task_count"].value
end

function DailyTaskWindow:__Delete()
    for i, v in ipairs(self.taskItems) do
        v.propItem:Destroy()
        GameObject.Destroy(v.gameObject)
    end
end

function DailyTaskWindow:__CacheObject()
    self.taskItemTemp = self:Find("template/task_item").gameObject
    self.taskItemCon = self:Find("main/task_con")

    self.propItemTemp = self:Find("template/prop_item").gameObject
end

function DailyTaskWindow:__Create()
    self:CloneTaskItem()

    self:Find("main/bg/title",Text).text = TI18N("日常任务")
    self:Find("main/refresh_tips",Text).text = TI18N("日常任务将在0点更新")
end

function DailyTaskWindow:CloneTaskItem()
    for i = 1, self.dailyTaskCount do
        local item = {}
        item.gameObject = GameObject.Instantiate(self.taskItemTemp)
        item.transform = item.gameObject.transform
        item.transform:SetParent(self.taskItemCon)
        item.transform:Reset()
        UnityUtils.SetAnchoredPosition(item.transform,0,(i-1)*(-122))

        item.propItem = PropItem.Create(self.propItemTemp)
        item.propItem:SetParent(item.transform:Find("reward_item"),0,0)
        item.propItem.transform:Reset()
        item.propItem:SetSize(88,78)
        item.propItem:Show()

        item.content = item.transform:Find("content").gameObject:GetComponent(Text)
        item.sliderMask = item.transform:Find("slider/mask")
        item.sliderFilled = item.transform:Find("slider/mask/filled")
        item.count = item.transform:Find("slider/count").gameObject:GetComponent(Text)

        item.goBtn = item.transform:Find("go_btn").gameObject:GetComponent(Button)
        item.goBtn.transform:Find("text").gameObject:GetComponent(Text).text = TI18N("前往")
        item.receiveBtn = item.transform:Find("receive_btn").gameObject:GetComponent(Button)
        item.receiveBtn.transform:Find("text").gameObject:GetComponent(Text).text = TI18N("领取")

        item.completed = item.transform:Find("completed").gameObject

        table.insert(self.taskItems,item)
    end
end

function DailyTaskWindow:__BindEvent()
    self:BindEvent(DailyTaskWindow.Event.RefreshDailyTask)
end

function DailyTaskWindow:__BindListener()
    self:Find("panel_bg",Button):SetClick(self:ToFunc("OnCloseClick"))
    self:Find("main/close_btn",Button):SetClick(self:ToFunc("OnCloseClick"))
end

function DailyTaskWindow:__Show()
    self:RefreshDailyTask()
end

function DailyTaskWindow:__Hide()
end

function DailyTaskWindow:RefreshDailyTask()
    local dailyTaskData = mod.TaskProxy:GetTaskListByType(TaskDefine.TaskType.daily_task)
    for i, v in ipairs(dailyTaskData) do
        self:SetTaskItem(i,v)
    end
end

function DailyTaskWindow:SetTaskItem(index,data)
    local taskItem = self.taskItems[index]
    local taskId = data.task_id
    local conf = mod.TaskProxy:GetTaskConfById(taskId)

    local rewardItemData = {}
    rewardItemData.item_id = conf.reward[1][1]
    rewardItemData.count = conf.reward[1][2]
    taskItem.propItem:SetData(rewardItemData)

    taskItem.content.text = mod.TaskProxy:FormatTaskDesc(conf.desc, conf.target)

    local val = data.progress / conf.target[#conf.target]
    local width = taskItem.sliderFilled.rect.width * val
    local height = taskItem.sliderFilled.rect.height
    UnityUtils.SetSizeDelata(taskItem.sliderMask, width, height)
    taskItem.count.text = string.format("%s/%s",data.progress,conf.target[#conf.target])

    local state = data.state
    if state == TaskDefine.TaskState.received then
        taskItem.goBtn.gameObject:SetActive(false)
        taskItem.receiveBtn.gameObject:SetActive(false)
        taskItem.completed.gameObject:SetActive(true)
    elseif state == TaskDefine.TaskState.not_received and val == 1 then
        taskItem.goBtn.gameObject:SetActive(false)
        taskItem.receiveBtn.gameObject:SetActive(true)
        taskItem.completed.gameObject:SetActive(false)
        taskItem.receiveBtn:SetClick(self:ToFunc("ReceiveReward"),data.uid)
    else
        taskItem.goBtn.gameObject:SetActive(true)
        taskItem.receiveBtn.gameObject:SetActive(false)
        taskItem.completed.gameObject:SetActive(false)
        taskItem.goBtn:SetClick(self:ToFunc("DailyTaskJump"),conf.jump_ways)
    end
end

function DailyTaskWindow:OnCloseClick()
    ViewManager.Instance:CloseWindow(DailyTaskWindow)
end

function DailyTaskWindow:ReceiveReward(taskUid)
    mod.TaskFacade:SendMsg(11505,taskUid)
end

function DailyTaskWindow:DailyTaskJump(jumpWays)
    if #jumpWays > 0 then
        mod.JumpCtrl:JumpTo(jumpWays[1])
        self:OnCloseClick()
    else
        SystemMessage.Show(TI18N("未配置跳转id"))
    end
end