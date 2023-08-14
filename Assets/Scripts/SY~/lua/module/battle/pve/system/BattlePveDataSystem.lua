BattlePveDataSystem = BaseClass("BattlePveDataSystem",SECBSystem)
BattlePveDataSystem.NAME = "BattleDataSystem"

function BattlePveDataSystem:__Init()
    --TODO 设置初始变量
    self.enterData = nil
    self.enterExtraData = nil

    self.homeUids = {}

    self.pveConf = nil
    self.levelConf = nil

    self.roleUid = nil

    self.waitSelectItems = nil
    self.selectedItems = {}
end

function BattlePveDataSystem:__Delete()
end


function BattlePveDataSystem:SetRoleUid(uid)
    self.roleUid = uid
end

function BattlePveDataSystem:InitData(data)
    self.data = data

    self.pveConf = self.world.BattleConfSystem:PveData_data_pve(data.pve_base_id)

    self.world.BattleRandomSystem:InitRandom(data.battle_rand_seed)
    self.world.BattleChestDropSystem:InitDrop(data.reward_rand_seed,data.pve_base_id)

    self:InitExtraData(data)

    self.world.BattleCommanderSystem:InitData()

    self.world.BattleGroupSystem:InitGroup(data.pve_base_id)
    self.world.BattleTerrainSystem:InitTerrain()

    self.world.PveReserveItemSystem:InitReserveUnit()
end

function BattlePveDataSystem:InitExtraData(data)
    --local roleData = mod.RoleProxy.roleData
    --LogTable("角色数据",roleData)
    --TODO:录像模式下，赋值为录像的role_id
    --self.roleUid = roleData.role_uid

    --
    local extraData = {}
    extraData.selfCamp = BattleDefine.Camp.defence

    if extraData.selfCamp == BattleDefine.Camp.attack then
        BattleDefine.angleDir = 0
    else
        BattleDefine.angleDir = -1
    end

    self.enterExtraData = extraData
end

function BattlePveDataSystem:AddHomeUid(uid,camp)
    table.insert(self.homeUids,{camp = camp,uid = uid})
end

function BattlePveDataSystem:GetHomeUid(camp)
    for i,v in ipairs(self.homeUids) do
        if v.camp == camp then
            return v.uid
        end
    end
end

function BattlePveDataSystem:GetFakeHomeInfo()
    local info = {}
    info.attr_list = {}
    info.level = 1
    info.skill_list = {}
    info.unit_id = 3008 --TODO 修改为索引常量表的配置

    return info
end

function BattlePveDataSystem:GetCommanderInfo()
    self.data.commander.unit_id = 2004
    return self.data.commander
end

function BattlePveDataSystem:SetWaitSelectItems(waitSelectItems)
    self.waitSelectItems = waitSelectItems
end

function BattlePveDataSystem:GetWaitSelectItems()
    return self.waitSelectItems
end

function BattlePveDataSystem:AddSelectedItem(selectedItem)
    table.insert(self.selectedItems,selectedItem)
    self.world.ClientIFacdeSystem:Call("SendEvent",BattlePveItemView.Event.RefreshItem,#self.selectedItems,selectedItem)
end

function BattlePveDataSystem:GetSelectedItems()
    return self.selectedItems
end

function BattlePveDataSystem:GetSelectedItemsShowData()
    local result = {}
    for _, data in ipairs(self.selectedItems) do
        table.insert(result, data.itemConf)
    end
    return result
end

function BattlePveDataSystem:GetCampByRoleUid(roleUid)
    if roleUid == self.roleUid then
        return BattleDefine.Camp.defence
    else
        return BattleDefine.Camp.attack
    end
end

function BattlePveDataSystem:OnUpdate()
    self:UpdateCdTime()
end

function BattlePveDataSystem:UpdateCdTime()
    for i, v in ipairs(self.selectedItems) do
        if v.manualInfo and v.manualInfo.cdTime > 0 then
            v.manualInfo.cdTime = v.manualInfo.cdTime - self.world.opts.frameDeltaTime
            if v.manualInfo.cdTime < 0 then v.manualInfo.cdTime = 0 end
            self.world.ClientIFacdeSystem:Call("SendEvent",BattlePveItemView.Event.RefreshItemCd,i,v)
        end
    end
end