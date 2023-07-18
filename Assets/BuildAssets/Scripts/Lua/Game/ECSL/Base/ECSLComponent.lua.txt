ECSLComponent = Class("ECSLComponent",ECSLBehaivor)
ECSLComponent.TYPE = ECSLConfig.Type.Component

function ECSLComponent:OnInit()
    self.entity = nil
end

function ECSLComponent:OnDelete()
end

function ECSLComponent:SetEntity(entity)
    self.entity = entity
end

function ECSLComponent:OnUpdate(deltaTime)
end

function ECSLComponent:OnEnable()
end

return ECSLComponent