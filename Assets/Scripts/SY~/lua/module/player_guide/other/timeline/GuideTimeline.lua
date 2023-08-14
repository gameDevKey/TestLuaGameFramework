GuideTimeline = BaseClass("GuideTimeline",LTimeline)

function GuideTimeline:__Init()
    self:SetNodeIndexs(PlayerGuideDefine.GuideTimeline)
    self.targetArgs = nil
    self.guideAction = nil
    self.guideNodes = {}
end

function GuideTimeline:__Delete()
end

function GuideTimeline:OnUpdate()
    for _, node in ipairs(self.guideNodes) do
        node:Update()
    end
end

function GuideTimeline:RestartNode(tpe)
    for _, node in ipairs(self.guideNodes) do
        if node.actionParam.type == tpe then
            node:Init(self,node.actionParam)
            node:Start()
            return true
        end
    end
    return false
end

function GuideTimeline:SetTargetArgs(targetArgs)
    self.targetArgs = targetArgs
end

function GuideTimeline:SetGuideAction(guideAction)
    self.guideAction = guideAction
end

function GuideTimeline:BattlePause(params)
    local node = BattlePauseGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:BubbleMsg(params)
    local node = BubbleMsgGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:ImageBubbleMsg(params)
    local node = ImageBubbleMsgGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:RoleDialogue(params)
    local node = RoleDialogueGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:LockScreen(params)
    local node = LockScreenGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:ScreenAnyClick(params)
    local node = ScreenAnyClickGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:ClickObj(params)
    local node = ClickObjGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:BeginGroupFinish(params)
    local node = BeginGroupFinishGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:CaptureBridgeBubbleMsg(params)
    local node = CaptureBridgeBubbleMsgGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:AddMoney(params)
    local roleUid = RunWorld.BattleDataSystem.roleUid

    if params.addMoney ~= 0 then
        RunWorld.BattleDataSystem:AddRoleMoney(roleUid,params.addMoney)
    end

    local curMoney = RunWorld.BattleDataSystem:GetRoleMoney(roleUid)

    if params.toMoney >= 0 then
        RunWorld.BattleDataSystem:AddRoleMoney(roleUid,params.toMoney - curMoney)
    end

    mod.BattleFacade:SendEvent(BattleInfoView.Event.RefreshMoney)
end


function GuideTimeline:ClickRandomUnit(params)
    local node = ClickRandomUnitGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:ClickUnlockGrid(params)
    local node = ClickUnlockGridGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end


function GuideTimeline:RoleToMoney(params)
    local node = RoleToMoneyGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:AnyClickBubbleMsg(params)
    local node = AnyClickBubbleMsgGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:ClickOpenUnitTips(params)
    local node = ClickOpenUnitTipsGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:CloseBattleUnitTips(params)
    mod.BattleFacade:SendEvent(BattleSelectHeroView.Event.ActiveUnitDetails,false)
end

function GuideTimeline:DragUseMagicCard(params)
    local node = DragUseMagicCardGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:ShowRestrainView(params)
    local node = ShowRestrainViewGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:SwapUnitGrid(params)
    local node = SwapUnitGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:AddRage(params)
    local roleUid = RunWorld.BattleDataSystem.roleUid

    if params.addRage ~= 0 then
        RunWorld.BattleCommanderSystem:AddRage(roleUid,params.addRage)
    end

    local curRage = RunWorld.BattleCommanderSystem:GetRage(roleUid)

    if params.toRage >= 0 then
        RunWorld.BattleCommanderSystem:AddRage(roleUid,params.toRage - curRage)
    end
    --mod.BattleFacade:SendEvent(BattleInfoView.Event.RefreshMoney)
end

function GuideTimeline:DragUseRageSkill(params)
    local node = DragUseRageSkillGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:DragUsePveSkill(params)
    local node = DragUsePveSkillGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:TriggerGuide(params)
    local node = TriggerGuideGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:PlayUIEffect(params)
    local node = PlayUIEffectGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:PlaySceneEffect(params)
    local node = PlaySceneEffectGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:PlayScaleAnim(params)
    local node = ScaleAnimGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:ResetBattle(params)
    local node = BattleResetGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:ShowHoleMask(params)
    local node = HoleMaskGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:OpenView(params)
    local node = OpenViewGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:LogForDebug(params)
    if params and params.msg then
        LogTable("GuideTimeline:LogForDebug",params.msg)
    else
        print("GuideTimeline:LogForDebug")
    end
end

function GuideTimeline:ScrollTo(params)
    local node = ScrollGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:Highlight(params)
    local node = HighlightGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:OpenSelectTips(params)
    BattleDefine.openSelectTips = params.flag
end

function GuideTimeline:AddUnitStar(params)
    local roleUid = RunWorld.BattleDataSystem.roleUid

    local unitData = RunWorld.BattleDataSystem:GetUnitData(roleUid,params.unitId)
    if not unitData then
        assert(false,string.format("操作台不存在单位[单位Id:%s]",tostring(params.unitId)))
    end

    local curStar = unitData.star
    if params.addStar ~= 0 then
        RunWorld.BattleMixedSystem:UpdateUnit(roleUid,params.unitId,unitData.grid_id,curStar + params.addStar)
    end

    if params.toStar >= 0 then
        RunWorld.BattleMixedSystem:UpdateUnit(roleUid,params.unitId,unitData.grid_id,params.toStar)
    end
end

function GuideTimeline:ResetPvpBattleState(params)
    local node = ResetPvpBattleStateGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:PausePveAutoSelectLogic(params)
    local node = PausePveAutoSelectGuideNode.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:PausePvpResultWindowPopup(params)
    local node = PausePvpResultWindowPopup.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:ResumePvpResultWindowPopup(params)
    local node = ResumePvpResultWindowPopup.New()
    node:Init(self,params)
    node:Start()
    table.insert(self.guideNodes,node)
end

function GuideTimeline:EnableSaleCardLogic(params)
    -- mod.BattleFacade:SendEvent(BattleHeroOperateView.Event.EnableSaleCard,params.flag)--TODO 2dUI
    if StringUtils.IsEmpty(params.tips) then
        -- mod.BattleFacade:SendEvent(BattleHeroOperateView.Event.AddSaleCardCallback, nil)
    else
        -- mod.BattleFacade:SendEvent(BattleHeroOperateView.Event.AddSaleCardCallback, function (index,success)
        --     if not success then
        --         SystemMessage.Show(params.tips)
        --     end
        -- end)
    end
end

function GuideTimeline:EnableSurrender(params)
    mod.BattleFacade:SendEvent(BattleFacade.Event.EnableSurrender,params.flag)
    if StringUtils.IsEmpty(params.tips) then
        mod.BattleFacade:SendEvent(BattleFacade.Event.AddSurrenderCallback, nil)
    else
        mod.BattleFacade:SendEvent(BattleFacade.Event.AddSurrenderCallback, function (success)
            if not success then
                SystemMessage.Show(params.tips)
            end
        end)
    end
end

function GuideTimeline:ChangeReserveIndex(params)
    RunWorld.BattleReserveUnitSystem.reserveIndex = params.index
end

function GuideTimeline:OnDestroy()
    for _,v in ipairs(self.guideNodes) do
        v:Destroy()
        v:Delete()
    end
    self.guideNodes = {}
    self:Delete()
end