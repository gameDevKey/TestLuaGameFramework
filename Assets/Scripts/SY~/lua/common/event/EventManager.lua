EventManager = SingleClass("EventManager")

function EventManager:__Init()
    self.events = {}
end

function EventManager:Clean()
    self.events = {}
end

function EventManager:AddEvent(event,callBack,args)
    assert(callBack ~= nil, "添加事件失败[error:回调函数为空]")
    assert(type(callBack) == "function",string.format("添加事件失败[error:回调函数类型错误][类型:%s]", type(callBack)))
    self:AssertEvent(event)
    if not self.events[event] then self.events[event] = EventAction.Create() end
    self.events[event]:AddListener(callBack,args)
end

function EventManager:AddEventOnce(event,callBack)
    local fn
    fn = function ()
        self:RemoveEvent(event,fn)
        callBack()
    end
    self:AddEvent(event,fn)
end

function EventManager:RemoveEvent(event,callBack)
    assert(callBack ~= nil, "移除事件失败[error:回调函数为空]")
    assert(type(callBack) == "function",string.format("移除事件失败[error:回调函数类型错误][类型:%s]", type(callBack)))
    self:AssertEvent(event)
    if not self.events[event] then return end
    self.events[event]:RemoveListener(callBack)
end

function EventManager:SendEvent(event,...)
    self:AssertEvent(event)
    local eventAction = self.events[event]
    if not eventAction then return end
    eventAction:SendEvent(...)
end

function EventManager:AssertEvent(event)
    assert(event ~= nil, "事件为空")
    assert(event._enum, "事件类型错误")
    assert(event == EventDefine[event.value], "[event_define.lua]未定义的事件")
end