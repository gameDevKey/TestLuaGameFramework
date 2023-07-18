MoveComponent = Class("MoveComponent",ECSLComponent)

function MoveComponent:OnInit()
    self.mover = nil --TODO 改用池
end

function MoveComponent:OnDelete()
    if self.mover then
        self.mover:Delete()
        self.mover = nil
    end
end

function MoveComponent:OnUpdate(deltaTime)
    if self.mover then
        self.mover:Update(deltaTime)
    end
end

function MoveComponent:OnEnable()
end

function MoveComponent:To(moveType,moveArgs)
    self:Stop()
    self.mover = _G[MoveConfig.Class[moveType]].New(moveType,moveArgs)
    self.mover:SetEntity(self.entity)
    self.mover:Start()
end

function MoveComponent:Stop()
    if self.mover then
        self.mover:Stop()
        self.mover:Delete()
        self.mover = nil
    end
end

return MoveComponent