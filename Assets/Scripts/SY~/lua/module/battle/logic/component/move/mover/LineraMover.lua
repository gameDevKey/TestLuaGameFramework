LineraMover = BaseClass("LineraMover",MoverBase)

function LineraMover:__Init()
end

function LineraMover:__Delete()
end

function LineraMover:OnInit()
end

function LineraMover:OnUpdate()
    local toTarget = self.targetPos - self.entity.TransformComponent.pos
    local dis = toTarget.magnitude

    local speed = nil
    if self.params then
        speed = self.params.speed
    end
    if not speed and self.entity.AttrComponent then
        speed = self.entity.AttrComponent:GetValue(GDefine.Attr.move_speed)
    end
    
    local moveLen = FPFloat.Mul_ii(speed,self.world.opts.frameDeltaTime)

    local x,y,z = 0,0,0

    local flag = false
    if moveLen >= dis then
        x = toTarget.x
        y = toTarget.y
        z = toTarget.z
        flag = true
    else
        toTarget:Normalize()
        x = FPFloat.Mul_ii(toTarget.x , moveLen)
        y = FPFloat.Mul_ii(toTarget.y , moveLen)
        z = FPFloat.Mul_ii(toTarget.z , moveLen)
    end

    self.entity.MoveComponent:SetPosOffset(x,y,z)

    if flag then
        self:MoveComplete()
    end
end

function LineraMover:MoveComplete()
    self:CallComplete()
end