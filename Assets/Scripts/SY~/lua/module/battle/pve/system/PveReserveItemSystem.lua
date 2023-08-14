PveReserveItemSystem = BaseClass("PveReserveItemSystem",SECBEntitySystem)

function PveReserveItemSystem:__Init()
    self.isReserve = false
    self.isReserveRandom = false
    self.lastGroup = nil
    self.lastGroupIndexs = nil
    self.reserveIndex = 1
end

function PveReserveItemSystem:__Delete()
end


function PveReserveItemSystem:OnInitSystem()
end


function PveReserveItemSystem:InitReserveUnit()
    local pveConf = self.world.BattleDataSystem.pveConf
    if pveConf.type == BattleDefine.PvpType.reserve then
        self.isReserve = true
        self.isReserveRandom = true
        self.world.BattleStateSystem:SetLocalRun(true)
        self.world.BattleOperationSystem:SetClientInput(true)
    end
end

function PveReserveItemSystem:OnUpdate()
    if not self.isReserve then
        return
    end

    --[[local pveConf = self.world.BattleDataSystem.pveConf

    local group = self.world.BattleGroupSystem.group + 1

    if not self.lastGroup or self.lastGroup ~= group then
        self.lastGroup = group
        self.lastGroupIndexs = {[BattleDefine.Camp.attack] = {},[BattleDefine.Camp.defence] = {}}
    end

    local reserveUnits = self.world.BattleConfSystem:BattleDungeonData_data_reserve_unit(pveConf.id,group,self.reserveIndex)
    self:ReserveUnits(reserveUnits)]]
end

--[[function PveReserveItemSystem:ReserveUnits(reserveUnits)
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
        self.world.ClientIFacdeSystem:Call("SendEvent",BattleInfoView.Event.RefreshMoney)
    end
end]]

function PveReserveItemSystem:GetReserveSelectItems()
    if not self.isReserveRandom then
        return nil
    end
    
    local itemList = nil
    local pveConf = self.world.BattleDataSystem.pveConf
    local conf = self.world.BattleConfSystem:PveData_data_random_item(pveConf.id,self.reserveIndex)
    if conf and conf.item_key then
        itemList = {}
        for i, v in ipairs(conf.item_key) do
            local item = {}
            item.item_group_id = v[1]
            item.item_id = v[2]
            table.insert(itemList,item)
        end
    end
    return itemList
end