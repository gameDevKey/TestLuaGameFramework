CollistionComponent = BaseClass("CollistionComponent",SECBComponent)
CollistionComponent.UPDATE_PRIORITY = 99
--TODO:调试此组件需要大量log，先不删很多注释的调试代码

function CollistionComponent:__Init()
    self.radius = 0
    self.runtimeRadius = 0

    self.mass = 0
    self.modelHeight = 0

    self.checkSamePos = FPVector3(0,0,0)
    self.isSamePos = false

    self.calcTargetPos = FPVector3(0,0,0)
end

function CollistionComponent:__Delete()
    self.world.BattleCollistionSystem:RemoveEntity(self.entity)
end

function CollistionComponent:OnInit()
    local scale = self.entity.ObjectDataComponent.unitConf.scale
    self.radius = FPFloat.Mul_ii(self.entity.ObjectDataComponent.unitConf.model_radius,scale)
    self.runtimeRadius = self.radius

    self.mass = self.entity.ObjectDataComponent.unitConf.mass

    self.modelHeight = FPFloat.Mul_ii(self.entity.ObjectDataComponent.unitConf.model_height,scale)

    self.world.BattleCollistionSystem:EntityAddToGrid(self.entity)

    self:AddScaleChangeListener()
end

function CollistionComponent:InitRadius()
    local scale = self.entity.ObjectDataComponent.unitConf.scale
    self.radius = FPFloat.Mul_ii(self.entity.ObjectDataComponent.unitConf.model_radius,scale)
    self.runtimeRadius = self.radius
end

function CollistionComponent:SetRadius(radius)
    self.radius = radius
    self.runtimeRadius = self.radius
end

function CollistionComponent:GetRadius()
    return self.runtimeRadius
end

function CollistionComponent:ResetRadius()
    self.runtimeRadius = self.radius
end

function CollistionComponent:OnLateInit()
    self.entity.TransformComponent:AddMoveListener(self:ToFunc("OnTransform"))
    --self:SetEnable(false)
end

function CollistionComponent:OnTransform()
    self.world.BattleCollistionSystem:EntityAddToGrid(self.entity)
end

function CollistionComponent:CanCollistion(entity)
	if not entity.StateComponent then
		return false
	end

    if not entity.CollistionComponent or not entity.CollistionComponent.enable or entity.CollistionComponent.mass <= 0 then
        return false
    end

    if not self.entity.ObjectDataComponent:IsSameWalkType(entity.ObjectDataComponent:GetWalkType()) then
        return false
    end

    return true
end

function CollistionComponent:OnLateUpdate()
    if self.entity.isUidSingle ~= self.world.isSingleFrame then
        return
    end

    if self.mass <= 0 then
        return
    end

    local fromPos = self.entity.TransformComponent:GetPos()
    local toPos = self.entity.TransformComponent.toPos

    if toPos == fromPos then
        return
    end

    if self.checkSamePos ~= FPVector3.zero and (self.checkSamePos - fromPos).magnitude <= FPFloat.Fix then
        self.isSamePos = true
    else
        self.isSamePos = false
    end
    self.checkSamePos:SetByFPVector3(fromPos)

    local beginGrid = self.world.BattleCollistionSystem:PosToGrid(toPos.x - self.runtimeRadius,toPos.z + self.runtimeRadius)
    local endGrid = self.world.BattleCollistionSystem:PosToGrid(toPos.x + self.runtimeRadius,toPos.z - self.runtimeRadius)
    local entityGroups = self.world.BattleCollistionSystem:GetRangeEntitys(beginGrid,endGrid)

    local tempEntitys = {}
    for i,entityGroup in ipairs(entityGroups) do
        for v in entityGroup:Items() do
            local uid = v.value
            if not tempEntitys[uid] then
                tempEntitys[uid] = true
                local entity = self.world.EntitySystem:GetEntity(uid)
                if entity and uid ~= self.entity.uid and self:CanCollistion(entity) then
                    self:CheckCollistionVector(fromPos,toPos,entity)
                end
            end
        end
    end


end

function CollistionComponent:CheckCollistionVector(from,to,checkEntity)
    self.calcTargetPos:SetByFPVector3(checkEntity.TransformComponent:GetPos())
    self.calcTargetPos.y = to.y
	local targetPos = self.calcTargetPos
    

    local targetRadius = checkEntity.CollistionComponent:GetRadius()

    local fromDis = self:GetDistance(from,targetPos)

    local targetDis = self:GetDistance(to,targetPos)

    --远离
    if targetDis > fromDis then
        return
    end

    if targetDis >= self.runtimeRadius + targetRadius then
        return
    end

    local newDis = math.abs(self.runtimeRadius + targetRadius - targetDis)

    local steeringForce = (to - targetPos):NormalizeTo(newDis)

    local diffMass = self.mass - checkEntity.CollistionComponent.mass

    if diffMass > 0 then
        local ratio = FPFloat.Div_ii(diffMass,checkEntity.CollistionComponent.mass)
        if ratio >= 1000 then
            checkEntity.TransformComponent:AddSteeringForce(-steeringForce.x,-steeringForce.y,-steeringForce.z)
        else
            steeringForce:NormalizeTo(FPFloat.Mul_ii(newDis,1000 - ratio))
            self.entity.TransformComponent:AddSteeringForce(steeringForce.x,steeringForce.y,steeringForce.z)

            steeringForce:NormalizeTo(FPFloat.Mul_ii(newDis,ratio))
            checkEntity.TransformComponent:AddSteeringForce(-steeringForce.x,-steeringForce.y,-steeringForce.z)
        end
    elseif diffMass < 0 then
        if checkEntity.StateComponent:IsState(BattleDefine.EntityState.move) then
            self.entity.TransformComponent:AddSteeringForce(steeringForce.x,steeringForce.y,steeringForce.z)
        else
            local ratio = FPFloat.Div_ii(-diffMass,checkEntity.CollistionComponent.mass)
            if self.isSamePos and ratio <= 300 then
                steeringForce:NormalizeTo(FPFloat.Mul_ii(newDis,1000 - 300))
                self.entity.TransformComponent:AddSteeringForce(steeringForce.x,steeringForce.y,steeringForce.z)

                steeringForce:NormalizeTo(FPFloat.Mul_ii(newDis,300))
                checkEntity.TransformComponent:AddSteeringForce(-steeringForce.x,-steeringForce.y,-steeringForce.z)
            else
                local toDir = (to - from):Normalize()
                local d = FPVector3.Dot(toDir,-steeringForce.normalized)

                self.entity.TransformComponent:AddSteeringForce(steeringForce.x,steeringForce.y,steeringForce.z)
                if d >= 1000 - FPFloat.Fix and d <= 1000 + FPFloat.Fix then
                    local right = FPVector3.Cross(FPVector3.up,toDir)
                    right:NormalizeTo(newDis)
                    self.entity.TransformComponent:AddSteeringForce(right.x,right.y,right.z)
                end
            end
        end
    else
        local toDir = (to - from):Normalize()
        local d = FPVector3.Dot(toDir,-steeringForce.normalized)

        if checkEntity.StateComponent:IsState(BattleDefine.EntityState.move) then
            self.entity.TransformComponent:AddSteeringForce(steeringForce.x,steeringForce.y,steeringForce.z)
            if d >= 1000 - FPFloat.Fix and d <= 1000 + FPFloat.Fix then
                local left = -FPVector3.Cross(FPVector3.up,toDir)
                left:NormalizeTo(newDis)
                self.entity.TransformComponent:AddSteeringForce(left.x,left.y,left.z)
            end
        else
            if self.isSamePos then
                steeringForce:NormalizeTo(FPFloat.Mul_ii(newDis,1000 - 500))
                self.entity.TransformComponent:AddSteeringForce(steeringForce.x,steeringForce.y,steeringForce.z)

                steeringForce:NormalizeTo(FPFloat.Mul_ii(newDis,500))
                checkEntity.TransformComponent:AddSteeringForce(-steeringForce.x,-steeringForce.y,-steeringForce.z)
            else
                self.entity.TransformComponent:AddSteeringForce(steeringForce.x,steeringForce.y,steeringForce.z)
                if d >= 1000 - FPFloat.Fix and d <= 1000 + FPFloat.Fix then
                    local right = FPVector3.Cross(FPVector3.up,toDir)
                    right:NormalizeTo(newDis)
                    self.entity.TransformComponent:AddSteeringForce(right.x,right.y,right.z)
                end
            end
        end
    end
end

function CollistionComponent:GetDistance(from,to)
	local x1 = from.x
	local y1 = from.z
	local x2 = to.x
	local y2 = to.z
    return FPMath.Sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
end

function CollistionComponent:AddScaleChangeListener()
    local params = {}
    params.entityUid = self.entity.uid
    self.world.EventTriggerSystem:AddListener(BattleEvent.unit_scale_change,self:ToFunc("OnUnitScaleChange"),params)
end

function CollistionComponent:OnUnitScaleChange()
    self.runtimeRadius = FPMath.Divide(self.radius * self.entity.TransformComponent:GetScale(),FPFloat.Precision)
end