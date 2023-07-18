TransformRenderComponent = Class("TransformRenderComponent",ECSLRenderComponent)

function TransformRenderComponent:OnInit()
    self.lastPos = nil
end

function TransformRenderComponent:OnDelete()
end

function TransformRenderComponent:OnUpdate()
    local logicTransform = self.entity.TransformComponent
    if not logicTransform then
        return
    end
    local vec3 = logicTransform:GetPosVec3()
    if vec3 ~= self.lastPos then
        self.entity.gameObject.transform.localPosition = vec3
        self.lastPos = vec3
    end
end

function TransformRenderComponent:OnEnable()
end

return TransformRenderComponent