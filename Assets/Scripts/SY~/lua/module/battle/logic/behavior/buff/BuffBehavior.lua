BuffBehavior = BaseClass("BuffBehavior",SECBBehavior)

function BuffBehavior:__Init()
    self.buff = nil
    self.actionParam = nil
    self.events = {}
end

function BuffBehavior:__Delete()
end

function BuffBehavior:SetBuff(buff)
    self.buff = buff
end

function BuffBehavior:Init(actionParam)
    self.actionParam = actionParam
    self:OnInit()
end

function BuffBehavior:AddEvent(event,callBack,eventArgs)
    local uid = self.world.EventTriggerSystem:AddListener(event,self:ToFunc("_CallEvent"),eventArgs)
    self.events[uid] = callBack
    return uid
end

--禁止被重写
function BuffBehavior:_CallEvent(args,eventUid)
    if not self.events[eventUid] or self.buff:IsMaxExecNum() then
        return
    end
    return self.events[eventUid](args)
end

function BuffBehavior:RemoveEvent(uid)
	self.world.EventTriggerSystem:RemoveListener(uid)
	self.events[uid] = nil
end

function BuffBehavior:ClearEvent()
    for uid,_ in pairs(self.events) do
        self.world.EventTriggerSystem:RemoveListener(uid)
    end
    self.events = {}
end

function BuffBehavior:Destroy()
    self:OnDestroy()
end

--
function BuffBehavior:OnAwake()
end

function BuffBehavior:OnExecute()
    return false
end

function BuffBehavior:OnUpdate()
end

function BuffBehavior:OnOverlay()
end

function BuffBehavior:OnDestroy()
end

function BuffBehavior:OnCheckRemove()
    return false
end
