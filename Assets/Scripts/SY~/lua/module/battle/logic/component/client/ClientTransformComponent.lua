ClientTransformComponent = BaseClass("ClientTransformComponent",SECBClientComponent)

function ClientTransformComponent:__Init()
    self.gameObject = nil
    self.transform = nil
    self.tposeTrans = nil
    self.bonePoolKey = nil
    self.name = nil

    self.rotation = Quaternion(0,0,0,0)
    self.pos = Vector3(0,0,0)

    self.syncRotate = true

    self.rightAxis = nil
    --self.renderX = Quaternion.AngleAxis(18, Vector3.right)

    self.scale = 1000
    self.scaleAnimTime = 0.5
    self.scaleAnimTimer = 0
end

function ClientTransformComponent:__Delete()
    if self.gameObject then
        PoolManager.Instance:Push(PoolType.object,self.bonePoolKey,self.gameObject)
        self.gameObject = nil
    end
    self.transform = nil
    self.tposeTrans = nil
    self.forwardTrans = nil
end

function ClientTransformComponent:OnCreate()
    
end

function ClientTransformComponent:OnInit()
    self.TransformComponent = self.clientEntity.entity.TransformComponent

    local tag = self.clientEntity.entity.TagComponent.mainTag
    local bound,poolKey = self.world.BattleAssetsSystem:GetBound(tag)
    self.gameObject = bound
    self.transform = bound.transform

    self.bonePoolKey = poolKey

    local name = self.name or string.format("实体[uid:%s]",self.clientEntity.entity.uid)
    self.gameObject.name = name

    self.transform:SetParent(BattleDefine.nodeObjs["entity"])
    self.transform:Reset()

    self.tposeTrans = self.transform:Find("tpose")

    self.forwardTrans = self.transform:Find("forward")

    self.scaleAnimTimer = 0

    self:SyncPos()
end

function ClientTransformComponent:SetRightAxis(angle)
    self.rightAxis = Quaternion.AngleAxis(angle, Vector3.right)
end

function ClientTransformComponent:OnUpdate()
    local lerpTime = self.world.lerpTime

    local pos = self.TransformComponent.pos.vec3
	local rotation = self.TransformComponent.rotation

	local lastPos = self.TransformComponent.lastPos.vec3
	local lastRotation = self.TransformComponent.lastRotation


	-- local lastHitFlyHeight = self.transformComponent.lastHitFlyHeight
	-- local hitFlyHeight = self.transformComponent.hitFlyHeight
	-- local y = lastPosition.y + (position.y - lastPosition.y) * lerpTime
	-- local hitY = lastHitFlyHeight + (hitFlyHeight - lastHitFlyHeight) * lerpTime
	-- y = y + hitY

    local y = pos.y

    --Log("ad",pos.x,lastPos.x,pos.z,lastPos.z)

	local x = lastPos.x + (pos.x - lastPos.x) * lerpTime
    local y = lastPos.y + (pos.y - lastPos.y) * lerpTime
	local z = lastPos.z + (pos.z - lastPos.z) * lerpTime
	
	-- local offsetX1 = self.lastOffsetX.x + (self.offsetX.x - self.lastOffsetX.x) * lerpTime
	-- local offsetX3 = self.lastOffsetX.z + (self.offsetX.z - self.lastOffsetX.z) * lerpTime
    self.transform:SetPosition(x,y,z)

    if self.syncRotate then
        rotation:ToQuaternion(self.rotation)
        local renderRotation = self.rightAxis and self.rightAxis * self.rotation or self.rotation
        self.tposeTrans:SetRotation(renderRotation.x, renderRotation.y, renderRotation.z,renderRotation.w)
        
        if self.forwardTrans then
            self.forwardTrans:SetRotation(self.rotation.x, self.rotation.y, self.rotation.z,self.rotation.w)
        end
    end

    self:CheckScaleChange()
end

function ClientTransformComponent:SyncPos()
    self.TransformComponent.pos:ToVector3(self.pos)
    self.TransformComponent.rotation:ToQuaternion(self.rotation)

    self.transform:SetPosition(self.pos.x,self.pos.y,self.pos.z)

    local renderRotation = self.rightAxis and self.rightAxis * self.rotation or self.rotation
    self.tposeTrans:SetRotation(renderRotation.x, renderRotation.y, renderRotation.z,renderRotation.w)

    if self.forwardTrans then
        self.forwardTrans:SetRotation(self.rotation.x, self.rotation.y, self.rotation.z,self.rotation.w)
    end
end

function ClientTransformComponent:SetName(name)
    self.name = name
end

function ClientTransformComponent:GetPos()
	return self.transform.position
end

function ClientTransformComponent:GetRotation()
	return self.transform.rotation
end

function ClientTransformComponent:SetActive(flag)
    self.gameObject:SetActive(flag)
end

function ClientTransformComponent:CheckScaleChange()
    local targetScale = self.TransformComponent:GetScale()
    local offset = targetScale - self.scale
    if offset ~= 0 then
        self.scaleAnimTimer = self.scaleAnimTimer + Time.deltaTime
        local rate = MathUtils.Clamp( self.scaleAnimTimer / self.scaleAnimTime, 0, 1)
        self.scale = Mathf.Lerp(self.scale, targetScale, rate)
        if Mathf.Abs(targetScale - self.scale) < 5 then
            self.scale = targetScale
            self.scaleAnimTimer = 0
        end
        local scale = self.scale / FPFloat.Precision
        UnityUtils.SetLocalScale(self.transform,scale,scale,scale)
    end
end

function ClientTransformComponent:SetScale(scale)
    UnityUtils.SetLocalScale(self.transform,scale,scale,scale)
end