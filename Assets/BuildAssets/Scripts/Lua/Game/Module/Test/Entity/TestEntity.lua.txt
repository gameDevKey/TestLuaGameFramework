TestEntity = Class("TestEntity",ECSLEntity)

function TestEntity:OnInit()
end

function TestEntity:OnDelete()
end

function TestEntity:OnUpdate()
    PrintLog("TestEntity:",self:GetUid(),"OnUpdate")
end

function TestEntity:DoSomething()
    PrintLog("TestEntity:",self:GetUid(),"执行了一些逻辑")
end

return TestEntity