OpenFuncTrigger = BaseClass("OpenFuncTrigger",BaseGuideTrigger)

function OpenFuncTrigger:OnUpdate()
    local curList = mod.OpenFuncProxy.openList or {}
    if curList[self.triggerCond.funcId] then
        self:TriggerCond(self.triggerCond)
    end
end