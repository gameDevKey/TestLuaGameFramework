SECBEventTriggerSystem = BaseClass("SECBEventTriggerSystem",SECBSystem)

function SECBEventTriggerSystem:__Init()
    self.uid = 0
    self.triggers = {}
    self.eventHandlers = {}
    self.eventListeners = {}
    self.uidToEvent = {}
end

function SECBEventTriggerSystem:__Delete()
    for i,v in ipairs(self.triggers) do
        v:Delete()
    end

    self.eventHandlers = {}

    for k,v in pairs(self.eventListeners) do
        v:Delete()
    end
end

function SECBEventTriggerSystem:OnLateInitSystem()
    self:OnInitTrigger()
end

function SECBEventTriggerSystem:AddTrigger(triggerType)
    local trigger = triggerType.New()
    trigger:SetWorld(self.world)
    trigger:OnRegister()
    table.insert(self.triggers,trigger)
end

function SECBEventTriggerSystem:AddHandler(event,handler)
    self.eventListeners[event] = SECBList.New()
    self.eventHandlers[event] = handler
end

function SECBEventTriggerSystem:AddListener(event,callBack,args)
    if not event or not callBack then
        assert(false,string.format("添加战斗事件回调异常,事件、回调函数为空[事件:%s][回调函数:%s]",tostring(event),tostring(callBack)))
        return 
    end

    if not self.eventListeners[event] then
        assert(false,string.format("添加战斗事件回调异常,未添加处理的事件[事件:%s]",tostring(event)))
        return
    end

    self.uid = self.uid + 1
    self.eventListeners[event]:Push({uid = self.uid,callBack = callBack,args = args},self.uid)
    self.uidToEvent[self.uid] = event
    return self.uid
end

function SECBEventTriggerSystem:RemoveListener(uid)
    if not self.uidToEvent[uid] then
        assert(false,string.format("移除未知的事件[uid:%s]",tostring(uid)))
        return
    end
  
    local event = self.uidToEvent[uid]
    self.uidToEvent[uid] = nil
    self.eventListeners[event]:RemoveByIndex(uid)
end

function SECBEventTriggerSystem:Trigger(event,...)
    assert(self.eventHandlers[event],string.format("尝试触发未知的事件[event:%s]",tostring(event)))
    return self.eventHandlers[event](self.eventListeners[event],...)
end

--
function SECBEventTriggerSystem:OnInitTrigger()

end