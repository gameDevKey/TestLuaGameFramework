GamePlayEntranceSystem = Class("GamePlayEntranceSystem",ECSLSystem)

function GamePlayEntranceSystem:OnAfterInit()
    self.mainRole = self.world.EntityCreateSystem:CreateMainRole({x=0,y=0,z=0})

    for i = 1, 10, 1 do
        local x = math.random(-10,10)
        local y = math.random(-10,10)
        self.world.EntityCreateSystem:CreateEnermy({x=x,y=y,z=0})
    end
end

function GamePlayEntranceSystem:OnDelete()
    self.mainRole = nil
end

function GamePlayEntranceSystem:OnUpdate()
end

return GamePlayEntranceSystem