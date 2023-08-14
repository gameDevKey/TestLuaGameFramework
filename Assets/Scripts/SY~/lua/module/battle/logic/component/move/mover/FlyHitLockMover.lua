FlyHitLockMover = BaseClass("FlyHitLockMover",MoverBase)

function FlyHitLockMover:__Init()
    self.beginPos = FPVector3(0,0,0)
    self.moveMaxTime = 0
    self.curTime = 0
    self.targetUid = 0
end

function FlyHitLockMover:__Delete()
end

function FlyHitLockMover:OnInit()
end

function FlyHitLockMover:OnMove()
    --TODO:仔细检查是否会收到渲染影响
    self.curTime = 0

    self.targetUid = self.params.targetUid

    local targetPos = nil
    if self.targetUid then
        local targetEntity = self.world.EntitySystem:GetEntity(self.targetUid)
        targetPos = targetEntity.TransformComponent:GetPos()
        self:SetRenderTargetPos()
    else
        targetPos = FPVector3(self.params.targetPos.posX,self.params.targetPos.posY or 0,self.params.targetPos.posZ)
        self:SetTargetPos(targetPos.x,targetPos.y,targetPos.z)
    end

    local curPos = self.entity.TransformComponent:GetPos()
    self.beginPos:SetByFPVector3(curPos)

    local toTarget = targetPos - self.params.logicPos
    local dis = toTarget.magnitude
    self.moveMaxTime = FPFloat.Div_ii(dis,self.params.speed)
    if self.moveMaxTime <= 0 then self.moveMaxTime = 100 end
    --Log("时间",self.moveMaxTime)
end

function FlyHitLockMover:OnUpdate()
    local lerp = FPFloat.Div_ii(self.curTime,self.moveMaxTime)
    if lerp > 1000 then lerp = 1000 end

    self:SetTransTransform(lerp)
    --TODO:临时,实现了FromToRotation同步修改ClientTransformComponent

    self.curTime = self.curTime + self.world.opts.frameDeltaTime

    if lerp >= 1000 then
        self:MoveComplete()
    end
end

function FlyHitLockMover:SetTransTransform(lerp)
    if not self.world.opts.isClient then
        return
    end

    self:SetRenderTargetPos()

    local pos =  FPVector3.Lerp(self.beginPos, self.targetPos, lerp)
    self.entity.TransformComponent:SetFixedPos(pos.x,pos.y,pos.z)

    local diff =  self.targetPos - pos
    local targetRotate = FPQuaternion.LookRotation(FPVector3(diff.x,diff.y,diff.z))
    --local curRotate = self.entity.TransformComponent:GetRotation()
    --local newRotate = FPQuaternion.Lerp(curRotate,targetRotate,1000)

    self.entity.TransformComponent:SetRotation(targetRotate)
end

function FlyHitLockMover:SetRenderTargetPos()
    if not self.world.opts:IsClient() then
        return
    end

    local targetEntity = self.world.EntitySystem:GetEntity(self.targetUid)
    if not targetEntity then
        return
    end

    local renderPos,_ = self.world.ClientIFacdeSystem:Call("GetBoneTransInfo",targetEntity,GDefine.Bone.chest)
    local pos = FPVector3(0,0,0)
    FPMath.ToFPVector3(renderPos,pos)

    self:SetTargetPos(pos.x,pos.y,pos.z)
end

function FlyHitLockMover:MoveComplete()
    self:CallComplete()
end