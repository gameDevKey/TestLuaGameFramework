SceneObjFinder = BaseClass("SceneObjFinder",BaseTargetPosFinder)

function SceneObjFinder:__Init()

end

function SceneObjFinder:__Delete()

end

function SceneObjFinder:OnInit()

end

function SceneObjFinder:OnUpdate()
    if not RunWorld then
        return
    end

    local tag = self.posParams.tag
    local objs = PlayerGuideUtils.GetSceneObject(tag,self.posParams)

    if #objs <= 0 then
        return
    end

    local firstObj = objs[1]

    local targetPos = BaseUtils.WorldToUIPoint(BattleDefine.nodeObjs["main_camera"],firstObj.transform.position)

    local targetArgs = {}
    targetArgs.targetPos = targetPos
    targetArgs.targetObj = firstObj
    targetArgs.targetObjs = objs

    self:FindPosFinish(targetArgs)
end