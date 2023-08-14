TreasureChestProxy = BaseClass("TreasureChestProxy",Proxy)

function TreasureChestProxy:__Init()
    self.treasureChestInfo = nil
    self.autoOpenFlag = false
    self.openChestData = nil

    self.cacheAutoOpenRewards = {}
end

function TreasureChestProxy:__InitProxy()
    self:BindMsg(11002)
    self:BindMsg(11005)
    self:BindMsg(11006)
    self:BindMsg(11007)
    self:BindMsg(11008)
    self:BindMsg(11009)
end

--宝箱信息
function TreasureChestProxy:Recv_11002(data)
    LogTable("接收11002",data)
    self.treasureChestInfo = data
    mod.CommanderFacade:SendEvent(TreasureChestUpWindow.Event.RefreshTreasureChestInfo)
end

function TreasureChestProxy:GetChestNum()
    local itemData = mod.RoleItemProxy:GetItemById(CommanderDefine.chestItemId)
    return itemData and itemData.count or 0
end


function TreasureChestProxy:Send_11005(opType,num)
    local data = {}
    data.type = opType
    data.times = num
    LogTable("发送11005",data)
    return data
end
function TreasureChestProxy:Recv_11005(data)
    LogTable("接收11005",data)
    self.treasureChestInfo.level = data.level
    self.treasureChestInfo.schedule = data.schedule
    self.treasureChestInfo.up_time = data.up_time
    self.treasureChestInfo.help_times = data.help_times
    mod.CommanderFacade:SendEvent(TreasureChestUpWindow.Event.RefreshTreasureChestInfo)
end

--宝箱信息
function TreasureChestProxy:Recv_11006(data)
    LogTable("接收11006",data)
    if data.code == 1 then
        --mod.CommanderCtrl:OpenChest(data)
        self.openChestData = data
        
        if ViewManager.Instance:HasWindow(CommanderWindow) then
            mod.CommanderFacade:SendEvent(CommanderPveView.Event.PlayFirstChestOpenAnim)
            mod.CommanderFacade:SendEvent(CommanderPveView.Event.RefreshTipsState)
        else
            mod.CommanderCtrl:HideViewChestOpen()
        end
    end
end

--宝箱升级
function TreasureChestProxy:Recv_11007(data)
    LogTable("接收11007",data)
    self.treasureChestInfo.level = data.level
    self.treasureChestInfo.schedule = data.schedule
    self.treasureChestInfo.up_time = data.up_time
    mod.CommanderFacade:SendEvent(TreasureChestUpWindow.Event.RefreshTreasureChestInfo)
end

function TreasureChestProxy:Send_11008(conditions)
    local data = {}
    data.condition_list = conditions
    LogTable("发送11008",data)
    return data
end
function TreasureChestProxy:Recv_11008(data)
    LogTable("接收11008",data)
    self.treasureChestInfo.condition_list = data.condition_list
    mod.CommanderFacade:SendEvent(AutoOpenChestWindow.Event.RefreshAutoOpenChest)
end


function TreasureChestProxy:Send_11009(opType)
    local data = {}
    data.type = opType
    LogTable("发送11009",data)
    return data
end

function TreasureChestProxy:Recv_11009(data)
    LogTable("接收11009",data)
    if data.code == 1 then
        if data.type == 1 then
            if ViewManager.Instance:HasWindow(NewEquipWindow) then
                ViewManager.Instance:CloseWindow(NewEquipWindow)
            end
            if ViewManager.Instance:HasWindow(CommanderWindow) then
                mod.CommanderFacade:SendEvent(CommanderPveView.Event.PlayChestCloseAnim)
            else
                mod.CommanderCtrl:HideViewChestClose()
            end
        elseif data.type == 2 then
            if self:ExistTempEquip() then
                mod.CommanderFacade:SendEvent(NewEquipWindow.Event.RefreshNewEquip)
            else
                ViewManager.Instance:CloseWindow(NewEquipWindow)
                if ViewManager.Instance:HasWindow(CommanderWindow) then
                    mod.CommanderFacade:SendEvent(CommanderPveView.Event.PlayChestCloseAnim)
                else
                    mod.CommanderCtrl:HideViewChestClose()
                end
            end
        end
        mod.CommanderFacade:SendEvent(CommanderPveView.Event.RefreshTipsState)
        --mod.CommanderFacade:SendEvent(CommanderPveView.Event.RefreshTreasureChest)
    end
end

function TreasureChestProxy:GetChestLevQualityProp(lev)
    local qualityToProps = {}
    for _,v in ipairs(Config.EquipBorn.data_quality_prop) do
        if lev >= v.level[1]  and lev <= v.level[2] then
            for _,qualityInfo in ipairs(v.quality) do
                qualityToProps[qualityInfo[1]] = qualityInfo[2]
            end
        end
    end
    return qualityToProps
end


function TreasureChestProxy:GetAutoOpenQuality()
    for i,v in ipairs(self.treasureChestInfo.condition_list) do
        if v.key == 1 then
            return v.val
        end
    end
    return GDefine.Quality.white
end

function TreasureChestProxy:GetAutoOpenEntry()
    local entrys = {}
    for i,v in ipairs(self.treasureChestInfo.condition_list) do
        if v.key == 2 then
            table.insert(entrys,v.val)
        end
    end
    return entrys
end

function TreasureChestProxy:GetAllEntryAttrs()
    local entrys = {}
    for i,v in ipairs(Config.AttrData.data_attr_info_list) do
        if v.attr_tag == GDefine.AttrTag.entry then
            table.insert(entrys,v.id)
        end
    end
    return entrys
end


function TreasureChestProxy:ExistTempEquip()
    local tempBag = mod.RoleItemProxy:GetRoleItemType(GDefine.BagType.temp)
    if tempBag and tempBag[1] then
        return true
    else
        return false
    end
end

function TreasureChestProxy:GetExpeditetItemInfo()
    local itemId1 = Config.TreasureBox.data_chest_expedite_info[4].reduce_need[1][1]
    local itemMinNum1 = Config.TreasureBox.data_chest_expedite_info[4].reduce_need[1][2]
    local typeFlag1,typeNum1 = self:IsExpeditetItem(itemId1,itemMinNum1)

    local itemId2 = Config.TreasureBox.data_chest_expedite_info[2].reduce_need[1][1]
    local itemMinNum2 = Config.TreasureBox.data_chest_expedite_info[2].reduce_need[1][2]
    local typeFlag2,typeNum2 = self:IsExpeditetItem(itemId2,itemMinNum2)


    local typeIndex = 0
    local maxNum = 0

    if not typeFlag1 and not typeFlag2 then
        typeIndex = 4
        maxNum = 0
    elseif typeFlag1 then
        typeIndex = 4
        maxNum = typeNum1
    elseif typeFlag2 then
        typeIndex = 2
        maxNum = typeNum2
    end

    local itemId = Config.TreasureBox.data_chest_expedite_info[typeIndex].reduce_need[1][1]
    return itemId,typeIndex,maxNum,(typeFlag1 or typeFlag2)
end

function TreasureChestProxy:IsExpeditetItem(itemId,minNum)
    local num = mod.RoleItemProxy:GetItemNum(itemId)
    if num < minNum then
        return false,0
    else
        return true,tonumber((num - (num % minNum)) / minNum)
    end
end