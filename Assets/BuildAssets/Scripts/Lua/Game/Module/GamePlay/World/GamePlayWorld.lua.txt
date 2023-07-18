GamePlayWorld = Class("GamePlayWorld",ECSLWorld)

function GamePlayWorld:OnInit()
    self:AddSystem(EntitySystem.New())
    self:AddSystem(EntityCreateSystem.New())
    self:AddSystem(GamePlayEntranceSystem.New())
    self:AddSystem(GameInputSystem.New())
    self:AddSystem(GamePlayOperateSystem.New())
    self:AddSystem(GameEventSystem.New())
    self:AddSystem(SearchSystem.New())
end

function GamePlayWorld:OnDelete()
end

function GamePlayWorld:OnUpdate(deltaTime)
end

return GamePlayWorld