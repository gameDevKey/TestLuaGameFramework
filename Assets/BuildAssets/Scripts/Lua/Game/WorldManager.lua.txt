WorldManager = SingletonClass("WorldManager")

function WorldManager:OnInit()
    self.worlds = ListMap.New()
end

function WorldManager:OnDelete()
    if self.worlds then
        self.worlds:Range(function (iter)
            iter.value:Delete()
        end)
        self.worlds:Delete()
        self.worlds = nil
    end
end

function WorldManager:AddWorld(world)
    self.worlds:Add(world._className,world)
end

function WorldManager:RemoveWorld(world)
    self.worlds:Remove(world._className)
end

function WorldManager:Tick(deltaTime)
    self.deltaTime = deltaTime
    self.worlds:Range(self.UpdateWorld,self)
end

function WorldManager:UpdateWorld(iter)
    iter.value:Update(self.deltaTime)
end

return WorldManager