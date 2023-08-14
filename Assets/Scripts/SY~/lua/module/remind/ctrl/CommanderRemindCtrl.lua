CommanderRemindCtrl = BaseClass("CommanderRemindCtrl",Controller)

function CommanderRemindCtrl:__Init()

end

function CommanderRemindCtrl:__Delete()

end

function CommanderRemindCtrl:__InitComplete()

end

function CommanderRemindCtrl:CommanderOpenChest(info,data,protoId)
    local itemData = mod.RoleItemProxy:GetItemById(CommanderDefine.chestItemId)
    local flag = itemData and itemData.count > 0 or false
    info:SetFlag(flag)
end

--
function CommanderRemindCtrl:CommanderChestExistEquip(info,data,protoId)
    local tempBag = mod.RoleItemProxy:GetRoleItemType(GDefine.BagType.temp)
    local flag = tempBag and tempBag[1] ~= nil or false
    info:SetFlag(flag)
end

--宝箱强化
function CommanderRemindCtrl:CommanderChestIntensify(info,data,protoId)
    if not mod.TreasureChestProxy.treasureChestInfo then
        return
    end

    local lev = mod.TreasureChestProxy.treasureChestInfo.level
    local existNext = Config.TreasureBox.data_chest_intensify_info[lev + 1] ~= nil

    if not existNext then
        info:SetFlag(false)
    else
        local conf = Config.TreasureBox.data_chest_intensify_info[lev]
        if mod.TreasureChestProxy.treasureChestInfo.schedule >= conf.intensify then
            info:SetFlag(false)
        else
            local itemId = conf.reduce_need[1][1]
            local needNum = conf.reduce_need[1][2]
            info:SetFlag(mod.RoleItemProxy:HasItemNum(itemId,needNum))
        end
    end

    Log("宝箱强化提醒",tostring(info:IsFlag()))
end

--宝箱升级
function CommanderRemindCtrl:CommanderChestUpLev(info,data,protoId)
    if not mod.TreasureChestProxy.treasureChestInfo then
        return
    end

    local lev = mod.TreasureChestProxy.treasureChestInfo.level
    local existNext = Config.TreasureBox.data_chest_intensify_info[lev + 1] ~= nil

    if not existNext then
        info:SetFlag(false)
    else
        local conf = Config.TreasureBox.data_chest_intensify_info[lev]
        if mod.TreasureChestProxy.treasureChestInfo.schedule < conf.intensify then
            info:SetFlag(false)
        else
            info:SetFlag(mod.TreasureChestProxy.treasureChestInfo.up_time <= 0)
        end
    end

    Log("宝箱升级提醒",tostring(info:IsFlag()))
end