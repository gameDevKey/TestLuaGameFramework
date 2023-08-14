TaskDefine = StaticClass("TaskDefine")


TaskDefine.TaskType = {
	daily_task = 1,
}

TaskDefine.TaskState = {
	received = 1,     -- 已领取
	not_received = 2, -- 未领取
}