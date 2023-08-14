BattleRoundResultPanel = BaseClass("BattleRoundResultPanel",BaseView)

BattleRoundResultPanel.Event = EventEnum.New(
)

function BattleRoundResultPanel:__Init()
	self:SetAsset("ui/prefab/battle/battle_round_result_panel.prefab")
    self.countdownTimer = nil
    self.time = 0
end

function BattleRoundResultPanel:__ExtendView()

end

function BattleRoundResultPanel:__CacheObject()

end

function BattleRoundResultPanel:__BindListener()

end

function BattleRoundResultPanel:__Show()
    local battleResultData = RunWorld.BattleDataSystem.battleResultData
    local isWin = RunWorld.BattleMixedSystem:IsSelfCamp(battleResultData.win_camp)

    if isWin then
        self:Find("main/win_title").gameObject:SetActive(true)
        self:Find("main/lose_title").gameObject:SetActive(false)
    else
        self:Find("main/win_title").gameObject:SetActive(false)
        self:Find("main/lose_title").gameObject:SetActive(true)
        UIUtils.Grey(self:Find("main/lose_title",Image),true)
    end


    local roundResultData = RunWorld.BattleDataSystem.roundResultData
    local remainTime = Network.Instance:GetRemoteRemainTime(roundResultData.show_end_time)
    Log("结算剩余秒数",remainTime,roundResultData.show_end_time)

    self.time = 2
    self.countdownTimer = TimerManager.Instance:AddTimer(self.time,1,self:ToFunc("RefreshCloseTime"))
end

function BattleRoundResultPanel:__Hide()
    self:RemoveCountdownTimer()
end

function BattleRoundResultPanel:RefreshCloseTime()
    self.time = self.time - 1
    if self.time <= 0 then
        self.countdownTimer = nil
        self:CloseClick()
        mod.BattleFacade:SendEvent(BattleMainPanel.Event.ActiveSelectRewardPanel,true)
    end
end

function BattleRoundResultPanel:RemoveCountdownTimer()
    if self.countdownTimer then
        TimerManager.Instance:RemoveTimer(self.countdownTimer)
        self.countdownTimer = nil
    end
end

function BattleRoundResultPanel:CloseClick()
    self:Hide()
end