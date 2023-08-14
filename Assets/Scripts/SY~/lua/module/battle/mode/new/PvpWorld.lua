PvpWorld = BaseClass("PvpWorld",SECBWorld)

function PvpWorld:__Init()
    self.worldState = BattleDefine.WorldState.none
    self.data = nil
    self.extraData = nil
    self.firstRunning = true
    self.bufferLen = 3
    self.isSingleFrame = false
end

function PvpWorld:__Delete()
    if self.checkWorld then
        self.checkWorld:Destroy()
        self.checkWorld = nil
    end
end

function PvpWorld:OnInitSystem()
    self:AddSystem(PvpPreLoadSystem)
    self:AddSystem(BattlePluginSystem)
    self:AddSystem(BattleEventTriggerSystem)
    self:AddSystem(BattleEnterSystem)
    self:AddSystem(BattleEntityCreateSystem)
    self:AddSystem(BattleMixedSystem)
    self:AddSystem(BattleStateSystem)
    self:AddSystem(BattleDataSystem)
    self:AddSystem(BattleGroupSystem)
    self:AddSystem(BattlePvpSearchSystem)
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
    
    
    self:AddSystem(BattleAssetsSystem)
    self:AddSystem(BattleClientEntitySystem)
    self:AddSystem(BattleInputSystem)
end

function PvpWorld:SetWorldState(state)
    self.worldState = state
end

function PvpWorld:IsWorldState(state)
    return self.worldState == state
end

function PvpWorld:SetData(data)
    self.data = data
end

function PvpWorld:SetExtraData(extraData)
    self.extraData = extraData
end

function PvpWorld:OnUpdate()
    if self.opts:IsClient() and self.runError then
        -- if GDefine.platform ~= GDefine.PlatformType.WebGLPlayer then
        --     mod.BattleCtrl:SaveWorld(self)
        -- end
        -- mod.BattleCtrl:ExitBattle(self)
        -- TimerManager.Instance:AddTimer(1,1,function() SystemMessage.Show(TI18N("战斗异常,已自动保存战斗数据,请查看日志")) end)
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

function PvpWorld:OnDeltaTime()
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

function PvpWorld:CheckWorld()
    if self.EntitySystem.entityList.length ~= self.checkWorld.EntitySystem.entityList.length then
        assert(false,string.format("战斗出现差异[%s]",self.frame))
    end

    if not self.BattleStateSystem:IsBattleResult(BattleDefine.BattleResult.none) then
        return
    end

    for iter in self.EntitySystem.entityList:Items() do
        local uid = iter.value
        local entity = self.EntitySystem:GetEntity(uid)
        local checkEntity = self.checkWorld.EntitySystem:GetEntity(uid)
        
        if (entity and not checkEntity) or (not entity and checkEntity) then
            assert(false,string.format("战斗出现差异[%s]",self.frame))
        end

        if entity and (entity.TagComponent.mainTag ~= checkEntity.TagComponent.mainTag 
            or entity.TagComponent.subTag ~= checkEntity.TagComponent.subTag)  then
            assert(false,string.format("战斗出现差异[%s]",self.frame))
        end

        if entity and entity.AttrComponent then
            local hp = entity.AttrComponent:GetValue(BattleDefine.Attr.hp)
            local checkHp = checkEntity.AttrComponent:GetValue(BattleDefine.Attr.hp)
            if hp ~= checkHp then
                assert(false,string.format("战斗出现差异[%s]",self.frame))
            end
        end

        if entity and entity.TransformComponent then
            local pos = entity.TransformComponent:GetPos()
            local checkPos = checkEntity.TransformComponent:GetPos()
            -- if pos ~= checkPos then
            --     Log("aaa",entity.uid,pos.x,pos.y,pos.z,checkPos.x,checkPos.y,checkPos.z)
            --     assert(false,string.format("战斗出现差异[%s]",self.frame))
            -- end
        end
    end

    for i,v in ipairs(self.BattleDataSystem.data.role_list) do
        local commanderInfo = self.BattleCommanderSystem:GetCommanderInfo(v.role_base.role_uid)
        local checkCommanderInfo = self.checkWorld.BattleCommanderSystem:GetCommanderInfo(v.role_base.role_uid)

        if commanderInfo.star ~= checkCommanderInfo.star or commanderInfo.exp ~= checkCommanderInfo.exp then
            assert(false,string.format("战斗出现差异[%s]",self.frame))
        end

        local money = self.BattleDataSystem:GetRoleMoney(v.role_base.role_uid)
        local checkMoney = self.checkWorld.BattleDataSystem:GetRoleMoney(v.role_base.role_uid)
        if money ~= checkMoney then
            assert(false,string.format("战斗出现差异[%s]",self.frame))
        end
    end


    local attackHomeUid = self.BattleDataSystem:GetHomeUid(BattleDefine.Camp.attack)
    local attackHomeEntity = self.EntitySystem:GetEntity(attackHomeUid)
    local attackHomeHp = attackHomeEntity.AttrComponent:GetValue(BattleDefine.Attr.hp)

    local checkAttackHomeUid = self.checkWorld.BattleDataSystem:GetHomeUid(BattleDefine.Camp.attack)
    local checkAttackHomeEntity = self.checkWorld.EntitySystem:GetEntity(checkAttackHomeUid)
    local checkAttackHomeHp = checkAttackHomeEntity.AttrComponent:GetValue(BattleDefine.Attr.hp)

    if attackHomeHp ~= checkAttackHomeHp then
        assert(false,string.format("战斗出现差异[%s]",self.frame))
    end


    local defenceHomeUid = self.BattleDataSystem:GetHomeUid(BattleDefine.Camp.defence)
    local defenceHomeEntity = self.EntitySystem:GetEntity(defenceHomeUid)
    local defenceHomeHp = defenceHomeEntity.AttrComponent:GetValue(BattleDefine.Attr.hp)

    local checkDefenceHomeUid = self.checkWorld.BattleDataSystem:GetHomeUid(BattleDefine.Camp.defence)
    local checkDefenceHomeEntity = self.checkWorld.EntitySystem:GetEntity(checkDefenceHomeUid)
    local checkDefenceHomeHp = checkDefenceHomeEntity.AttrComponent:GetValue(BattleDefine.Attr.hp)

    if defenceHomeHp ~= checkDefenceHomeHp then
        assert(false,string.format("战斗出现差异[%s]",self.frame))
    end
end

function PvpWorld:InitFirstRunning()
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

function PvpWorld:BeginLogicRunning()
    if self.frame ~= 1 then
        return
    end
    self.EventTriggerSystem:Trigger(BattleEvent.begin_logic_running)
    self.ClientIFacdeSystem:Call("SendEvent","BattleInfoView","ActiveWaitEnemyEnter",false)
end

function PvpWorld:OnPreUpdate()
    if DEBUG_BATTLE_TIME then
        self.logicTime = os.clock()
    end
    self.isSingleFrame = self.frame % 2 ~= 0
    self.BattleRandomSystem:SetLogicRandom(true)
    self:BeginLogicRunning()
    self.BattleOperationSystem:ApplyOperation()
    self.EntitySystem:PreUpdate()
end

function PvpWorld:OnLogicUpdate()
    self.BattleGroupSystem:Update()
    self.BattleCommanderSystem:Update()
    self.EntitySystem:Update()
    self.BattleCaptureBridgeSystem:Update()
    self.BattleReserveUnitSystem:Update()
end

function PvpWorld:OnLateUpdate()
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

function PvpWorld:OnDestroy()
    self:CleanSystem()

    if self.clientWorld then
        self.clientWorld:Delete()
        self.clientWorld = nil
    end

    self:Delete()
    --collectgarbage("restart")
end