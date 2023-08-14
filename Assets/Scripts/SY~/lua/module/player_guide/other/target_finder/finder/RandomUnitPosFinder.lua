RandomUnitPosFinder = BaseClass("RandomUnitPosFinder",BaseTargetPosFinder)

function RandomUnitPosFinder:__Init()
    self.findOutArgs = {}
end

function RandomUnitPosFinder:__Delete()

end

function RandomUnitPosFinder:OnInit()

end

function RandomUnitPosFinder:OnUpdate()
    if not RunWorld then
        return
    end

    mod.BattleFacade:SendEvent(BattleSelectHeroView.Event.GetRandomUnitObj,self.posParams.unitId,self.findOutArgs)

    if not self.findOutArgs.targetObj then
        return
    end

    local objRectTrans = self.findOutArgs.targetObj:GetComponent(RectTransform)

    local targetPos = UIUtils.GetLocalPos(PlayerGuideDefine.contentTrans,objRectTrans)

    local targetArgs = {}
    targetArgs.targetPos = targetPos
    targetArgs.targetObj = self.findOutArgs.targetObj

    self:FindPosFinish(targetArgs)
end