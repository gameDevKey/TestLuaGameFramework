GameEventSystem = Class("GameEventSystem", ECSLSystem)
local _ = GameEventSystemExtend

function GameEventSystem:OnInit()
    self.eventDispatcher = EventDispatcher.New()
    self.eventHandlers = {}
    self:BindAllHandler()
end

function GameEventSystem:OnDelete()
    self.eventDispatcher:Delete()
    for eventId, callobject in pairs(self.eventHandlers) do
        callobject:Delete()
    end
    self.eventDispatcher = nil
end

---绑定处理器
---@param eventId EventConfig.Type
---@param callObject CallObject func(judgeData,...):bool
function GameEventSystem:BindHandler(eventId, callObject)
    self.eventHandlers[eventId] = callObject
end

function GameEventSystem:BindHandlerBySelfFunc(eventId, fnName)
    self:BindHandler(eventId, CallObject.New(self:ToFunc(fnName)))
end

function GameEventSystem:AddListener(eventId, callObject, judgeData, once)
    local eventKey = self.eventDispatcher:AddListener(eventId,
        CallObject.New(self:ToFunc("OnEvent"), nil, {
            eventId = eventId,
            callObject = callObject,
            judgeData = judgeData,
        })
        , once)
    return eventKey
end

function GameEventSystem:RemoveListener(eventId, eventKey)
    self.eventDispatcher:RemoveListener(eventId, eventKey)
end

function GameEventSystem:Broadcast(eventId, ...)
    self.eventDispatcher:Broadcast(eventId, ...)
end

function GameEventSystem:OnEvent(args, ...)
    local handler = self.eventHandlers[args.eventId]
    local valid = handler == nil or handler:Invoke(args.judgeData, ...)
    if valid then
        args.callObject:Invoke(...)
    end
end

return GameEventSystem
