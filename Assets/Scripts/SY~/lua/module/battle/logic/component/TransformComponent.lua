TransformComponent = BaseClass("TransformComponent",SECBTransformComponent)
TransformComponent.UPDATE_PRIORITY = 101

function TransformComponent:__Init()
    self.moveListeners = SECBList.New()
    self.velocity = FPVector3(0,0,0)
    self.steeringForce = FPVector3(0,0,0)
    self.maxSteeringForce = 100
    self.toPos = FPVector3(0,0,0)
end

function TransformComponent:__Delete()
    self.moveListeners:Delete()
end

function TransformComponent:AddMoveListener(callBack)
    self.moveListeners:Push(callBack)
end

function TransformComponent:OnPos()
    for iter in self.moveListeners:Items() do
        iter.value()
    end
end

function TransformComponent:OnScale()
    self.world.EventTriggerSystem:Trigger(BattleEvent.unit_scale_change,self.entity.uid)
end

-- function TransformComponent:OnInit()
--     self.toPos:SetByFPVector3(self.pos)
-- end

function TransformComponent:PreUpdate()
    self:OnPreUpdate()
    if self.toPos ~= self.pos then
        self.toPos:SetByFPVector3(self.pos)
    end

    -- if self.entity.uid == 5 then
    --     Log("进入这里了11",self.entity.uid,self.toPos.x,self.toPos.y,self.toPos.z)
    -- end
end

function TransformComponent:AddVelocity(x,y,z)
    self.velocity.x = self.velocity.x + x
    self.velocity.y = self.velocity.y + y
    self.velocity.z = self.velocity.z + z
    self:UpdateToPos()
end

function TransformComponent:AddSteeringForce(x,y,z)
    self.steeringForce.x = self.steeringForce.x + x
    self.steeringForce.y = self.steeringForce.y + y
    self.steeringForce.z = self.steeringForce.z + z
    self:UpdateToPos()
end

function TransformComponent:UpdateToPos()
    self.toPos.x = self.pos.x + self.velocity.x + self.steeringForce.x
    self.toPos.y = self.pos.y + self.velocity.y + self.steeringForce.y
    self.toPos.z = self.pos.z + self.velocity.z + self.steeringForce.z
end

function TransformComponent:OnLateUpdate()
    local x,y,z = 0,0,0

    if self.velocity ~= FPVector3.zero then
        x = x + self.velocity.x
        y = y + self.velocity.y
        z = z + self.velocity.z
        self.velocity:Set(0,0,0)
    end

    if self.steeringForce ~= FPVector3.zero then
        if self.steeringForce.magnitude > self.maxSteeringForce then
            self.steeringForce:NormalizeTo(self.maxSteeringForce)
        end
        x = x + self.steeringForce.x
        y = y + self.steeringForce.y
        z = z + self.steeringForce.z
        self.steeringForce:Set(0,0,0)
    end

    if x ~= 0 or y ~= 0 or z ~= 0 then
        self:SetPosByOffset(x,y,z)
        self.world.EventTriggerSystem:Trigger(BattleEvent.unit_moved,self.entity.uid)
    end
end