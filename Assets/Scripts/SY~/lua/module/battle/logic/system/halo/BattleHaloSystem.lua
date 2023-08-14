BattleHaloSystem = BaseClass("BattleHaloSystem",SECBSystem)

function BattleHaloSystem:__Init()
    self.roleUnitHalos = {}
    self.activeHalos = {}

    self.curTypeNum = {}
end

function BattleHaloSystem:__Delete()
    -- self.roleUnitHalos:Delete()
    for k, v in pairs(self.roleUnitHalos) do
        for k1, v1 in pairs(v) do
            for k2, v2 in pairs(v1) do
                v2:Delete()
            end
        end
    end
    self.roleUnitHalos = {}
    self.curTypeNum = {}
end

function BattleHaloSystem:OnLateInitSystem()
    self.world.EventTriggerSystem:AddListener(BattleEvent.begin_battle,self:ToFunc("BeginBattle"))
    self.world.EventTriggerSystem:AddListener(BattleEvent.place_unit,self:ToFunc("PlaceUnit"))
    self.world.EventTriggerSystem:AddListener(BattleEvent.update_unit,self:ToFunc("UpdateUnit"))
    self.world.EventTriggerSystem:AddListener(BattleEvent.cancel_unit,self:ToFunc("CancelUnit"))
end

function BattleHaloSystem:BeginBattle()
    for _,roleUid in ipairs(self.world.BattleDataSystem:GetCampRoleUid(BattleDefine.Camp.attack)) do
        if not self.roleUnitHalos[roleUid] then
            self.roleUnitHalos[roleUid] = {}
        end
    end

    for _,roleUid in ipairs(self.world.BattleDataSystem:GetCampRoleUid(BattleDefine.Camp.defence)) do
        if not self.roleUnitHalos[roleUid] then
            self.roleUnitHalos[roleUid] = {}
        end
    end
    self:SetCurTypeNum()
    self:SendRefreshEvent()
end

function BattleHaloSystem:PlaceUnit(args)
    self:UpdatePlaceUnitHalo(args.roleUid,args.camp,args.unitId,args.grid)
end

function BattleHaloSystem:UpdateUnit(args)
    self:UpdatePlaceUnitHalo(args.roleUid,args.camp,args.unitId,args.grid)
end

function BattleHaloSystem:UpdatePlaceUnitHalo(roleUid,camp,unitId,grid)
    local heroInfo = self.world.BattleDataSystem:GetUnitDataByGrid(roleUid,grid)
    for i, v in ipairs(heroInfo.skill_list) do
        local levConf = self.world.BattleConfSystem:SkillData_data_skill_lev(v.skill_id,v.skill_level)
        if not levConf then
            assert(false,string.format("不存在技能配置[单位Id:%s][技能Id:%s][技能等级:%s]",heroInfo.unit_id,v.skill_id,v.skill_level))
        end
        -- LogTable("levConf.halo",levConf.halo)--TODO Log
        if levConf.halo then
            self:InitHalo(roleUid,camp,unitId,levConf.halo)
        end
    end
    -- self:LogKey(">>>>>>>在这里触发了UpdatePlaceUnitHalo")
    -- self:LogActiveHalos()   --TODO Log

    self:SetCurTypeNum()
    self:SendRefreshEvent()
end

function BattleHaloSystem:InitCommanderHalo(roleUid,camp,unitId)
    local info = self.world.BattleDataSystem:GetCampCommanderInfo(roleUid)
    for i, v in ipairs(info.skill_list) do
        local levConf = self.world.BattleConfSystem:SkillData_data_skill_lev(v.skill_id,v.skill_level)
        if not levConf then
            assert(false,string.format("不存在技能配置[单位Id:%s][技能Id:%s][技能等级:%s]",info.unit_id,v.skill_id,v.skill_level))
        end
        -- LogTable("levConf.halo",levConf.halo)--TODO Log
        if levConf.halo then
            self:InitHalo(roleUid,camp,unitId,levConf.halo)
        end
    end
    -- self:LogKey(">>>>>>>在这里触发了UpdatePlaceUnitHalo")
    -- self:LogActiveHalos()   --TODO Log

    self:SetCurTypeNum()
    self:SendRefreshEvent()
end

function BattleHaloSystem:CancelUnit(args)
    for k, v in pairs(self.roleUnitHalos[args.roleUid]) do
        local toRemoveHaloId = nil
        for k1, v1 in pairs(v) do
            if v1.from.unitId == args.unitId then
                v1:Destroy()
                toRemoveHaloId = k
            end
        end
        if toRemoveHaloId then
            self.roleUnitHalos[args.roleUid][toRemoveHaloId] = nil
            self.activeHalos[args.roleUid][toRemoveHaloId] = nil
        end
    end
    -- self:LogKey(">>>>>>>在这里触发了CancelUnit")
    -- self:LogActiveHalos()  --TODO Log

    self:SetCurTypeNum()
    self:SendRefreshEvent()
end

function BattleHaloSystem:InitHalo(roleUid,camp,unitId,haloInfos)
    for _, haloInfo in ipairs(haloInfos) do
        if not self.roleUnitHalos[roleUid] then
            self.roleUnitHalos[roleUid] = {}
        end
        if not self.roleUnitHalos[roleUid][haloInfo[1]] then
            self.roleUnitHalos[roleUid][haloInfo[1]] = {}
        end
        if not self.roleUnitHalos[roleUid][haloInfo[1]][haloInfo[2]] then
            local halo = Halo.New()
            local uid = self.world:GetUid(BattleDefine.UidType.halo)
            local skill = nil
            halo:SetWorld(self.world)
            halo:Init(haloInfo,uid,roleUid,camp,unitId,skill)
            self.roleUnitHalos[roleUid][haloInfo[1]][haloInfo[2]] = halo

            if not self.activeHalos[roleUid] then
                self.activeHalos[roleUid] = {}
            end
            if not self.activeHalos[roleUid][haloInfo[1]] then
                self.activeHalos[roleUid][haloInfo[1]] = {}
            end
            self.activeHalos[roleUid][haloInfo[1]][haloInfo[2]] = false
        end
    end
end

function BattleHaloSystem:OnLateUpdate()
    self:CurValidHighestHalo()
end

function BattleHaloSystem:CurValidHighestHalo()
    --TODO 获取当前生效的最高等级光环，该光环激活，其它等级取消激活
    for k, v in pairs(self.roleUnitHalos) do --k:roleUid, v:self.roleUnitHalos[roleUid]
        for k2, v2 in pairs(v) do            --k2:haloId,  v2:self.roleUnitHalos[roleUid][haloId]
            local highestLev = 0
            for k3, v3 in pairs(v2) do       --k3:haloLev, v3:self.roleUnitHalos[roleUid][haloId][haloLev] => halo
                if v3.isValid then
                    if highestLev < k3 then
                        highestLev = k3
                    end
                elseif not v3.isValid and self.activeHalos[k][k2][k3] then
                    v3:InActive()
                    self.activeHalos[k][k2][k3] = false
                    -- self:LogKey(">>>>>>>在这里触发了光环取消激活")
                    -- self:LogActiveHalos()
                    self:SendRefreshEvent()
                    -- LogError(v3.roleUid,v3.haloId,v3.haloLev,"<<<<<<<InActive")--TODO Log
                end
            end

            if highestLev > 0 then
                for k3, v3 in pairs(v2) do
                    if k3 == highestLev then
                        if not self.activeHalos[k][k2][k3] then
                            v3:OnActive()
                            self.activeHalos[k][k2][k3] = true
                            -- self:LogKey(">>>>>>>在这里触发了光环新增激活")
                            -- self:LogActiveHalos()
                            self:SendRefreshEvent()
                            -- LogError(v3.roleUid,v3.haloId,v3.haloLev,"<<<<<<<OnActive")--TODO Log
                        end
                    else
                        if self.activeHalos[k][k2][k3] then
                            v3:InActive()
                            self.activeHalos[k][k2][k3] = false
                            -- self:LogKey(">>>>>>>在这里触发了光环取消激活")
                            -- self:LogActiveHalos()
                            self:SendRefreshEvent()
                            -- LogError(v3.roleUid,v3.haloId,v3.haloLev,"<<<<<<<InActive")--TODO Log
                        end
                    end
                end
            end
        end
    end
end

function BattleHaloSystem:SendRefreshEvent()
    self.world.ClientIFacdeSystem:Call("SendEvent","BattleHaloTipsView","RefreshHaloList",self.roleUnitHalos,self.activeHalos)
end

function BattleHaloSystem:SetCurTypeNum()
    self.curTypeNum = {}
    for _,roleUid in ipairs(self.world.BattleDataSystem:GetCampRoleUid(BattleDefine.Camp.attack)) do
        local unitDatas = self.world.BattleDataSystem.rolePkDatas[roleUid].unitDatas
        if not self.curTypeNum[roleUid] then
            self.curTypeNum[roleUid] = {}
        end
        for k1, v1 in pairs(unitDatas) do
            local conf = self.world.BattleConfSystem:UnitData_data_unit_info(k1)
            if not self.curTypeNum[roleUid][conf.race_type] then
                self.curTypeNum[roleUid][conf.race_type] = 0
            end
            self.curTypeNum[roleUid][conf.race_type] = self.curTypeNum[roleUid][conf.race_type] + 1
        end
    end
    for _,roleUid in ipairs(self.world.BattleDataSystem:GetCampRoleUid(BattleDefine.Camp.defence)) do
        local unitDatas = self.world.BattleDataSystem.rolePkDatas[roleUid].unitDatas
        if not self.curTypeNum[roleUid] then
            self.curTypeNum[roleUid] = {}
        end
        for k1, v1 in pairs(unitDatas) do
            local conf = self.world.BattleConfSystem:UnitData_data_unit_info(k1)
            if not self.curTypeNum[roleUid][conf.race_type] then
                self.curTypeNum[roleUid][conf.race_type] = 0
            end
            self.curTypeNum[roleUid][conf.race_type] = self.curTypeNum[roleUid][conf.race_type] + 1
        end
    end
end

function BattleHaloSystem:GetCurTypeNum(roleUid)
    return self.curTypeNum[roleUid]
end

--TODO LogFunc
function BattleHaloSystem:LogKey(name)
    local l1 = {}

    for k, v in pairs(self.roleUnitHalos) do
        local l2 = {}
        for k2, v2 in pairs(v) do
            local l3 = {}
            if v2 ~= nil then
                for k3, v3 in pairs(v2) do
                    table.insert(l3,k3)
                end
                l2[k2] = l3
            end
        end
        l1[k] = l2
    end
    LogTable(name,l1)
end
--TODO LogFunc
function BattleHaloSystem:LogActiveHalos()
    LogTable("activeHalos",self.activeHalos)
end