DynamicUINodeFinder = BaseClass("DynamicUINodeFinder",BaseTargetPosFinder)

function DynamicUINodeFinder:__Init()
end

function DynamicUINodeFinder:__Delete()

end

function DynamicUINodeFinder:OnInit()

end

function DynamicUINodeFinder:OnUpdate()
    local tag = self.posParams.tag
    local id = self.posParams.id
    if tag == "card_lib" then
        mod.BackpackFacade:SendEvent(BackpackCardView.Event.GetCardLibrayPos, id, self:ToFunc("OnFindTarget"))
    end
    if tag == "card_config" then
        mod.BackpackFacade:SendEvent(BackpackCardView.Event.GetCardConfigPos, id, self:ToFunc("OnFindTarget"))
    end
    if tag == "division_reward" then
        mod.DivisionFacade:SendEvent(RankWindow.Event.GetGuideDivisionRewardPos, self.posParams, self:ToFunc("OnFindTarget"))
    end
    if tag == "division" then
        mod.DivisionFacade:SendEvent(RankWindow.Event.GetGuideDivisionPos, self.posParams, self:ToFunc("OnFindTarget"))
    end
    if tag == "division_unlock" then
        mod.DivisionFacade:SendEvent(RankWindow.Event.GetGuideDivisionUnlockCardPos, self.posParams, self:ToFunc("OnFindTarget"))
    end
    if tag == "battlepass_reward" then
        mod.BattlepassFacade:SendEvent(BattlepassWindow.Event.GetGuideBattlepassRewardPos, id, self:ToFunc("OnFindTarget"))
    end
    if tag == "pve_skill_item" then
        mod.BattleFacade:SendEvent(BattlePveItemView.Event.GetSkillBtn, self.posParams, self:ToFunc("OnFindTarget"))
    end
end

function DynamicUINodeFinder:GetTargetPos(currentTran,targetParent)
    local originParent = currentTran.parent
    currentTran:SetParent(targetParent,true)
    local pos = currentTran.anchoredPosition
    currentTran:SetParent(originParent,true)
    return pos
end

function DynamicUINodeFinder:ConvertToCenterPos(pos)
    return Vector2(pos.x - Screen.width/2, pos.y + Screen.height/2)
end

function DynamicUINodeFinder:OnFindTarget(rootTransform,clickTransform)
    if not rootTransform or not clickTransform then
        return
    end
    local targetArgs = {}
    -- local pos = BaseUtils.WorldToUIPoint(UIDefine.uiCamera, rootTransform.transform.position)
    local pos = UIUtils.GetLocalPos(PlayerGuideDefine.contentTrans,rootTransform)
    targetArgs.targetPos = Vector2(pos.x, pos.y)
    targetArgs.targetObj = clickTransform.gameObject
    self:FindPosFinish(targetArgs)
end