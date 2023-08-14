BattleEnterPerformView = BaseClass("BattleEnterPerformView",ExtendView)

BattleEnterPerformView.Event = EventEnum.New()

function BattleEnterPerformView:__Init()
    self.overTimer = nil
end

function BattleEnterPerformView:__CacheObject()
    self.animRoot = self:Find("main/tips_node")
end

function BattleEnterPerformView:__BindEvent()
    self:BindEvent(BattleFacade.Event.PlayEnterPerform)
end

function BattleEnterPerformView:__Hide()
    self:RemoveTimer()
    self:RemoveRaitEnemtEnterTimer()
end

function BattleEnterPerformView:PlayEnterPerform()
    self:PlayCameraEnterAnim()
end

function BattleEnterPerformView:PlayCameraEnterAnim()
    local enterAnimName = nil
    BattleDefine.nodeObjs["main_camera"].gameObject:GetComponent(Animator).enabled = true
    if RunWorld.BattleDataSystem.enterExtraData.selfCamp == BattleDefine.Camp.attack then
        enterAnimName = "attack"
        BattleDefine.nodeObjs["main_camera_holder"].transform:SetLocalPosition(0,0,BattleDefine.cameraOffsetZ)
        BattleDefine.nodeObjs["map_parent"].transform:SetLocalEulerAngles(0,0,0)
    else
        enterAnimName = "defence"
        BattleDefine.nodeObjs["main_camera_holder"].transform:SetLocalPosition(0,0,-BattleDefine.cameraOffsetZ)
        BattleDefine.nodeObjs["map_parent"].transform:SetLocalEulerAngles(0,180,0)
    end

    RunWorld.ClientIFacdeSystem:Call("RefreshGroupTime")
    -- mod.BattleFacade:SendEvent(BattleBridgeView.Event.CacheBridgeState)

    mod.BattleFacade:SendEvent(BattleInfoView.Event.RefreshMoney)

    local cameraAnimator = BattleDefine.nodeObjs["main_camera_animator"]
    cameraAnimator:Play(enterAnimName,0,0) --从头播放
    local animTime = BaseUtils.GetAnimatorClipTime(cameraAnimator, enterAnimName)
    self.cameraTimer = TimerManager.Instance:AddTimer(1, animTime, function ()
        cameraAnimator:Play(enterAnimName,0,1.0)    --镜头位置一定要先到目标位置，否则会影响UI的屏幕位置计算
        cameraAnimator:Update(0)
        cameraAnimator.enabled = false

        mod.BattleFacade:SendEvent(BattleFacade.Event.ActiveMainPanel,true)

        -- RunWorld.ClientIFacdeSystem:Call("RefreshGroupTime")

        RunWorld.BattleTerrainSystem:InitTerrainCollider()
        mod.BattleFacade:SendEvent(BattleMixedView.Event.SetCommanderColliderClick)

        mod.BattleFacade:SendEvent(BattleInfoView.Event.RefreshRoleInfo)
        mod.BattleFacade:SendEvent(BattleHeroGridView.Event.RefreshHeroGrid)
        mod.BattleFacade:SendEvent(BattleInfoView.Event.RefreshGroupNum,0)

        mod.BattleFacade:SendEvent(BattleFacade.Event.InitComplete,0)

        RunWorld.BattleEnterSystem:InitRefresh()

        self:PlayCommanderBornAnim()
    end)
end

function BattleEnterPerformView:PlayCommanderBornAnim()
    local attackCommanderEntity = RunWorld.EntitySystem:GetCommanderByCamp(BattleDefine.Camp.attack)
    if attackCommanderEntity.clientEntity and attackCommanderEntity.clientEntity.ClientTransformComponent then
        attackCommanderEntity.clientEntity.ClientTransformComponent.gameObject:SetActive(true)
        attackCommanderEntity.clientEntity.ClientAnimComponent:PlayAnim(BattleDefine.Anim.born)
        self:PlayCommanderBornEffect(attackCommanderEntity)
    end

    local defenceCommanderEntity = RunWorld.EntitySystem:GetCommanderByCamp(BattleDefine.Camp.defence)
    if defenceCommanderEntity.clientEntity and defenceCommanderEntity.clientEntity.ClientTransformComponent then
        defenceCommanderEntity.clientEntity.ClientTransformComponent.gameObject:SetActive(true)
        defenceCommanderEntity.clientEntity.ClientAnimComponent:PlayAnim(BattleDefine.Anim.born)
        self:PlayCommanderBornEffect(defenceCommanderEntity)
    end

    self.overTimer = TimerManager.Instance:AddTimer(1,4,self:ToFunc("ShowEnterTips"))
end

function BattleEnterPerformView:PlayCommanderBornEffect(entity)
    local unitId = entity.ObjectDataComponent.unitConf.id
    local effectIds = RunWorld.BattleConfSystem:CommanderData_data_base_info(unitId).enter_perform_effectId_list
    for _, effectId in ipairs(effectIds) do
        RunWorld.BattleAssetsSystem:PlayUnitEffect(entity.uid,effectId)
    end
end

function BattleEnterPerformView:ShowEnterTips()
    self:LoadUIEffect({
        confId = 10028,
        parent = self.animRoot,
        order = self:GetOrder() + 1,
        onComplete = self:ToFunc("EnterAnimFinish"),
    },true)
end

function BattleEnterPerformView:EnterAnimFinish()
    RunWorld:SetWorldState(BattleDefine.WorldState.running)
    RunWorld.BattleStateSystem:SetBattleState(BattleDefine.BattleState.battle)

    if not RunWorld.BattleStateSystem.localRun then
        mod.BattleFacade:SendMsg(10401)
    end

    mod.BattleFacade:SendEvent(BattleCommanderDragSkillView.Event.RefreshView)

    local activeMid = RunWorld.BattleDataSystem:CanExtGrid(3) or RunWorld.BattleDataSystem:CanExtGrid(8)
    local activeSide = RunWorld.BattleDataSystem:CanExtGrid(2) or RunWorld.BattleDataSystem:CanExtGrid(7) or RunWorld.BattleDataSystem:CanExtGrid(4) or RunWorld.BattleDataSystem:CanExtGrid(9)
    mod.BattleFacade:SendEvent(BattleMixedEffectView.Event.PlayRoadEffect,activeMid,activeSide)

    local maskCamera = BattleDefine.nodeObjs["camera/mask_camera"]
    local mainCamera = GDefine.mainCamera
    if maskCamera and mainCamera then
        maskCamera.fieldOfView = mainCamera.fieldOfView
        maskCamera.transform.position = mainCamera.transform.position
        maskCamera.transform.eulerAngles = mainCamera.transform.eulerAngles
    end

    self.waitEnemyEnterTimer = TimerManager.Instance:AddTimer(1,1,self:ToFunc("CheckWaitEnemyEnter"))

    RunWorld.BattleResultSystem:CheckImmedResult()
end

function BattleEnterPerformView:CheckWaitEnemyEnter()
    self.waitEnemyEnterTimer = nil
    if RunWorld.BattleFrameSyncSystem.frame <= 0 and not RunWorld.BattleStateSystem.localRun then
        mod.BattleFacade:SendEvent(BattleInfoView.Event.ActiveWaitEnemyEnter,true)
    end
end

function BattleEnterPerformView:RemoveRaitEnemtEnterTimer()
    if self.waitEnemyEnterTimer then
        TimerManager.Instance:RemoveTimer(self.waitEnemyEnterTimer)
        self.waitEnemyEnterTimer = nil
    end
end

function BattleEnterPerformView:RemoveTimer()
    if self.cameraTimer then
        TimerManager.Instance:RemoveTimer(self.cameraTimer)
        self.cameraTimer = nil
    end

    if self.overTimer then
        TimerManager.Instance:RemoveTimer(self.overTimer)
        self.overTimer = nil
    end
end