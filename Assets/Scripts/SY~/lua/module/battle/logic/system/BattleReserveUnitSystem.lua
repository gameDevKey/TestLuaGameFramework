BattleReserveUnitSystem = BaseClass("BattleReserveUnitSystem",SECBEntitySystem)

function BattleReserveUnitSystem:__Init()
    self.isReserve = false
    self.isReserveRandom = false
    self.lastGroup = nil
    self.lastGroupIndexs = nil
    self.reserveIndex = 1
end

function BattleReserveUnitSystem:__Delete()

end

function BattleReserveUnitSystem:OnInitSystem()

end

function BattleReserveUnitSystem:InitReserveUnit()
    local pvpConf = self.world.BattleDataSystem.pvpConf
    if pvpConf.type == BattleDefine.PvpType.reserve then
        self.isReserve = true
        self.isReserveRandom = true
        self.world.BattleStateSystem:SetLocalRun(true)
        self.world.BattleOperationSystem:SetClientInput(true)
    elseif pvpConf.type == BattleDefine.PvpType.debug then
        self.isReserve = true
        self.world.BattleStateSystem:SetLocalRun(true)
        self.world.BattleOperationSystem:SetClientInput(true)
    end
end

function BattleReserveUnitSystem:OnUpdate()
    if not self.isReserve then
        return
    end

    local pvpConf = self.world.BattleDataSystem.pvpConf

    local group = self.world.BattleGroupSystem.group + 1

    if not self.lastGroup or self.lastGroup ~= group then
        self.lastGroup = group
        self.lastGroupIndexs = {[BattleDefine.Camp.attack] = {},[BattleDefine.Camp.defence] = {}}
    end

    local reserveUnits = self.world.BattleConfSystem:BattleDungeonData_data_reserve_unit(pvpConf.id,BattleDefine.Camp.attack,group,self.reserveIndex)
    self:ReserveUnits(BattleDefine.Camp.attack,reserveUnits)

    local reserveUnits = self.world.BattleConfSystem:BattleDungeonData_data_reserve_unit(pvpConf.id,BattleDefine.Camp.defence,group,self.reserveIndex)
    self:ReserveUnits(BattleDefine.Camp.defence,reserveUnits)
end


function BattleReserveUnitSystem:ReserveUnits(camp,reserveUnits)
    if not reserveUnits then
        return
    end

    local roleUid = self.world.BattleDataSystem:GetCampRoleUid(camp)[1]

    local flag = false
    local groupTime = self.world.BattleGroupSystem.groupTime

    for i,v in ipairs(reserveUnits) do
        if not self.lastGroupIndexs[camp][i] then
            if groupTime >= v.delay_time then
                flag = true
                self.lastGroupIndexs[camp][i] = true
                if v.unit_id > 0 then
                    self.world.BattleMixedSystem:UpdateUnit(roleUid,v.unit_id,v.slot,v.star)
                else
                    self.world.BattleMixedSystem:RemoveUnit(roleUid,v.slot)
                end
            end
        end
    end

    if flag then
        self.world.ClientIFacdeSystem:Call("RefreshHeroGrid",roleUid)
        self.world.ClientIFacdeSystem:Call("SendEvent","BattleInfoView","RefreshMoney")
        self.world.ClientIFacdeSystem:Call("SendEvent","BattleHeroGridView","RefreshExtGrid")
    end
end


function BattleReserveUnitSystem:GetReserveSelectUnits(roleUid)
    if not self.isReserveRandom then
        return nil
    end
    
    local pvpConf = self.world.BattleDataSystem.pvpConf
    local camp = self.world.BattleDataSystem:GetCampByRoleUid(roleUid)
    local num = self.world.BattleDataSystem:GetRandomNum(roleUid) + 1
    local conf = self.world.BattleConfSystem:BattleDungeonData_data_random_unit(pvpConf.id,camp,num,self.reserveIndex)
    return conf and conf.unit_id or nil
end