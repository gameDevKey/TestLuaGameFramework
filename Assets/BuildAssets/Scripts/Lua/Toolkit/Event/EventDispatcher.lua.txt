EventDispatcher = Class("EventDispatcher")

function EventDispatcher:OnInit()
    self.tbAllEvent = {} --map[EventId]ListMap
    self.eventKeyGenerator = GetAutoIncreaseFunc()
end

function EventDispatcher:OnDelete()
    self:RemoveAllListener()
end

---添加监听器
---@param eventId any 监听类型
---@param callback function 回调 function(...) 接收广播数据
---@param callOnce boolean|nil 是否只监听一次
function EventDispatcher:AddListener(eventId, callObject, callOnce)
    local eventKey = self.eventKeyGenerator()
    if not self.tbAllEvent[eventId] then
        self.tbAllEvent[eventId] = ListMap.New()
    end
    self.tbAllEvent[eventId]:Add(eventKey,{
        callObject = callObject,
        callOnce = callOnce,
    })
    return eventKey
end

---移除监听器
---@param eventId any 监听类型
function EventDispatcher:RemoveListener(eventId, eventKey)
    if self.tbAllEvent[eventId] and self.tbAllEvent[eventId]:Size() > 0 then
        self.tbAllEvent[eventId]:Remove(eventKey)
    end
end

---移除所有监听器
function EventDispatcher:RemoveAllListener()
    for eventId, listMap in pairs(self.tbAllEvent) do
        listMap:Delete()
    end
    self.tbAllEvent = {}
end

---广播
---@param eventId any 监听类型
---@param ... any 任意数据
function EventDispatcher:Broadcast(eventId, ...)
    local listMap = self.tbAllEvent[eventId]
    if listMap then
        listMap:RangeByCallObject(
            CallObject.New(self:ToFunc("OnBroadcast"),nil,{
                eventId = eventId,
                args = {...},
            }))
    end
end

function EventDispatcher:OnBroadcast(args,iter)
    iter.value.callObject:Invoke(table.SafeUpack(args.args))
    if iter.value.callOnce then
        self:RemoveListener(args.eventId,iter.key)
    end
end

return EventDispatcher
