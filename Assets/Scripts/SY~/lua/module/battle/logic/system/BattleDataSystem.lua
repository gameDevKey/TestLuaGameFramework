BattleDataSystem = BaseClass("BattleDataSystem",SECBSystem)


function BattleDataSystem:__Init()
    self.enterData = nil
    self.enterExtraData = nil

    self.campToBattleRoleUid = {}
    self.campGenIndex = 0

    self.homeUids = {}

    self.pvpConf = nil
    self.levelConf = nil

    self.rolePkDatas = {}

    --在观战或者录像时，为被观战者role_id，正常对战下为自己角色Id
    self.roleUid = nil

    self.customExtList = nil
end

function BattleDataSystem:__Delete()

end

function BattleDataSystem:SetRoleUid(uid)
    self.roleUid = uid
end

function BattleDataSystem:InitData(data)
    self.data = data

    self.pvpConf = self.world.BattleConfSystem:PvpData_data_pvp(data.qualifying_base_id)

    self.world.BattleRandomSystem:InitRandom(data.rand_seed)

    self:InitExtraData(data)
    self:InitRolePkData()

    self.world.BattleCommanderSystem:InitData()

    self.world.BattleGroupSystem:InitGroup()
    self.world.BattleTerrainSystem:InitTerrain()

    self.world.BattleReserveUnitSystem:InitReserveUnit()
end

function BattleDataSystem:InitRolePkData()
    for i,v in ipairs(self.data.role_list) do
        local data = {}
        data.baseInfo = v
        data.unitDatas = {}
        data.unitStars = {}
        data.gridToUnits = {}
        data.money = 0
        data.randomCost = 0
        data.randomNum = 0
        data.extendNum = 0
        data.unlockGrids = {}
        data.unlockNum = 0
        data.randomMoney = 0
        data.heroBuyMoney = {}
        data.randomUnits = {}
        data.waitSelectUnits = nil
        data.curNotSelectNum = 0

        self.rolePkDatas[v.role_base.role_uid] = data

        self:AddRoleMoney(v.role_base.role_uid,self.pvpConf.init_res)
        self:InitRandomUnits(v.object_list,data)
        self:InitUnitDatas(v.role_base.role_uid,v.grid_list)
    end
end

function BattleDataSystem:InitUnitDatas(roleUid,unitDatas)
    for _,v in ipairs(unitDatas) do
        self:UpdateUnit(roleUid,v)
    end
end

function BattleDataSystem:InitRandomUnits(objectList,data)
    for i,unitInfo in ipairs(objectList) do
        local unitConf = self.world.BattleConfSystem:UnitData_data_unit_info(unitInfo.unit_id)
        if not unitConf then
            assert(false, string.format("不存在的单位配置[单位Id:%s]",unitInfo.unit_id))
        end
        if unitConf.type == BattleDefine.UnitType.hero 
            or unitConf.type == BattleDefine.UnitType.magic_card then
            table.insert(data.randomUnits,unitInfo.unit_id)
        end
    end
end

function BattleDataSystem:SetRandomMoney(roleUid,money)
    local rolePkData = self.rolePkDatas[roleUid]
    rolePkData.randomMoney = money
end

function BattleDataSystem:GetRandomMoney(roleUid)
    local rolePkData = self.rolePkDatas[roleUid]
    return rolePkData.randomMoney
end

function BattleDataSystem:GetRandomUnits(roleUid)
    local randomUnits = {}
    local rolePkData = self.rolePkDatas[roleUid]
    for i,unitId in ipairs(rolePkData.randomUnits) do
        local unitData = self:GetUnitData(roleUid,unitId)
        if not unitData or unitData.star < self.pvpConf.star_up_count_limit then
            table.insert(randomUnits,unitId)
        end
    end
    return randomUnits
end

function BattleDataSystem:GetRandomUnitsByExistUnit(roleUid)
    local randomUnits = {}
    local rolePkData = self.rolePkDatas[roleUid]
    for i,unitId in ipairs(rolePkData.randomUnits) do
        local unitData = self:GetUnitData(roleUid,unitId)
        if unitData and unitData.star < self.pvpConf.star_up_count_limit then
            table.insert(randomUnits,unitId)
        end
    end
    return randomUnits
end

function BattleDataSystem:GetRandomUnitsByExclude(roleUid,excludeUnitId1,excludeUnitId2)
    local randomUnits = {}
    local rolePkData = self.rolePkDatas[roleUid]
    for i,unitId in ipairs(rolePkData.randomUnits) do
        local unitData = self:GetUnitData(roleUid,unitId)
        if unitData and unitData.star < self.pvpConf.star_up_count_limit 
            and unitId ~= excludeUnitId1 and unitId ~= excludeUnitId2 then
            table.insert(randomUnits,unitId)
        end
    end
    return randomUnits
end

function BattleDataSystem:SetWaitSelectUnits(roleUid,units)
    local rolePkData = self.rolePkDatas[roleUid]
    rolePkData.waitSelectUnits = units

    if units then
        for _,unitId in ipairs(units) do
            local unitData = self:GetUnitData(roleUid,unitId)
            if unitData then
                rolePkData.curNotSelectNum = 0
                return
            end
        end

        local heroNum = self:GetHeroNum(roleUid)
        local unlockNum = self:GetUnlockGridNum(roleUid)
        if heroNum >= unlockNum then
            rolePkData.curNotSelectNum = rolePkData.curNotSelectNum + 1
        else
            rolePkData.curNotSelectNum = 0
        end
    else
        rolePkData.curNotSelectNum = 0
    end
end

function BattleDataSystem:GetCurNotSelectNum(roleUid)
    local rolePkData = self.rolePkDatas[roleUid]
    return rolePkData.curNotSelectNum
end

function BattleDataSystem:ExistWaitSelectUnits(roleUid)
    local rolePkData = self.rolePkDatas[roleUid]
    return rolePkData.waitSelectUnits ~= nil
end

function BattleDataSystem:ExistRandomUnit(roleUid)
    local rolePkData = self.rolePkDatas[roleUid]
    return rolePkData.randomUnits and #rolePkData.randomUnits > 0
end

function BattleDataSystem:SetRandomUnits(roleUid,units)
    local rolePkData = self.rolePkDatas[roleUid]
    rolePkData.randomUnits = units
end

function BattleDataSystem:UpdateUnit(roleUid,unitData)
    local newAddHeros = {}
    local updateHeros = {}
    local cancelHeros = {}
    
    local rolePkData = self.rolePkDatas[roleUid]

    self:UnlockGrid(roleUid, unitData.grid_id)

    if unitData.unit_id == 0 and rolePkData.gridToUnits[unitData.grid_id] then
        local lastUnitData = self:GetUnitDataByGrid(roleUid,unitData.grid_id)
        rolePkData.unitDatas[lastUnitData.unit_id] = nil
        rolePkData.gridToUnits[unitData.grid_id] = nil
    elseif unitData.unit_id ~= 0 then
        --unitData.unit_id = 1003
        -- if unitData.unit_id == 10151 then
        --     unitData.skill_list = {{skill_id = 1015104,skill_level = 1}}
        -- end

        -- if unitData.unit_id == 10111 then
        --     --table.insert(unitData.skill_list,{skill_id = 1011101,skill_level = 2})
        --     unitData.skill_list = {{skill_id = 1011101,skill_level = 2}}
        -- end
        
        rolePkData.unitDatas[unitData.unit_id] = unitData
        rolePkData.gridToUnits[unitData.grid_id] = unitData.unit_id
        rolePkData.unitStars[unitData.unit_id] = unitData.star
    end
end

function BattleDataSystem:UnlockGrid(roleUid, gridId)
    local rolePkData = self.rolePkDatas[roleUid]
    if rolePkData then
        if not rolePkData.unlockGrids[gridId] then
            rolePkData.unlockGrids[gridId] = true
            rolePkData.unlockNum = rolePkData.unlockNum + 1
        end
    end
end

function BattleDataSystem:ResetGridUnlockData(roleUid)
    local rolePkData = self.rolePkDatas[roleUid]
    if rolePkData then
        rolePkData.unlockGrids = {}
        rolePkData.unlockNum = 0
    end
end

function BattleDataSystem:ClearCustomExtList()
    self.customExtList = nil
end

function BattleDataSystem:AddCustomExtGrid(gridId)
    if not self.customExtList then
        self.customExtList = {}
    end
    if not TableUtils.ContainValue(self.customExtList, gridId) then
        table.insert(self.customExtList, gridId)
    end
end

function BattleDataSystem:GetExtGridList()
    return self.customExtList or self.pvpConf.extension_list
end

function BattleDataSystem:GetUnitStar(roleUid,unitId)
    local rolePkData = self.rolePkDatas[roleUid]
    return rolePkData.unitStars[unitId] or 1
end

-- function BattleDataSystem:UpdateUnitData(roleUid,data,operateType)
--     local rolePkData = self.rolePkDatas[roleUid]
--     if not rolePkData.unlockGrids[data.grid_id] then
--         rolePkData.unlockGrids[data.grid_id] = true
--         rolePkData.unlockNum = rolePkData.unlockNum + 1
--     end

--     if data.unit_id == 0 and rolePkData.unitDatas[data.unit_id] then
--         -- if operateType ~= BattleDefine.ServerOperation.swap_hero_grid then
--         --     table.insert(cancelHeros,{unitId = rolePkData.heroGrids[v.grid_id].unit_id,grid = v.grid_id})
--         -- end
--         rolePkData.unitDatas[data.unit_id] = nil
--         rolePkData.gridToUnits[data.grid_id] = nil
--     elseif data.unit_id ~= 0 then
--         --v.unit_id = 1003
--         --v.skill_list = {{skill_id = 100301,skill_level = 1}}

--         if not rolePkData.unitDatas[data.unit_id] then
--             if operateType ~= BattleDefine.ServerOperation.swap_hero_grid then
--                 table.insert(newAddHeros,{unitId = data.unit_id,grid = data.grid_id})
--             end
--         else
--             if operateType ~= BattleDefine.ServerOperation.swap_hero_grid then
--                 table.insert(updateHeros,{roleUid = roleUid, unitId = data.unit_id,grid = data.grid_id,starOffset = data.star - rolePkData.heroGrids[data.grid_id].star})
--             end
--         end

--         rolePkData.unitDatas[data.unit_id] = data
--         rolePkData.gridToUnits[data.grid_id] = data.unit_id
--         --rolePkData.heroGrids[v.grid_id] = v

--         --TODO:调试技能，记得删
--         -- if rolePkData.baseInfo.camp == 1 then
--         --     table.insert(v.skill_list,{skill_id = 1001,skill_level = v.star + 1})
--         -- end
--         -- end
--     end
-- end


function BattleDataSystem:GetHeroBaseInfo(roleUid,heroId)
    local rolePkData = self.rolePkDatas[roleUid]
    for i,v in ipairs(rolePkData.baseInfo.unit_list) do
        if v.unit_id == heroId then
            return v
        end
    end
end

function BattleDataSystem:GetUnitDataByGrid(roleUid,grid)
    local rolePkData = self.rolePkDatas[roleUid]
    local unitId = rolePkData.gridToUnits[grid]
    return rolePkData.unitDatas[unitId]
end

function BattleDataSystem:GetUnitData(roleUid,unitId)
    local rolePkData = self.rolePkDatas[roleUid]
    return rolePkData.unitDatas[unitId]
end

function BattleDataSystem:GetHeroNum(roleUid)
    local rolePkData = self.rolePkDatas[roleUid]
    local num = 0
    for k,v in pairs(rolePkData.unitDatas) do
        num = num + 1
    end
    return num
end

function BattleDataSystem:HasUnit(roleUid,unitId)
    local rolePkData = self.rolePkDatas[roleUid]
    return rolePkData.unitDatas[unitId] ~= nil
end

function BattleDataSystem:GetHeroStarByUnitId(roleUid,unitId)
    local rolePkData = self.rolePkDatas[roleUid]
    local unitData = rolePkData.unitDatas[unitId]
    return unitData and unitData.star or 1
end

function BattleDataSystem:IsUnlockGrid(roleUid,grid)
    local rolePkData = self.rolePkDatas[roleUid]
    return rolePkData.unlockGrids[grid] or false
end

function BattleDataSystem:GetUnlockGridNum(roleUid)
    local rolePkData = self.rolePkDatas[roleUid]
    return rolePkData.unlockNum
end

function BattleDataSystem:GetMaxUnlockGridNum()
    return #self:GetExtGridList()
end

function BattleDataSystem:GetEnemyUnlockGird(roleUid)
    local camp = self:GetCampByRoleUid(roleUid)
    for _,grid in ipairs(BattleDefine.CampPlaceIndex[camp]) do
        if self:IsUnlockGrid(roleUid,grid) and not self:GetUnitDataByGrid(roleUid,grid) then
            return grid
        end
    end
    return nil
end

function BattleDataSystem:GetRoleMoney(roleUid)
    local rolePkData = self.rolePkDatas[roleUid]
    return rolePkData.money
end

function BattleDataSystem:AddRoleMoney(roleUid,num)
    local rolePkData = self.rolePkDatas[roleUid]
    rolePkData.money = rolePkData.money + num
    self.world.ServerIFaceSystem:Call(ServerEventDefine.money_update,roleUid,rolePkData.money)
    self.world.ClientIFacdeSystem:Call("SendGuideEvent","PlayerGuideDefine","role_update_money",roleUid,rolePkData.money)
    self.world.BattleStatisticsSystem:AddMoney(roleUid,num)
end

function BattleDataSystem:HasMoney(roleUid,num)
    local rolePkData = self.rolePkDatas[roleUid]
    return rolePkData.money >= num
end

function BattleDataSystem:AddRandomNum(roleUid,num)
    local rolePkData = self.rolePkDatas[roleUid]
    rolePkData.randomNum = rolePkData.randomNum + num
end

function BattleDataSystem:GetRandomNum(roleUid)
    local rolePkData = self.rolePkDatas[roleUid]
    return rolePkData.randomNum
end

function BattleDataSystem:GetRandomCostMoney(roleUid)
    local rolePkData = self.rolePkDatas[roleUid]
    local conf = self.world.BattleConfSystem:PvpData_data_pvp_buy_cost(self.pvpConf.id,rolePkData.randomNum + 1)
    return conf.cost
end

function BattleDataSystem:AddExtendNum(roleUid,num)
    local rolePkData = self.rolePkDatas[roleUid]
    rolePkData.extendNum = rolePkData.extendNum + num
end

function BattleDataSystem:GetExtendNum(roleUid)
    local rolePkData = self.rolePkDatas[roleUid]
    return rolePkData.extendNum
end

function BattleDataSystem:GetExtendMoney(roleUid)
    local rolePkData = self.rolePkDatas[roleUid]
    local conf = self.world.BattleConfSystem:PvpData_data_pvp_extend_cost(self.pvpConf.id,rolePkData.extendNum + 1)
    return conf.cost
end

function BattleDataSystem:AddHeroBuyMoney(roleUid,unitId,money)
    local rolePkData = self.rolePkDatas[roleUid]
    if not rolePkData.heroBuyMoney[unitId] then
        rolePkData.heroBuyMoney[unitId] = money
    else
        rolePkData.heroBuyMoney[unitId] = rolePkData.heroBuyMoney[unitId] + money
    end
end

function BattleDataSystem:GetHeroSellMoney(roleUid,gridId,clearFlag)
    local heroInfo = self:GetUnitDataByGrid(roleUid,gridId)
    local costMoney = self:GetHeroBuyMoney(roleUid,heroInfo.unit_id)
    if clearFlag then
        self:RemoveHeroBuyMoney(roleUid,heroInfo.unit_id)
    end
    local addMoney = FPFloat.Mul_ii(costMoney,self.pvpConf.sell_price_rate)
    local toChangeMoney = self.world.EventTriggerSystem:Trigger(BattleEvent.sell_hero,roleUid,heroInfo.unit_id)
    if toChangeMoney then
        addMoney = toChangeMoney
    end
    return addMoney
end

function BattleDataSystem:GetHeroBuyMoney(roleUid,unitId)
    local rolePkData = self.rolePkDatas[roleUid]
    return rolePkData.heroBuyMoney[unitId] or 0
end

function BattleDataSystem:RemoveHeroBuyMoney(roleUid,unitId)
    local rolePkData = self.rolePkDatas[roleUid]
    if rolePkData and rolePkData.heroBuyMoney[unitId] then
        rolePkData.heroBuyMoney[unitId] = 0
    end
end

function BattleDataSystem:GetRoleData(roleUid)
    for i,v in ipairs(self.data.role_list) do
        if v.role_base.role_uid == roleUid then
            return v
        end
    end
end

function BattleDataSystem:GetEnemyRoleData()
    for i,v in ipairs(self.data.role_list) do
        if v.role_base.role_uid ~= self.roleUid then
            return v
        end
    end
end

function BattleDataSystem:GetEnemyRoleUid()
    for i,v in ipairs(self.data.role_list) do
        if v.role_base.role_uid ~= self.roleUid then
            return v.role_base.role_uid
        end
    end
end

function BattleDataSystem:AddHomeUid(uid,camp)
    table.insert(self.homeUids,{camp = camp,uid = uid})
end

function BattleDataSystem:GetHomeUid(camp)
    for i,v in ipairs(self.homeUids) do
        if v.camp == camp then
            return v.uid
        end
    end
end

function BattleDataSystem:SwitchCampGenIndex()
    local roleNum = #self.enterExtraData.campRoles[BattleDefine.Camp.attack]
    self.campGenIndex = self.campGenIndex + 1 > roleNum and 1 or self.campGenIndex + 1
end

function BattleDataSystem:GetCampGenRoleUid(camp)
    local roles = self.enterExtraData.campRoles[camp]
    return roles[self.campGenIndex]
end

function BattleDataSystem:GetCampRoleUid(camp)
    return self.enterExtraData.campRoles[camp]
end

function BattleDataSystem:SetCampBattleRoleUid(camp,roleUid)
    self.campToBattleRoleUid[camp] = roleUid
end

function BattleDataSystem:GetCampBattleRoleUid(camp)
    return self.campToBattleRoleUid[camp]
end

function BattleDataSystem:IsCampBattleRoleUid(camp,roleUid)
    return self.campToBattleRoleUid[camp] and self.campToBattleRoleUid[camp] == roleUid
end

function BattleDataSystem:SetMaxRound(maxRound)
    self.maxRound = maxRound
end

function BattleDataSystem:SetCurRound(curRound)
    self.curRound = curRound
end

function BattleDataSystem:UpdateRoleData(data)
    for i,v in ipairs(data) do
        self.roleDatas[v.key] = v.value
    end
end

function BattleDataSystem:GetRoleUidByIndex(camp,index)
    return self.enterExtraData.campRoles[camp][index]
end

--


function BattleDataSystem:GetBaseUnitData(roleUid,unitId)
    for i,v in ipairs(self.data.role_list) do
        if v.role_base.role_uid == roleUid then
            for _,unitInfo in ipairs(v.object_list) do
                if unitInfo.unit_id == unitId then
                    return unitInfo
                end
            end
            return nil
        end
    end
end

function BattleDataSystem:GetCampHomeInfo(roleUid)
    for i,v in ipairs(self.data.role_list) do
        if v.role_base.role_uid == roleUid then
            for _,unitInfo in ipairs(v.object_list) do
                local unitConf = self.world.BattleConfSystem:UnitData_data_unit_info(unitInfo.unit_id)
                if unitConf.type == BattleDefine.UnitType.home then
                    return unitInfo
                end
            end
        end
    end
end

function BattleDataSystem:GetCampCommanderInfo(roleUid)
    for i,v in ipairs(self.data.role_list) do
        if v.role_base.role_uid == roleUid then
            for _,unitInfo in ipairs(v.object_list) do
                local unitConf = self.world.BattleConfSystem:UnitData_data_unit_info(unitInfo.unit_id)
                if unitConf.type == BattleDefine.UnitType.commander then
                    return unitInfo
                end
            end
        end
    end
end

function BattleDataSystem:GetMagicCards(roleUid)
    local magicCards = {}
    for i,v in ipairs(self.data.role_list) do
        if v.role_base.role_uid == roleUid then
            for _,unitInfo in ipairs(v.object_list) do
                local unitConf = self.world.BattleConfSystem:UnitData_data_unit_info(unitInfo.unit_id)
                if unitConf.type == BattleDefine.UnitType.magic_card then
                    table.insert(magicCards,unitInfo)
                end
            end
        end
    end
    return magicCards
end

function BattleDataSystem:GetAsset(assetType)
    return self.assetDatas[assetType]
end


function BattleDataSystem:InitExtraData(data)
    --local roleData = mod.RoleProxy.roleData
    --LogTable("角色数据",roleData)
    --TODO:录像模式下，赋值为录像的role_id
    --self.roleUid = roleData.role_uid

    
    --
    local selfCamp = nil
    local campRoles = {}
    local roleUidToCamp = {}
    for i,v in ipairs(data.role_list) do
        if v.role_base.role_uid == self.roleUid then
            selfCamp = v.camp
        end

        if not campRoles[v.camp] then
            campRoles[v.camp] = {}
        end
        table.insert(campRoles[v.camp],v.role_base.role_uid)
        roleUidToCamp[v.role_base.role_uid] = v.camp
    end

    --
    local extraData = {}
    extraData.selfCamp = selfCamp
    extraData.campRoles = campRoles
    extraData.roleUidToCamp = roleUidToCamp

    if selfCamp == BattleDefine.Camp.attack then
        self.world.BattleTerrainSystem.angleDir = 0
    else
        self.world.BattleTerrainSystem.angleDir = -1
    end

    --Log("自身阵营",selfCamp,BattleDefine.angleDir)

    self.enterExtraData = extraData
end

function BattleDataSystem:GetCampByRoleUid(roleUid)
    return self.enterExtraData.roleUidToCamp[roleUid]
end

function BattleDataSystem:GetCampByFrom(from)
    local selfCamp = self:GetCampByRoleUid(self.roleUid)
    if from == 1 then
        return selfCamp
    elseif from == -1 then
        if selfCamp == BattleDefine.Camp.attack then
            return BattleDefine.Camp.defence
        elseif selfCamp == BattleDefine.Camp.defence then
            return BattleDefine.Camp.attack
        end
    end
end

function BattleDataSystem:CanExtGrid(grid)
    for i,v in ipairs(self:GetExtGridList()) do
        if v == grid then
            return true
        end
    end
    return false
end