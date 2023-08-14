SceneUIFinder = BaseClass("SceneUIFinder",BaseTargetPosFinder)

function SceneUIFinder:__Init()

end

function SceneUIFinder:__Delete()

end

function SceneUIFinder:OnInit()

end

function SceneUIFinder:OnUpdate()
    if not RunWorld then
        return
    end

    local tag = self.posParams.tag
    local args = self.posParams
    if tag == "road" then
        args.roadIndex = self.guideAction.triggerArgs.roadIndex or args.roadIndex
    end
    local result = PlayerGuideUtils.GetSceneUI(tag,args)
    local targetTrans = result.targetTrans
    local targetObj = result.targetObj
    local worldPos = result.worldPos

    if not worldPos and not targetTrans then
        return
    end

    if not worldPos then
        worldPos = targetTrans.position
    end

    local targetPos = BaseUtils.WorldToUIPoint(BattleDefine.nodeObjs["main_camera"],worldPos)

    local targetArgs = {}
    targetArgs.targetPos = targetPos
    targetArgs.targetObj = targetObj

    self:FindPosFinish(targetArgs)
end