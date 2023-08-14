BaseGuideTrigger = BaseClass("BaseGuideTrigger",SECBBase)

function BaseGuideTrigger:__Init()
    self.guideAction = nil
    self.triggerCond = nil
    self.onTriggerCond = nil
    self.eventUids = {}
end

function BaseGuideTrigger:__Delete()
	self:Destroy()
end

function BaseGuideTrigger:Init(guideAction, triggerCond)
    self.guideAction = guideAction
    self.triggerCond = triggerCond or guideAction.conf.trigger_cond
    self:OnInit()
end

function BaseGuideTrigger:AddEvent(event,callBack,args)
    local uid = mod.PlayerGuideEventCtrl:AddListener(event,callBack,args)
    table.insert(self.eventUids,uid)
end

function BaseGuideTrigger:ClearEvent()
    for _,uid in ipairs(self.eventUids) do
        mod.PlayerGuideEventCtrl:RemoveListener(uid)
    end
    self.eventUids = {}
end

function BaseGuideTrigger:TriggerCond(param)
    if self.onTriggerCond then
        self.onTriggerCond(self,param)
    else
        self.guideAction:TriggerFinish(param)
    end
end

function BaseGuideTrigger:SetTriggerCondFunc(func)
    self.onTriggerCond = func
end

function BaseGuideTrigger:Destroy()
    self:ClearEvent()
    self:OnDestroy()
end

function BaseGuideTrigger:Update(deltaTime)
    self:OnUpdate(deltaTime)
end

--
function BaseGuideTrigger:OnInit()
end
function BaseGuideTrigger:OnUpdate()
end
function BaseGuideTrigger:OnDestroy()
end