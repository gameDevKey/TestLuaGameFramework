TestWorld = Class("TestWorld",ECSLWorld)

function TestWorld:OnInit()
    self:AddSystem(EntitySystem.New())
    self:AddSystem(EntityCreateSystem.New())
end

function TestWorld:OnDelete()
end

function TestWorld:OnUpdate()
    PrintLog("TestWorld:",self:GetUid(),"OnUpdate")
end

return TestWorld