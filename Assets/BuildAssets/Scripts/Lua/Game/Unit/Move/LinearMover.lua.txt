LinearMover = Class("LinearMover",MoverBase)

--- args = { targetPos, speed }
function LinearMover:OnInit()

end

function LinearMover:OnDelete()
end

function LinearMover:OnStart()

end

function LinearMover:OnStop()

end

function LinearMover:OnUpdate(deltaTime)
    local curPos = self.entity.TransformComponent:GetPosVec3()
    local targetPos = self.args.targetPos
    local deltaPos = targetPos - curPos
    if deltaPos.magnitude <= 1 then
        self.entity.TransformComponent:SetPosVec3(targetPos)
        self:Finish()
        return
    end
    local offsetPos = deltaPos * deltaTime * self.args.speed
    local newPos = curPos + offsetPos
    self.entity.TransformComponent:SetPosVec3(newPos)
    PrintLog("LinearMover:OnUpdate",newPos)
end

return LinearMover