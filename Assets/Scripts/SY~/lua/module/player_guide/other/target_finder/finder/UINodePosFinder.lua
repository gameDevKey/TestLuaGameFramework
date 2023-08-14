UINodePosFinder = BaseClass("UINodePosFinder",BaseTargetPosFinder)

function UINodePosFinder:__Init()

end

function UINodePosFinder:__Delete()

end

function UINodePosFinder:OnInit()

end

function UINodePosFinder:OnUpdate()
    local targetObj
    if self.posParams.path then
        targetObj = mod.PlayerGuideUINodeCtrl:GetUIObj(self.posParams.path)
    elseif self.posParams.pathKey then
        targetObj = mod.PlayerGuideUINodeCtrl:GetUIObjByPathKey(self.posParams.pathKey)
    end
    if not targetObj or not targetObj.activeInHierarchy then
        return
    end

    --PlayerGuideUINodeCtrl:GetUIObj(name,path)

    local targetPos = UIUtils.GetLocalPos(PlayerGuideDefine.contentTrans,targetObj.transform)

    local targetArgs = {}
    targetArgs.targetObj = targetObj
    targetArgs.targetPos = targetPos

    self:FindPosFinish(targetArgs)
end