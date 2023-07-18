TestComponent = Class("TestComponent",ECSLComponent)

function TestComponent:OnInit()
end

function TestComponent:OnDelete()
end

function TestComponent:OnUpdate()
    PrintLog("TestComponent:",self:GetUid(),"OnUpdate")
end

function TestComponent:OnEnable()
    PrintLog("TestComponent:",self:GetUid(),"OnEnable",self.enable)
end

return TestComponent