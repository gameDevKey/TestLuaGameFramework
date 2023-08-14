MagicEventBehavior = BaseClass("MagicEventBehavior",SECBBehavior)

function MagicEventBehavior:__Init()
    self.event = nil
    self.listenerEvents = {}
end

function MagicEventBehavior:__Delete()
end

function MagicEventBehavior:SetEvent(event)
    self.event = event
end

function MagicEventBehavior:Init()
    self:OnInit()
end

function MagicEventBehavior:AddEvent(event,callBack,eventArgs)
    local uid = self.world.EventTriggerSystem:AddListener(event,self:ToFunc("_CallEvent"),eventArgs)
    self.listenerEvents[uid] = callBack
    return uid
end

--禁止被重写
function MagicEventBehavior:_CallEvent(args,eventUid)
    if not self.listenerEvents[eventUid] or self.event:IsMaxExecNum() then
        return
    end
    return self.listenerEvents[eventUid](args)
end

function MagicEventBehavior:RemoveEvent(uid)
	self.world.EventTriggerSystem:RemoveListener(uid)
	self.listenerEvents[uid] = nil
end

function MagicEventBehavior:ClearEvent()
    for uid,_ in pairs(self.listenerEvents) do
        self.world.EventTriggerSystem:RemoveListener(uid)
    end
    self.listenerEvents = {}
end

function MagicEventBehavior:Destroy()
    self:ClearEvent()
    self:OnDestroy()
end

--
function MagicEventBehavior:OnAwake()
end

function MagicEventBehavior:OnExecute()
    return false
end

function MagicEventBehavior:OnUpdate()
end

function MagicEventBehavior:OnDestroy()
end

function MagicEventBehavior:OnCheckRemove()
    return false
end
