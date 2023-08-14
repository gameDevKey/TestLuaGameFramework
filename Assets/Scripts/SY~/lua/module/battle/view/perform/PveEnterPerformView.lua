PveEnterPerformView = BaseClass("PveEnterPerformView",ExtendView)

PveEnterPerformView.Event = EventEnum.New()

function PveEnterPerformView:__Init()
    self.overTimer = nil
end

function PveEnterPerformView:__CacheObject()
    self.enterTipsCanvasGroup = self:Find("main/tips_node/enter_tips",CanvasGroup)
    self.animRoot = self:Find("main/tips_node")
end

function PveEnterPerformView:__BindEvent()
    self:BindEvent(BattleFacade.Event.PlayEnterPerform)
end

function PveEnterPerformView:__Hide()
    self:RemoveTimer()
end

function PveEnterPerformView:PlayEnterPerform()
    self:PlayCameraEnterAnim()
end

function PveEnterPerformView:PlayCameraEnterAnim()
    local enterAnimName = "defence"
    BattleDefine.nodeObjs["main_camera"].gameObject:GetComponent(Animator).enabled = true
    BattleDefine.nodeObjs["main_camera_holder"].transform:SetLocalPosition(0,0,-BattleDefine.cameraOffsetZ)
    BattleDefine.nodeObjs["map_parent"].transform:SetLocalEulerAngles(0,180,0)

    local cameraAnimator = BattleDefine.nodeObjs["main_camera_animator"]
    cameraAnimator:Play(enterAnimName,0,1.0)
    cameraAnimator:Update(0)

    local animTime = 0
    self.cameraTimer = TimerManager.Instance:AddTimer(1, animTime, function ()
        mod.BattleFacade:SendEvent(BattleFacade.Event.ActiveMainPanel,true)

        RunWorld.BattleTerrainSystem:InitTerrainCollider()

        mod.BattleFacade:SendEvent(BattleFacade.Event.InitComplete,0)

        RunWorld.BattleEnterSystem:InitRefresh()

        self:PlayCommanderBornAnim()

        BattleDefine.nodeObjs["main_camera"].gameObject:GetComponent(Animator).enabled = false
    end)
end

function PveEnterPerformView:PlayCommanderBornAnim()
    local commanderEntity = RunWorld.EntitySystem:GetCommanderByCamp(BattleDefine.Camp.defence)
    if commanderEntity.clientEntity and commanderEntity.clientEntity.ClientTransformComponent then
        commanderEntity.clientEntity.ClientTransformComponent.gameObject:SetActive(true)
        commanderEntity.clientEntity.ClientAnimComponent:PlayAnim(BattleDefine.Anim.born)
        self:PlayCommanderBornEffect(commanderEntity)
    end

    self.overTimer = TimerManager.Instance:AddTimer(1,4,self:ToFunc("ShowEnterTips"))
end

function PveEnterPerformView:PlayCommanderBornEffect(entity)
    local unitId = entity.ObjectDataComponent.unitConf.id
    local effectIds = RunWorld.BattleConfSystem:CommanderData_data_base_info(unitId).enter_perform_effectId_list
    for _, effectId in ipairs(effectIds) do
        RunWorld.BattleAssetsSystem:PlayUnitEffect(entity.uid,effectId)
    end
end

function PveEnterPerformView:ShowEnterTips()
    self:LoadUIEffect({
        confId = 10033,
        parent = self.animRoot,
        order = self:GetOrder() + 1,
        onComplete = self:ToFunc("EnterAnimFinish"),
    },true)
end

function PveEnterPerformView:EnterAnimFinish()
    RunWorld:SetWorldState(BattleDefine.WorldState.running)
    RunWorld.BattleStateSystem:SetBattleState(BattleDefine.BattleState.battle)

    if not RunWorld.BattleStateSystem.localRun then
        mod.BattleFacade:SendMsg(10401)
    end

    local maskCamera = BattleDefine.nodeObjs["camera/mask_camera"]
    local mainCamera = GDefine.mainCamera
    if maskCamera and mainCamera then
        maskCamera.fieldOfView = mainCamera.fieldOfView
        maskCamera.transform.position = mainCamera.transform.position
        maskCamera.transform.eulerAngles = mainCamera.transform.eulerAngles
    end
end

function PveEnterPerformView:RemoveRaitEnemtEnterTimer()
    if self.waitEnemyEnterTimer then
        TimerManager.Instance:RemoveTimer(self.waitEnemyEnterTimer)
        self.waitEnemyEnterTimer = nil
    end
end

function PveEnterPerformView:RemoveEnterAnim()
    if self.enterAnim then
        self.enterAnim:Destroy()
        self.enterAnim = nil
    end
end

function PveEnterPerformView:RemoveTimer()
    if self.cameraTimer then
        TimerManager.Instance:RemoveTimer(self.cameraTimer)
        self.cameraTimer = nil
    end

    if self.overTimer then
        TimerManager.Instance:RemoveTimer(self.overTimer)
        self.overTimer = nil
    end
end