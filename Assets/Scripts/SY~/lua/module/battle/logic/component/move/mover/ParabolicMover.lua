ParabolicMover = BaseClass("ParabolicMover",MoverBase)

function ParabolicMover:__Init()
    self.beginPos = FPVector3(0,0,0)
    self.moveMaxTime = 0
    self.curTime = 0
    self.targetUid = 0
end

function ParabolicMover:__Delete()
end

function ParabolicMover:OnInit()
end

--[[
    self.params = {}
    self.params.logicPos      -- 逻辑位置 当前位置
    self.params.targetUid     -- 目标Uid
    self.params.targetPos     -- 目标位置
    self.params.targetPos = { posX, posY, posZ}
    self.params.maxHeight     -- 最大高度
    self.params.moveMaxTime   -- 移动时间
    self.params.speed         -- 平面移动时间
]]
function ParabolicMover:OnMove()
    --TODO:仔细检查是否会受到渲染影响

    if self.entity.CollistionComponent then
        self.entity.CollistionComponent:SetEnable(false)
    end

    self.curTime = 0

    local curPos = self.params.logicPos
    self.beginPos:SetByFPVector3(curPos)

    self.targetUid = self.params.targetUid
    local targetPos = nil
    if self.targetUid then
        local targetEntity = self.world.EntitySystem:GetEntity(self.targetUid)
        targetPos = targetEntity.TransformComponent:GetPos()
    else
        targetPos = FPVector3(self.params.targetPos.posX,self.params.targetPos.posY or 0,self.params.targetPos.posZ)
    end
    self:SetTargetPos(targetPos.x,targetPos.y,targetPos.z)

    local toTarget = targetPos - curPos
    local dis = toTarget.magnitude

    local midDis = FPFloat.Div_ii(dis,2 * FPFloat.Precision)
    local dir = toTarget:Normalize()
    self.centerPos = FPVector3(FPFloat.Mul_ii(dir.x,midDis) + curPos.x, FPFloat.Div_ii(self.params.maxHeight,FPFloat.Precision), FPFloat.Mul_ii(dir.z,midDis) + curPos.z)

    if self.params.moveMaxTime then
        self.moveMaxTime = self.params.moveMaxTime
    elseif self.params.speed then
        self.moveMaxTime = FPFloat.Div_ii(dis,self.params.speed)
    else
        self.moveMaxTime = 100
    end
    if self.moveMaxTime <= 0 then self.moveMaxTime = 100 end
end

function ParabolicMover:OnUpdate()
    local lerp = FPFloat.Div_ii(self.curTime,self.moveMaxTime)
    if lerp > 1000 then lerp = 1000 end

    self:SetTransTransform(lerp)
    self:CallUpdate(lerp)

    self.curTime = self.curTime + self.world.opts.frameDeltaTime

    if lerp >= 1000 then
        self:MoveComplete()
    end
end

function ParabolicMover:SetTransTransform(lerp)
    local pos =  BattleUtils.Curve2(self.beginPos, self.centerPos ,self.targetPos, lerp)
    self.entity.TransformComponent:SetFixedPos(pos.x,pos.y,pos.z)
end

function ParabolicMover:MoveComplete()
    if self.entity.CollistionComponent then
        self.entity.CollistionComponent:SetEnable(true)
    end
    self:CallComplete()
end