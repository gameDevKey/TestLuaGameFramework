BattleResultSystem = BaseClass("BattleResultSystem",SECBOperationSystem)

function BattleResultSystem:__Init()
    self.resultData = nil
    self.resultFrame = 0
    self.timeoutTimer = nil
    self.resultPerformFinish = false
    self.canShowResultWin = true
end

function BattleResultSystem:__Delete()
    self:RemoveTimeoutTimer()
end

function BattleResultSystem:OnLateInitSystem()
    self.world.EventTriggerSystem:AddListener(BattleEvent.be_home_hit,self:ToFunc("BeHomeHit"))
    self.world.EventTriggerSystem:AddListener(BattleEvent.unit_die,self:ToFunc("CheckSoloHeroDie"))
end

function BattleResultSystem:BeHomeHit(homeUid)
    if not self.world.BattleStateSystem:IsBattleResult(BattleDefine.BattleResult.none) then
        return
    end
    
    local homeEntity = self.world.EntitySystem:GetEntity(homeUid)

    local hp = homeEntity.AttrComponent:GetValue(BattleDefine.Attr.hp)
    if hp > 0 then 
        return
    end

    local selfCamp = self.world.BattleMixedSystem:IsSelfCamp(homeEntity.CampComponent.camp)

    local pvpResult = nil
    if selfCamp then
        pvpResult = BattleDefine.BattleResult.lose
    else
        pvpResult = BattleDefine.BattleResult.win
    end

    self:OverResult(pvpResult)

    --self.world.BattleStateSystem:SetBattleResult(pvpResult)

    --Log("战斗结果",pvpResult)
end

function BattleResultSystem:CheckSoloHeroDie(eventParams)
    if not self.world.BattleStateSystem:IsBattleResult(BattleDefine.BattleResult.none) then
        return
    end

    if not self.world.BattleStateSystem:IsBattleState(BattleDefine.BattleState.solo_battle) then
        return
    end
    
    
    local dieEntity = self.world.EntitySystem:GetEntity(eventParams.dieEntityUid)

    local attackCampNum = self.world.EntitySystem:GetEntityNumByCamp(BattleDefine.Camp.attack)
    local defenceCampNum = self.world.EntitySystem:GetEntityNumByCamp(BattleDefine.Camp.defence)

    if attackCampNum > 0 and defenceCampNum > 0 then
        return
    end

    local winCamp = nil

    if attackCampNum <= 0 and defenceCampNum <= 0 then
        winCamp = dieEntity.CampComponent:GetCamp()
    elseif attackCampNum <= 0 then
        winCamp = BattleDefine.Camp.defence
    elseif defenceCampNum <= 0 then
        winCamp = BattleDefine.Camp.attack
    end

    local selfCamp = self.world.BattleMixedSystem:IsSelfCamp(winCamp)

    local pvpResult = nil
    if selfCamp then
        pvpResult = BattleDefine.BattleResult.win
    else
        pvpResult = BattleDefine.BattleResult.lose
    end

    self:OverResult(pvpResult)
    --self.world.BattleStateSystem:SetBattleResult(pvpResult)
end

function BattleResultSystem:Surrender()
    self.world.BattleStateSystem:SetSurrender(true)
    mod.BattleFacade:SendMsg(10411)
end

function BattleResultSystem:SurrenderResult(winCamp)
    local selfCamp = self.world.BattleMixedSystem:IsSelfCamp(winCamp)

    local pvpResult = nil
    if selfCamp then
        pvpResult = BattleDefine.BattleResult.win
    else
        pvpResult = BattleDefine.BattleResult.lose
    end

    self:OverResult(pvpResult)
    self:CheckImmedResult()
end

function BattleResultSystem:CheckImmedResult()
    if self.resultData and self.world.BattleFrameSyncSystem.frame <= 0 and self.world:IsWorldState(BattleDefine.WorldState.running) then
        self.resultPerformFinish = true
        self:CheckResult()
    end 
end

function BattleResultSystem:OverResult(result)
    self.world.BattleStateSystem:SetBattleResult(result)

    local roleData = self.world.BattleDataSystem:GetRoleData(self.world.BattleDataSystem.roleUid)

    local winCamp = nil
    if self.world.BattleStateSystem:IsBattleResult(BattleDefine.BattleResult.win) then
        winCamp = roleData.camp
    else
        winCamp = roleData.camp == BattleDefine.Camp.attack and BattleDefine.Camp.defence or BattleDefine.Camp.attack
    end
    self.world.BattleStateSystem.winCamp = winCamp

    self.resultFrame = self.world.frame

    self.world.ClientIFacdeSystem:Call("SendEvent","BattleFacade","ActiveLockScreen",true)
end


function BattleResultSystem:OnLateUpdate()
    if self.world.BattleStateSystem:IsBattleResult(BattleDefine.BattleResult.none) then
        return
    end

    if self.world.BattleStateSystem:IsOverLock() then
        return
    end

    self.world:SetWorldState(BattleDefine.WorldState.stop)

    if not self.world.opts:IsClient() then
        return
    end

    self.world.ClientIFacdeSystem:Call("SendEvent","BattleResultPerformView","PlayResultPerform")
    
    self:CheckResult()
end

function BattleResultSystem:ResultPerformFinish()
    self.resultPerformFinish = true
    self:CheckResult()
end

function BattleResultSystem:CheckResult()
    -- self:CloseBlockLayer()
	-- self.delayOverTimer = nil
	-- self.BattleProxy.overAniming = false
	
	if self.resultData and self.resultPerformFinish then
        self:InvokeEvent()
        self:TryShowResultWindow()
    elseif not self.resultData then
        self:RemoveTimeoutTimer()
        mod.BattleFacade:SendMsg(10410,
            self.world.BattleStateSystem.winCamp,
            self.world.BattleResultSystem.resultFrame,"1","1","")
		self.timeoutTimer = TimerManager.Instance:AddTimer(1,3,self:ToFunc("ResultTimeout"))
    end
end

function BattleResultSystem:ResultTimeout()
    self.timeoutTimer = nil
	local data = {}
    data.msg = TI18N("网络异常，是否重新提交结束战斗？")
    data.cancelText = TI18N("退出")
    data.confirmText = TI18N("提交")
    data.confirmCallback = self:ToFunc("OnAgainResult")
    data.cancelCallback = self:ToFunc("OnCancelResult")
    data.canClose = false
    mod.BattleFacade:SendEvent(BattleDialogPanel.Event.ActiveDialog,true,data)
end

function BattleResultSystem:OnAgainResult()
	self:CheckResult()
end

function BattleResultSystem:OnCancelResult()
    local roleData = self.world.BattleDataSystem:GetRoleData(self.world.BattleDataSystem.roleUid)

    local winCamp = roleData.camp == BattleDefine.Camp.attack and BattleDefine.Camp.defence or BattleDefine.Camp.attack

    local virtualResultData = {}
    virtualResultData.win_camp = winCamp
    self:ReturnResult(virtualResultData)
end

--服务器返回结果
function BattleResultSystem:ReturnResult(resultData)
    if self.resultData then
        return
    end
    
    mod.BattleFacade:SendEvent(BattleDialogPanel.Event.ActiveDialog,false)
    self:RemoveTimeoutTimer()
    
    self.resultData = resultData

    if self.world.BattleStateSystem:IsBattleResult(BattleDefine.BattleResult.none) then
        self:SurrenderResult(resultData.win_camp)
    else
        self:CheckResult()
    end
end

function BattleResultSystem:ShowResultWindow()
    if ViewManager.Instance:HasWindow(BattleResultWindow) then
        return
    end

    --TODO:如果还在表演中，就先不显示
    -- if self.BattleProxy.resultData.result == 1 then
	-- 	self.BattleOverCtrl:ShowWinView(self.BattleProxy.resultData)
	-- else
	-- 	self.BattleOverCtrl:ShowLoseView(self.BattleProxy.resultData)
	-- end
    self.world.ClientIFacdeSystem:Call("SendEvent","BattleFacade","ActiveLockScreen",false)
    ViewManager.Instance:OpenWindow(BattleResultWindow)
    AudioManager.Instance:StopBgm()
end


function BattleResultSystem:RemoveTimeoutTimer()
    if self.timeoutTimer then
        TimerManager.Instance:RemoveTimer(self.timeoutTimer)
        self.timeoutTimer = nil
    end
end

function BattleResultSystem:SetCanShowResultWindow(canShow)
    self.canShowResultWin = canShow
end

function BattleResultSystem:TryShowResultWindow()
    if self.canShowResultWin then
        self:ShowResultWindow()
    end
end

function BattleResultSystem:InvokeEvent()
    local roleData = self.world.BattleDataSystem:GetRoleData(self.world.BattleDataSystem.roleUid)
    local isSelf = self.resultData.win_camp ~= roleData.camp
    self.world.ClientIFacdeSystem:Call("SendGuideEvent", "PlayerGuideDefine","on_commander_die", isSelf)
    if self.world.BattleStateSystem:IsBattleResult(BattleDefine.BattleResult.win) then
        self.world.ClientIFacdeSystem:Call("SendGuideEvent", "PlayerGuideDefine","on_pvp_win")
    end
end