SECBTransformComponent = BaseClass("SECBTransformComponent",SECBComponent)

function SECBTransformComponent:__Init()
	self.pos = FPVector3(0,0,0)
	self.lastPos = FPVector3(0,0,0)

	self.rotation = FPQuaternion(0, 0, 0, 1)
	self.lastRotation = FPQuaternion(0, 0, 0, 1)

	self.forward = FPVector3(0,0,0)

	self.scale = 1000
end

function SECBTransformComponent:__Delete()
    
end

function SECBTransformComponent:OnPreUpdate()
	self.lastPos:SetByFPVector3(self.pos)
end

function SECBTransformComponent:SetPos(x,y,z)
	self.pos:Set(x,y,z)
	self.lastPos:Set(x,y,z)
end

function SECBTransformComponent:SetFixedPos(x,y,z)
	self.lastPos:SetByFPVector3(self.pos)
	self.pos:Set(x,y,z)
	self:OnPos()
end

function SECBTransformComponent:SetRotation(rotation)
	self.lastRotation:Set(self.rotation.x,self.rotation.y,self.rotation.z,self.rotation.w)
	self.rotation:Set(rotation.x,rotation.y,rotation.z,rotation.w)
	self.forward = (self.rotation * FPVector3.forward):Normalize()
end

function SECBTransformComponent:SetPosByOffset(x,y,z)
	self.lastPos:SetByFPVector3(self.pos)
	self.pos:Set(self.pos.x + x,self.pos.y + y,self.pos.z + z)
	self:OnPos()
end

function SECBTransformComponent:GetForwardPos(distance)
	local forward = self.rotation * FPVector3.forward
	forward:NormalizeTo(distance)
	return self.pos + forward
end

function SECBTransformComponent:GetForward()
	return self.forward
end

function SECBTransformComponent:GetPos()
	return self.pos
end

function SECBTransformComponent:GetRotation()
	return self.rotation
end

function SECBTransformComponent:SetScale(scale)
	self.scale = scale
	self:OnScale()
end

function SECBTransformComponent:SetScaleByOffset(scale)
	self.scale = self.scale + scale
	self:OnScale()
end

function SECBTransformComponent:GetScale()
	return self.scale
end

function SECBTransformComponent:Reset()
	self.pos:Set(0,0,0)
	self.lastPos:Set(0,0,0)

	self.rotation:Set(0,0,0,1)
	self.lastRotation:Set(0,0,0,1)

	self.forward:Set(0,0,0)
end

function SECBTransformComponent:OnPos()
end

function SECBTransformComponent:OnScale()
end