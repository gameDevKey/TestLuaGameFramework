AIBehaviorTree = BaseClass("AIBehaviorTree",BehaviorTree)

function AIBehaviorTree:__Init()
    self.world = nil
    self.entity = nil
end

function AIBehaviorTree:__Delete()

end

function BehaviorTree:OnInit(world,entity)
    self.world = world
    self.entity = entity
end