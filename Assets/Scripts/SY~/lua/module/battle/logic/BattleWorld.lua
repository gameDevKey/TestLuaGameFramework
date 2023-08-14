BattleWorld = BaseClass("BattleWorld",SECBWorld)

function BattleWorld:__Init()
    self.worldState = BattleDefine.WorldState.none
    self.data = nil
    self.extraData = nil
    self.firstRunning = true
    self.bufferLen = 3
    self.isSingleFrame = false
end

function BattleWorld:__Delete()
    if self.checkWorld then
        self.checkWorld:Destroy()
        self.checkWorld = nil
    end
end

function BattleWorld:OnInitSystem()
    self:AddSystem(BattlePreLoadSystem)
    self:AddSystem(BattlePluginSystem)
    self:AddSystem(BattleEventTriggerSystem)
    self:AddSystem(BattleEnterSystem)
    self:AddSystem(BattleEntityCreateSystem)
    self:AddSystem(BattleMixedSystem)
    self:AddSystem(BattleStateSystem)
    self:AddSystem(BattleDataSystem)
    self:AddSystem(BattleGroupSystem)
    self:AddSystem(BattleSearchSystem)
    self:AddSystem(BattleCastSkillSystem)
    self:AddSystem(BattleOperationSystem)
    self:AddSystem(BattleConfSystem)
    self:AddSystem(BattleRandomSystem)
    self:AddSystem(BattleFrameSyncSystem)
    self:AddSystem(BattleClientIFacdeSystem)
    self:AddSystem(BattleHomeSystem)
    self:AddSystem(BattleResultSystem)
    self:AddSystem(BattleHitSystem)
    self:AddSystem(BattleCollistionSystem)
    self:AddSystem(BattleTerrainSystem)
    self:AddSystem(BattleMagicEventSystem)
    self:AddSystem(BattleCommanderSystem)
    self:AddSystem(BattleReserveUnitSystem)
    self:AddSystem(BattleHaloSystem)
    self:AddSystem(BattleCaptureBridgeSystem)
    self:AddSystem(BattleStatisticsSystem)
    self:AddSystem(BattleEntitySystem)
    self:AddSystem(BattleServerIFaceSystem)
    self:AddSystem(BattleSyncCheckSystem)
    
    
    self:AddSystem(BattleAssetsSystem)
    self:AddSystem(BattleClientEntitySystem)
    self:AddSystem(BattleInputSystem)
end

function BattleWorld:SetWorldState(state)
    self.worldState = state
end

function BattleWorld:IsWorldState(state)
    return self.worldState == state
end

function BattleWorld:SetData(data)
    self.data = data
end

function BattleWorld:SetExtraData(extraData)
    self.extraData = extraData
end

function BattleWorld:OnUpdate()
    if self.opts:IsClient() and self.runError then
        if GDefine.platform ~= GDefine.PlatformType.WebGLPlayer then
            mod.BattleCtrl:SaveWorld(self)
        end
        mod.BattleCtrl:ExitBattle(self)
        TimerManager.Instance:AddTimer(1,1,function() SystemMessage.Show(TI18N("战斗异常,已自动保存战斗数据,请查看日志")) end)
        return
    end

    if self.worldState == BattleDefine.WorldState.running then
        self:InitFirstRunning()
        self:UpdateFrame()

        if self.BattleStateSystem.isReconnect then
            self.BattleStateSystem:SetReconnect(false)
            mod.BattleCtrl:ReconnectComplete()
        end
    end

    if self.clientWorld then
        -- local renderTime = nil
        -- if DEBUG_BATTLE_TIME then
        --     renderTime = os.clock()
        -- end
        self.clientWorld:Update()
        self.clientWorld:LateUpdate()
        -- if DEBUG_BATTLE_TIME then
        --     local t = os.clock() - renderTime
        --     if t > 0 then
        --         LogInfof("渲染帧耗时[帧数:%s][时间:%s]",self.frame,t)
        --     end
        -- end
    end
end

function BattleWorld:OnDeltaTime()
    if not self.opts:IsClient() then
        return self.opts.frameDeltaTime,true
    end

    local deltaTime = Time.deltaTime * 1000

    if self.BattleStateSystem.localRun then
        return deltaTime * (DEBUG_SPEED or 1),true
    end


    local disFrame = self.BattleFrameSyncSystem.frame - self.frame

    --local localNextFrameTime = (self.frame + 1) * self.opts.deltaTime
    --local remoteNextFrameTime = (self.BattleFrameSyncSystem.frame + 1) * self.opts.deltaTime

    local maxFrameTime = self.BattleFrameSyncSystem.frame * self.opts.frameDeltaTime
    --3 * 50
    
    -- if self.time + deltaTime >= nextFrameTime and self.frame + 1 > self.BattleFrameSyncSystem.frame then
    --     return 0
    if self.BattleStateSystem.isReconnect then
        deltaTime = maxFrameTime - self.time
        Log("重连,将时间设置为最大")
    elseif disFrame >= 0 and disFrame <= self.bufferLen then
        deltaTime = deltaTime * 0.8 --Mathf.Clamp(0.6,1.0,0.6 + disFrame * 0.1)
    elseif disFrame >= self.bufferLen + 1 and disFrame <= self.bufferLen + 60 then
        deltaTime = deltaTime * 2
    elseif disFrame > self.bufferLen + 60 then
        deltaTime = maxFrameTime - self.time
    elseif disFrame < 0 then
        assert(false,string.format("本地帧超过服务器帧[本地帧:%s][服务器帧:%s]",self.frame,self.BattleFrameSyncSystem.frame))
    end

    if self.time + deltaTime > maxFrameTime then
        return maxFrameTime - self.time,self.BattleFrameSyncSystem.frame > self.frame
    else
        return deltaTime,self.BattleFrameSyncSystem.frame > self.frame
    end
end

function BattleWorld:CheckWorld()
    self.SyncCheckSystem:Check()
end

function BattleWorld:InitFirstRunning()
    if not self.firstRunning then
        return
    end
    self.firstRunning = false

    self.EventTriggerSystem:Trigger(BattleEvent.begin_battle)

    if self.checkWorld then
        self.checkWorld:InitFirstRunning()
    end

    self.ClientIFacdeSystem:Call("SendEvent","BattleFacade","ActiveLockScreen",false)
    self.ClientIFacdeSystem:Call("SendGuideEvent","PlayerGuideDefine","enter_battle",self.BattleDataSystem.pvpConf.id)
    self.ClientIFacdeSystem:Call("SendEvent","BattleFacade","FirstRunBattle")
    self.ClientIFacdeSystem:Call("SendGuideEvent","PlayerGuideDefine","enter_target_pvp", {
        maxCount = self.BattleDataSystem.pvpConf.max_embattle_count
    })
end

function BattleWorld:BeginLogicRunning()
    if self.frame ~= 1 then
        return
    end
    self.EventTriggerSystem:Trigger(BattleEvent.begin_logic_running)
    self.ClientIFacdeSystem:Call("SendEvent","BattleInfoView","ActiveWaitEnemyEnter",false)
end

function BattleWorld:OnPreUpdate()
    if DEBUG_BATTLE_TIME then
        self.logicTime = os.clock()
    end
    self.isSingleFrame = self.frame % 2 ~= 0
    self.BattleRandomSystem:SetLogicRandom(true)
    self:BeginLogicRunning()
    self.BattleOperationSystem:ApplyOperation()
    self.EntitySystem:PreUpdate()
end

function BattleWorld:OnLogicUpdate()
    self.BattleGroupSystem:Update()
    self.BattleCommanderSystem:Update()
    self.EntitySystem:Update()
    self.BattleCaptureBridgeSystem:Update()
    self.BattleReserveUnitSystem:Update()
end

function BattleWorld:OnLateUpdate()
    self.BattleMagicEventSystem:LateUpdate()
    self.EntitySystem:LateUpdate()
    self.BattleStateSystem:LateUpdate()
    self.BattleResultSystem:LateUpdate()
    --self.BattleSearchSystem:LateUpdate()
    self.BattleRandomSystem:SetLogicRandom(false)
    self.BattleHaloSystem:LateUpdate()

    if DEBUG_BATTLE_TIME then
        local t = os.clock() - self.logicTime
        if t > 0 then
            print(string.format("逻辑帧耗时[帧数:%s][时间:%s]",self.frame,t))
        end
    end
end

function BattleWorld:OnDestroy()
    self:CleanSystem()

    if self.clientWorld then
        self.clientWorld:Delete()
        self.clientWorld = nil
    end

    self:Delete()
    --collectgarbage("restart")
end