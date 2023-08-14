BattleClientEntitySystem = BaseClass("BattleClientEntitySystem",SECBClientEntitySystem)
BattleClientEntitySystem.NAME = "ClientEntitySystem"

function BattleClientEntitySystem:__Init()
end

function BattleClientEntitySystem:__Delete()
    self:CleanEntitys()
end

function BattleClientEntitySystem:OnInitSystem()

end

function BattleClientEntitySystem:OnLateInitSystem()
    
end

function BattleClientEntitySystem:OnUpdate()
    self:UpdateEntity()
end

function BattleClientEntitySystem:OnLateUpdate()
    self:LateUpdateEntity()
end