IWorld = Interface("IWorld")

function IWorld:SetWorld(world)
    self.world = world
end

function IWorld:GetWorld()
    return self.world or RunWorld
end

return IWorld