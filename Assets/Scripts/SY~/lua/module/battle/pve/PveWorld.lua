PveWorld = BaseClass("PveWorld",SECBWorld)

function PveWorld:__Init()
    self.worldState = BattleDefine.WorldState.none
    self.data = nil
    self.extraData = nil
    self.firstRunning = true
    self.bufferLen = 3
end

function PveWorld:__Delete()
    if self.checkWorld then
        self.checkWorld:Destroy()
        self.checkWorld = nil
    end
end

function PveWorld:OnInitSystem()
    self:AddSystem(BattlePvePreLoadSystem)
    self:AddSystem(BattlePluginSystem)
    self:AddSystem(BattleEventTriggerSystem)
    self:AddSystem(BattlePveEnterSystem)
    self:AddSystem(BattleEntityCreateSystem)
    self:AddSystem(BattlePveMixedSystem)
    self:AddSystem(BattleStateSystem)
    self:AddSystem(BattlePveDataSystem)
    self:AddSystem(BattlePveGroupSystem)
    self:AddSystem(BattleSearchSystem)
    self:AddSystem(BattleCastSkillSystem)
    self:AddSystem(BattlePveOperationSystem)
    self:AddSystem(BattleConfSystem)
    self:AddSystem(BattleRandomSystem)
    -- self:AddSystem(BattleFrameSyncSystem)  --TODO 帧驱动系统 移除
    self:AddSystem(BattleClientIFacdeSystem)
    self:AddSystem(BattleHomeSystem)
    self:AddSystem(BattlePveResultSystem)
    self:AddSystem(BattleHitSystem)
    self:AddSystem(BattleCollistionSystem)
    self:AddSystem(BattleTerrainSystem)
    self:AddSystem(BattleMagicEventSystem)
    self:AddSystem(BattlePveCommanderSystem)
    self:AddSystem(PveReserveItemSystem)

    self:AddSystem(BattleStatisticsSystem) --TODO 统计系统 替换
    self:AddSystem(BattleEntitySystem)
    self:AddSystem(BattleChestDropSystem)
    
    self:AddSystem(BattleSelectPveItemSystem)
    
    self:AddSystem(BattleAssetsSystem)
    self:AddSystem(BattleClientEntitySystem)
    self:AddSystem(BattleInputSystem)
end

function PveWorld:SetWorldState(state)
    self.worldState = state
end

function PveWorld:IsWorldState(state)
    return self.worldState == state
end

function PveWorld:SetData(data)
    self.data = data
end

function PveWorld:SetExtraData(extraData)
    self.extraData = extraData
end

function PveWorld:OnUpdate()
    if self.opts:IsClient() and self.runError then
        mod.BattleCtrl:SaveWorld(self)
        mod.BattleCtrl:ExitPve(self)
        TimerManager.Instance:AddTimer(1,1,function() SystemMessage.Show(TI18N("战斗异常,已自动保存战斗数据,请查看日志")) end)
        return
    end

    if self.worldState == BattleDefine.WorldState.running then
        self.BattleRandomSystem:SetLogicRandom(true)
        self:InitFirstRunning()
        self:UpdateFrame()
        self.BattleRandomSystem:SetLogicRandom(false)

        if self.BattleStateSystem.isReconnect then
            self.BattleStateSystem:SetReconnect(false)
            mod.BattleCtrl:ReconnectComplete()
        end
    end

    if self.clientWorld then
        self.clientWorld:Update()
        self.clientWorld:LateUpdate()
    end
end

function PveWorld:OnDeltaTime()
    return (Time.deltaTime * 1000) * (DEBUG_SPEED or 1),true
end

function PveWorld:CheckWorld()
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

function PveWorld:InitFirstRunning()
    if not self.firstRunning then
        return
    end
    self.firstRunning = false

    self.EventTriggerSystem:Trigger(BattleEvent.begin_battle)

    if self.checkWorld then
        self.checkWorld:InitFirstRunning()
    end

    self.ClientIFacdeSystem:Call("SendEvent","BattleFacade","ActiveLockScreen",false)
    -- self.ClientIFacdeSystem:Call("SendGuideEvent",PlayerGuideDefine.Event.enter_battle,self.BattleDataSystem.pvpConf.id)
    self.ClientIFacdeSystem:Call("SendEvent","BattleFacade","FirstRunBattle")
    self.ClientIFacdeSystem:Call("SendGuideEvent","PlayerGuideDefine","enter_target_pve", {
        pveId = self.BattleDataSystem.pveConf.id
    })
end

function PveWorld:BeginLogicRunning()
    if self.frame ~= 1 then
        return
    end
    self.EventTriggerSystem:Trigger(BattleEvent.begin_logic_running)
    self.ClientIFacdeSystem:Call("SendEvent","BattleInfoView","ActiveWaitEnemyEnter",false)
end

function PveWorld:OnPreUpdate()
    self.BattleRandomSystem:SetLogicRandom(true)
    self:BeginLogicRunning()
    self.BattleOperationSystem:ApplyOperation()
    self.EntitySystem:PreUpdate()
end

function PveWorld:OnLogicUpdate()
    self.BattleGroupSystem:Update()
    self.BattleCommanderSystem:Update()
    self.EntitySystem:Update()
    -- self.BattleReserveUnitSystem:Update()  --TODO 替换  被 BattleDataSystem 关联
    self.BattleMagicEventSystem:Update()
    self.BattleDataSystem:Update()
end

function PveWorld:OnLateUpdate()
    -- self.BattleMagicEventSystem:LateUpdate()  --TODO 移除
    self.EntitySystem:LateUpdate()
    self.BattleStateSystem:LateUpdate()
    self.BattleResultSystem:LateUpdate()
    --self.BattleSearchSystem:LateUpdate()
    self.BattleRandomSystem:SetLogicRandom(false)
    -- self.BattleHaloSystem:LateUpdate()  --TODO 移除
end

function PveWorld:OnDestroy()
    self:CleanSystem()

    if self.clientWorld then
        self.clientWorld:Delete()
        self.clientWorld = nil
    end

    self:Delete()
    --collectgarbage("restart")
end