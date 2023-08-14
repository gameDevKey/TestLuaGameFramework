BattleCaptureBridgeSystem = BaseClass("BattleCaptureBridgeSystem",SECBSystem)

function BattleCaptureBridgeSystem:__Init()
    self.bridgeState = {
        [1] = BattleDefine.BridgeState.none,
        [2] = BattleDefine.BridgeState.none,
    }

    self.expTime = {
        [1] = 0,
        [2] = 0,
    }

    self.rageTime = {
        [1] = 0,
        [2] = 0,
    }
end

function BattleCaptureBridgeSystem:OnLateInitSystem()
    --self.world.EventTriggerSystem:AddListener(BattleEvent.unit_moved,self:ToFunc("RefreshBridgeState"))
end

function BattleCaptureBridgeSystem:RefreshBridgeState(movedEntityUid)
    -- if self.world.BattleDataSystem.pvpConf.open_capture_bridge_commander_up == 0 then
    --     return
    -- end
    if self.world.BattleDataSystem.pvpConf.open_capture_bridge_commander_rage_up == 0 then
        return
    end

    local movedEntity = self.world.EntitySystem:GetEntity(movedEntityUid)
    if not movedEntity then
        return -- 不存在移动的实体
    end

    local movedEntityWalkType = movedEntity.ObjectDataComponent:GetWalkType()
    if movedEntityWalkType ~= BattleDefine.WalkType.floor then
        return -- 移动类型不为地面
    end

    local pos = movedEntity.TransformComponent:GetPos()
    local inRoadX,inRoadIndex = self.world.BattleTerrainSystem:InRoadArea(pos.x,pos.z)
    if not inRoadX then
        return -- 移动的实体没有进入到桥的区域
    end

    local camp = movedEntity.CampComponent:GetCamp()
    if camp == self.bridgeState[inRoadIndex] then
        return -- 移动的实体阵营与当前桥的占领阵营一致
    end
    self:SetBridgeState()
end

function BattleCaptureBridgeSystem:SetBridgeState()
    local state = {
        [BattleDefine.Camp.attack] = { [1] = false, [2] = false},
        [BattleDefine.Camp.defence] = { [1] = false, [2] = false}
    }

    for k, v in pairs(BattleDefine.Camp) do
        local entitys = self.world.EntitySystem:GetAllEntityByCamp(v)
        for k2, v2 in pairs(entitys) do
            local entity = self.world.EntitySystem:GetEntity(v2)
            local movedEntityWalkType = entity.ObjectDataComponent:GetWalkType()
            if movedEntityWalkType == BattleDefine.WalkType.floor then
                local pos = entity.TransformComponent:GetPos()
                local inRoadX,inRoadIndex = self.world.BattleTerrainSystem:InRoadArea(pos.x,pos.z)
                if inRoadX then
                    state[v][inRoadIndex] = true
                end
            end
        end
    end

    for i = 1, 2 do
        if state[BattleDefine.Camp.attack][i] and not state[BattleDefine.Camp.defence][i] then
            if self.bridgeState[i] ~= BattleDefine.BridgeState.attackCamp then
                self.bridgeState[i] = BattleDefine.BridgeState.attackCamp
                self.world.ClientIFacdeSystem:Call("SendEvent",BattleBridgeView.Event.RefreshBridgeState,i,BattleDefine.BridgeState.attackCamp)
                -- self.expTime[i] = 0
                self.rageTime[i] = 0
            end
        elseif not state[BattleDefine.Camp.attack][i] and state[BattleDefine.Camp.defence][i] then
            if self.bridgeState[i] ~= BattleDefine.BridgeState.defenceCamp then
                self.bridgeState[i] = BattleDefine.BridgeState.defenceCamp
                self.world.ClientIFacdeSystem:Call("SendEvent",BattleBridgeView.Event.RefreshBridgeState,i,BattleDefine.BridgeState.defenceCamp)
                -- self.expTime[i] = 0
                self.rageTime[i] = 0
            end
        elseif state[BattleDefine.Camp.attack][i] and state[BattleDefine.Camp.defence][i] then
            if self.bridgeState[i] ~= BattleDefine.BridgeState.capturing then
                self.bridgeState[i] = BattleDefine.BridgeState.capturing
                self.world.ClientIFacdeSystem:Call("SendEvent",BattleBridgeView.Event.RefreshBridgeState,i,BattleDefine.BridgeState.capturing)
                -- self.expTime[i] = 0
                self.rageTime[i] = 0
            end
        elseif not state[BattleDefine.Camp.attack][i] and not state[BattleDefine.Camp.defence][i] then
            if self.bridgeState[i] ~= BattleDefine.BridgeState.none then
                if self.bridgeState[i] == BattleDefine.BridgeState.capturing then
                    self.bridgeState[i] = BattleDefine.BridgeState.none
                    self.world.ClientIFacdeSystem:Call("SendEvent",BattleBridgeView.Event.RefreshBridgeState,i,BattleDefine.BridgeState.none)
                    -- self.expTime[i] = 0
                    self.rageTime[i] = 0
                end
            end
        end

        if state[BattleDefine.Camp.attack][i] ~= BattleDefine.BridgeState.none or state[BattleDefine.Camp.defence][i] ~= BattleDefine.BridgeState.none then
            self.world.ClientIFacdeSystem:Call("SendGuideEvent",PlayerGuideDefine.Event.capture_bridge,i)
        end
    end
end

function BattleCaptureBridgeSystem:GetBridgeState()
    return self.bridgeState
end

function BattleCaptureBridgeSystem:OnUpdate()
    if self.world.BattleDataSystem.pvpConf.open_capture_bridge_commander_rage_up == 0 then
        return
    end

    if self.bridgeState[1] == BattleDefine.BridgeState.capturing or self.bridgeState[2] == BattleDefine.BridgeState.capturing then
        self:SetBridgeState()
    end

    self:CalculateRage(1)
    self:CalculateRage(2)

    do return end -- 以下为统帅经验升星逻辑
    if self.world.BattleDataSystem.pvpConf.open_capture_bridge_commander_up == 0 then
        return
    end
    if self.bridgeState[1] == BattleDefine.BridgeState.capturing or self.bridgeState[2] == BattleDefine.BridgeState.capturing then
        self:SetBridgeState()
    end

    self:CalculateExp(1)
    self:CalculateExp(2)
end

function BattleCaptureBridgeSystem:CalculateRage(index)
    local groupConf = self.world.BattleGroupSystem.groupConf
    if groupConf.capture_bridge_commander_add_rage[2] <= 0 then
        return
    end
    if not self.lastGroup or self.lastGroup ~= groupConf.group then
        self.lastGroup = groupConf.group
        self.rageTime[index] = 0
        self.rageAddTime = groupConf.capture_bridge_commander_add_rage[1] --多少毫秒添加一次怒气
    end

    if self.bridgeState[index] ~= BattleDefine.BridgeState.none and self.bridgeState[index] ~= BattleDefine.BridgeState.capturing then
        self.rageTime[index] = self.rageTime[index] + self.world.opts.frameDeltaTime
    end

    if self.rageTime[index] < self.rageAddTime then
        return
    end
    local addNum = FPMath.Divide(self.rageTime[index] - (self.rageTime[index] % self.rageAddTime),self.rageAddTime)
    local addRage = addNum * groupConf.capture_bridge_commander_add_rage[2] -- 一次增加多少点怒气

    self.rageTime[index] = self.rageTime[index] - addNum * self.rageAddTime

    local addRageCamp = self.world.BattleDataSystem.enterExtraData.selfCamp
    if self.bridgeState[index] ~= addRageCamp then
        addRageCamp = self.world.BattleDataSystem:GetCampByFrom(-1)
    end

    local roleUids = self.world.BattleDataSystem:GetCampRoleUid(addRageCamp)
    for _,roleUid in ipairs(roleUids) do
        self.world.BattleCommanderSystem:AddRage(roleUid,addRage)
    end
end

function BattleCaptureBridgeSystem:CalculateExp(index)
    local groupConf = self.world.BattleGroupSystem.groupConf
    if groupConf.capture_bridge_commander_add_exp[2] <= 0 then
        return
    end

    if not self.lastGroup or self.lastGroup ~= groupConf.group then
        self.lastGroup = groupConf.group
        self.expTime[index] = 0
        self.addTime = groupConf.capture_bridge_commander_add_exp[1] --多少毫秒添加一次经验
    end

    if self.bridgeState[index] ~= BattleDefine.BridgeState.none and self.bridgeState[index] ~= BattleDefine.BridgeState.capturing then
        self.expTime[index] = self.expTime[index] + self.world.opts.frameDeltaTime
    end

    if self.expTime[index] < self.addTime then
        return
    end

    local addNum = FPMath.Divide(self.expTime[index] - (self.expTime[index] % self.addTime),self.addTime)
    local addExp = addNum * groupConf.capture_bridge_commander_add_exp[2] -- 一次增加多少点经验

    self.expTime[index] = self.expTime[index] - addNum * self.addTime

    -- local roleUid = self.world.BattleDataSystem.roleUid
    -- local selfCamp = self.world.BattleDataSystem.enterExtraData.selfCamp
    -- if self.bridgeState[index] ~= selfCamp then
    --     for i,v in ipairs(self.world.BattleDataSystem.data.role_list) do
    --         if v.role_base.role_uid ~= roleUid then
    --             roleUid = v.role_base.role_uid
    --         end
    --     end
    -- end
    -- self.world.BattleCommanderSystem:AddExp(roleUid,addExp,{from = 2,index = index})

    local addExpCamp = self.world.BattleDataSystem.enterExtraData.selfCamp
    if self.bridgeState[index] ~= addExpCamp then
        addExpCamp = self.world.BattleDataSystem:GetCampByFrom(-1)
    end

    local roleUids = self.world.BattleDataSystem:GetCampRoleUid(addExpCamp)
    for _,roleUid in ipairs(roleUids) do
        self.world.BattleCommanderSystem:AddExp(roleUid,addExp,{from = 2,index = index})
    end
end