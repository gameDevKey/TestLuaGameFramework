BattlePveResultSystem = BaseClass("BattlePveResultSystem",SECBOperationSystem)
BattlePveResultSystem.NAME = "BattleResultSystem"

function BattlePveResultSystem:__Init()
    self.resultData = nil
    self.resultFrame = 0
    self.timeoutTimer = nil
    self.resultPerformFinish = false
end

function BattlePveResultSystem:__Delete()
    self:RemoveTimeoutTimer()
end

function BattlePveResultSystem:OnLateInitSystem()
    self.world.EventTriggerSystem:AddListener(BattleEvent.be_home_hit,self:ToFunc("BeHomeHit"))
    self.world.EventTriggerSystem:AddListener(BattleEvent.enter_round,self:ToFunc("OnEnterRound"))
end

function BattlePveResultSystem:BeHomeHit(homeUid)
    local homeEntity = self.world.EntitySystem:GetEntity(homeUid)

    local hp = homeEntity.AttrComponent:GetValue(BattleDefine.Attr.hp)
    if hp > 0 then 
        return
    end

    local selfCamp = self.world.BattleMixedSystem:IsSelfCamp(homeEntity.CampComponent.camp)

    local battleResult = nil
    if selfCamp then
        battleResult = BattleDefine.BattleResult.lose
    else
        battleResult = BattleDefine.BattleResult.win
    end

    self:OverResult(battleResult)

    --self.world.BattleStateSystem:SetBattleResult(battleResult)

    --Log("战斗结果",battleResult)
end

function BattlePveResultSystem:Surrender()
    self.world.BattleStateSystem:SetSurrender(true)
    local pveUid = self.world.BattleDataSystem.data.pve_uid
    local pveBaseId = self.world.BattleDataSystem.data.pve_base_id
    local winNum = 0
    local dropList = {}
    mod.BattleFacade:SendMsg(10910,pveUid,pveBaseId,winNum,dropList)
end

function BattlePveResultSystem:SurrenderResult(winCamp)
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

function BattlePveResultSystem:CheckImmedResult()
    -- if self.resultData and self.world.BattleFrameSyncSystem.frame <= 0 and self.world:IsWorldState(BattleDefine.WorldState.running) then
    --     self.resultPerformFinish = true
    --     self:CheckResult()
    -- end 
end

function BattlePveResultSystem:OverResult(result)
    self.world.BattleStateSystem:SetBattleResult(result)

    local winCamp = nil
    if self.world.BattleStateSystem:IsBattleResult(BattleDefine.BattleResult.win) then
        winCamp = BattleDefine.Camp.defence
    else
        winCamp = BattleDefine.Camp.attack
    end
    self.world.BattleStateSystem.winCamp = winCamp

    self.resultFrame = self.world.frame

    self.world.ClientIFacdeSystem:Call("SendEvent",BattleFacade.Event.ActiveLockScreen,true)
end


function BattlePveResultSystem:OnLateUpdate()
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

    self.world.ClientIFacdeSystem:Call("SendEvent",PveResultPerformView.Event.PlayPveResultPerform)
    
    self:CheckResult()
end

function BattlePveResultSystem:ResultPerformFinish()
    self.resultPerformFinish = true
    self:CheckResult()
end

function BattlePveResultSystem:CheckResult()
	if self.resultData and self.resultPerformFinish then
        self.world.BattleMixedSystem:BattlePause(false)
        if self.world.BattleStateSystem:IsBattleResult(BattleDefine.BattleResult.win) then
            self.world.ClientIFacdeSystem:Call("SendGuideEvent", PlayerGuideDefine.Event.on_pve_win)
        end
		self:ShowResultWindow()
    elseif not self.resultData then
        self:RemoveTimeoutTimer()
        local pveUid = self.world.BattleDataSystem.data.pve_uid
        local pveBaseId = self.world.BattleDataSystem.data.pve_base_id
        local winNum = self.world.BattleStateSystem.winCamp == BattleDefine.Camp.defence and 1 or 0
        local dropList = winNum == 1 and self.world.BattleChestDropSystem.tbChest or {}
        mod.BattleFacade:SendMsg(10910,pveUid,pveBaseId,winNum,dropList)
		self.timeoutTimer = TimerManager.Instance:AddTimer(1,3,self:ToFunc("ResultTimeout"))
    end
end

function BattlePveResultSystem:ResultTimeout()
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

function BattlePveResultSystem:OnAgainResult()
	self:CheckResult()
end

function BattlePveResultSystem:OnCancelResult()

    local winCamp = BattleDefine.Camp.attack

    local virtualResultData = {}
    virtualResultData.win_camp = winCamp
    self:ReturnResult(virtualResultData)
end

--服务器返回结果
function BattlePveResultSystem:ReturnResult(resultData)
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

function BattlePveResultSystem:ShowResultWindow()
    if ViewManager.Instance:HasWindow(PveResultWindow) then
        return
    end

    --TODO:如果还在表演中，就先不显示
    -- if self.BattleProxy.resultData.result == 1 then
	-- 	self.BattleOverCtrl:ShowWinView(self.BattleProxy.resultData)
	-- else
	-- 	self.BattleOverCtrl:ShowLoseView(self.BattleProxy.resultData)
	-- end
    self.world.ClientIFacdeSystem:Call("SendEvent",BattleFacade.Event.ActiveLockScreen,false)
    ViewManager.Instance:OpenWindow(PveResultWindow, {
        isWin = self.resultData.is_win == 1,
        itemList = self.resultData.item_list,
        skillList = RunWorld.BattleDataSystem:GetSelectedItemsShowData(),
        totalSec = math.floor(self.world.BattleGroupSystem.totalTimer / 1000),
        name = RunWorld.BattleDataSystem.pveConf.name,
    })
    AudioManager.Instance:StopBgm()
end


function BattlePveResultSystem:RemoveTimeoutTimer()
    if self.timeoutTimer then
        TimerManager.Instance:RemoveTimer(self.timeoutTimer)
        self.timeoutTimer = nil
    end
end

function BattlePveResultSystem:OnEnterRound()
    --统帅存活且进行到了最后一波，判定为胜利
    local isFinish = self.world.BattleGroupSystem:IsFinishAllGroup()
    if isFinish then
        self:OverResult(BattleDefine.BattleResult.win)
    end
    LogYqh("结算系统判定: 统帅存活且进行到了最后一波?",isFinish)
end