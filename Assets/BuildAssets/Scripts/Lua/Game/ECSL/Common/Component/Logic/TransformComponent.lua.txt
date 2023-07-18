TransformComponent = Class("TransformComponent",ECSLComponent)

function TransformComponent:OnInit()
    self.posVec3 = Vector3.zero
end

function TransformComponent:OnDelete()
end

function TransformComponent:OnUpdate()
end

function TransformComponent:OnEnable()
end

function TransformComponent:SetPos(x,y,z)
    self.posVec3.x,self.posVec3.y,self.posVec3.z = (x or 0),(y or 0),(z or 0)
end

function TransformComponent:SetPosVec3(vec)
    self.posVec3 = vec
end

function TransformComponent:GetPos()
    return self.posVec3.x,self.posVec3.y,self.posVec3.z
end

function TransformComponent:GetPosVec3()
    return self.posVec3
end

return TransformComponent