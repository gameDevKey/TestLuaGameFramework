ECSLRenderComponent = Class("ECSLRenderComponent",ECSLBehaivor)
ECSLRenderComponent.TYPE = ECSLConfig.Type.Component

function ECSLRenderComponent:OnInit()
    self.entity = nil
    self.isRender = true
end

function ECSLRenderComponent:OnDelete()
end

function ECSLRenderComponent:SetEntity(entity)
    self.entity = entity
end

function ECSLRenderComponent:OnUpdate()
end

function ECSLRenderComponent:OnEnable()
end

return ECSLRenderComponent