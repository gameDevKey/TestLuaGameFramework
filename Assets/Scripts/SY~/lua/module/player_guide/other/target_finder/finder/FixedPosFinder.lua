FixedPosFinder = BaseClass("FixedPosFinder",BaseTargetPosFinder)

function FixedPosFinder:__Init()

end

function FixedPosFinder:__Delete()

end

function FixedPosFinder:OnInit()

end

function FixedPosFinder:OnUpdate()
    local targetArgs = {}
    targetArgs.targetPos = Vector2(self.posParams.x,self.posParams.y)

    self:FindPosFinish(targetArgs)
end