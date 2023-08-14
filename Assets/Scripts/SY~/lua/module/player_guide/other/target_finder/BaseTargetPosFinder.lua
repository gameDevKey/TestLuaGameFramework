BaseTargetPosFinder = BaseClass("BaseTargetPosFinder")

function BaseTargetPosFinder:__Init()
    self.guideAction = nil
    self.targetPos = nil
    self.targetTrans = nil
    self.posParams = nil
end

function BaseTargetPosFinder:__Delete()

end

function BaseTargetPosFinder:Init(guideAction)
    self.guideAction = guideAction
    self.posParams = guideAction.conf.target_pos
    self:OnInit()
end

function BaseTargetPosFinder:Update()
    self:OnUpdate()
end

function BaseTargetPosFinder:FindPosFinish(targetArgs)
    if self.posParams.offsetX then
        targetArgs.targetPos.x = targetArgs.targetPos.x + self.posParams.offsetX
    end
    if self.posParams.offsetY then
        targetArgs.targetPos.y = targetArgs.targetPos.y + self.posParams.offsetY
    end

    self.guideAction:PosFinderFinish(targetArgs)
end

--
function BaseTargetPosFinder:OnInit()
end

function BaseTargetPosFinder:OnUpdate()
end