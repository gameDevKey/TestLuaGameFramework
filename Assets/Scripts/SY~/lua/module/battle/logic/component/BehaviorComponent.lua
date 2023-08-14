BehaviorComponent = BaseClass("BehaviorComponent",SECBBehaviorComponent)

function BehaviorComponent:__Init()

end

function BehaviorComponent:__Delete()
end

function BehaviorComponent:OnInit()
    
end

function BehaviorComponent:OnUpdate()
    self:UpdateBehavior()
end