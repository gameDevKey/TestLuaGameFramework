PassiveCondBase = BaseClass("PassiveCondBase",SECBBase)

function PassiveCondBase:__Init()
    self.passive = nil
    self.events = {}
end

function PassiveCondBase:__Delete()
	
end

function PassiveCondBase:Init(passive)
    self.passive = passive
    self:OnInit()
end

function PassiveCondBase:AddEvent(event,callBack,args)
    local uid = self.world.EventTriggerSystem:AddListener(event,self:ToFunc("_CallEvent"),args)
    self.events[uid] = callBack
    return uid
end

--禁止被重写
function PassiveCondBase:_CallEvent(args,eventUid)
    if not self.events[eventUid] or self.passive:MaxExecNum() then
        return
    end
    return self.events[eventUid](args)
end

function PassiveCondBase:ClearEvent()
    for uid,_ in pairs(self.events) do
        self.world.EventTriggerSystem:RemoveListener(uid)
    end
    self.events = {}
end

function PassiveCondBase:TriggerCond(param)
    self.passive:Execute(param)
end

function PassiveCondBase:Update()
    self:OnUpdate()
end

function PassiveCondBase:Destroy()
    self:ClearEvent()
    self:OnDestroy()
end

--虚函数
function PassiveCondBase:OnInit()
end

function PassiveCondBase:OnUpdate()
end

function PassiveCondBase:OnDestroy()
end