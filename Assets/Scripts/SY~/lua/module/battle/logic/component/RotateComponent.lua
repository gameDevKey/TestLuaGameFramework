RotateComponent = BaseClass("RotateComponent",SECBComponent)

function RotateComponent:__Init()
    self.rotateSpeed = 1000
    --self.lookAt
end

function RotateComponent:__Delete()
end

function RotateComponent:OnInit()
end


function RotateComponent:LookAtTarget(entity)
    local targetPos = entity.TransformComponent:GetPos()
	local curPos = self.entity.TransformComponent:GetPos()
	local x = targetPos.x - curPos.x
	local z = targetPos.z - curPos.z
	if x == 0 and z == 0 then
		return
	end
	local rotate = FPQuaternion.LookRotation(FPVector3(x,0,z))
    self.entity.TransformComponent:SetRotation(rotate)
end

function RotateComponent:LookAtPos(x,z)
    local curPos = self.entity.TransformComponent:GetPos()
	local x = x - curPos.x
	local z = z - curPos.z
	if x == 0 and z == 0 then
		return
	end
	local rotate = FPQuaternion.LookRotation(FPVector3(x,0,z))
    self.entity.TransformComponent:SetRotation(rotate)
end

function RotateComponent:LookAtDir(x,z)
    local rotate = FPQuaternion.LookRotation(FPVector3(x,0,z))
    self.entity.TransformComponent:SetRotation(rotate)
end

function RotateComponent:LookAtTargetByLerp(entity,useBase,extraSpeed,accelSpeed,lastTime)
	self.isLookAt = true
	self.lookAtAccelSpeed = accelSpeed
	self.lookAtLastTime = lastTime
	self.lookAtInstanceId = entity.instanceId

	local baseSpeed = useBase and self.rotateSpeed or 0
	self.lookAtInitSpeed = baseSpeed + extraSpeed
	self.lookAtNowSpeed = self.lookAtInitSpeed

	local pos1 = entity.transformComponent.position
	local pos2 = self.transformComponent.position
	local x = pos1.x - pos2.x
	local z = pos1.z - pos2.z
	local rotate = Quaternion.LookRotation(Vector3(x,0,z))
	self.lookAtRotate = rotate
end


-- function RotateComponent:OnUpdate()
-- end