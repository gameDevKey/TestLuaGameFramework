local eventDispatcher = EventDispatcher.New()

local callobject = CallObject.New(function (...)
    PrintLog("触发callobject",...)
end,nil,{"参数1","参数2"})
local key1 = eventDispatcher:AddListener("A", callobject, true)

local callobject2 = CallObject.New(function (...)
    PrintLog("触发callobject2",...)
end,nil,{"参数3","参数4"})
local key2 = eventDispatcher:AddListener("A", callobject2, false)

PrintLog("第一次广播")

eventDispatcher:Broadcast("A","广播数据1","广播数据2")

PrintLog("第二次广播")

eventDispatcher:Broadcast("A","广播数据3","广播数据4")

PrintLog("移除key2监听后再次广播")
eventDispatcher:RemoveListener("A",key2)

eventDispatcher:Broadcast("A","广播数据5","广播数据6")