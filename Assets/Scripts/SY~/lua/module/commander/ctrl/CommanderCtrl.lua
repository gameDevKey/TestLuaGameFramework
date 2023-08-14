CommanderCtrl = BaseClass("CommanderCtrl",Controller)

function CommanderCtrl:__Init()

end


function CommanderCtrl:__Delete()
    self:RemoveChestChestOpen()
    self:RemoveChestCloseTimer()
end

function CommanderCtrl:__InitCtrl()
    
end

function CommanderCtrl:__InitComplete()
    EventManager.Instance:AddEvent(EventDefine.reconnet_init_data_complete,self:ToFunc("CheckAutoOpenChest"))
    Network.Instance:SetEvent(ConnEvent.disconnect,self:ToFunc("ConnectDisconnect"))
end


function CommanderCtrl:OpenChest(data)
    mod.CommanderFacade:SendEvent(CommanderPveView.Event.RefreshTreasureChest)
    if mod.TreasureChestProxy.autoOpenFlag then
        --判断是否满足条件
        local quality = mod.TreasureChestProxy:GetAutoOpenQuality()
        local entryAttrs = mod.TreasureChestProxy:GetAutoOpenEntry()

        local tempBag = mod.RoleItemProxy:GetRoleItemType(GDefine.BagType.temp)
        local tempEquipData = tempBag[1]
        local tempEquipConf = Config.ItemData.data_item_info[tempEquipData.item_id]

        local existPartEquip = mod.RoleItemProxy:GetEquipByPart(tempEquipConf.equip_type) ~= nil


        local entryAttrFlag1 = false
        local entryAttrFlag2 = false

        local equipEntryAttrs = CommanderUtils.GetEntryAttrs(tempEquipData.attr_list)
        for i,v in ipairs(equipEntryAttrs) do
            if entryAttrs[1] and entryAttrs[1] ~= 0 and v.attr_id == entryAttrs[1] then
                entryAttrFlag1 = true
            end

            if entryAttrs[2] and entryAttrs[2] ~= 0 and v.attr_id == entryAttrs[2] then
                entryAttrFlag2 = true
            end
        end

        if (tempEquipData.quality >= quality and (not entryAttrs[1] or entryAttrs[1] == 0) and (not entryAttrs[2] or entryAttrs[2] == 0))
            or (tempEquipData.quality >= quality and entryAttrFlag1) 
            or (tempEquipData.quality >= quality and entryAttrFlag2)
            or not existPartEquip then
            --Log("达标的装备")
            --Log("信息",tempEquipConf.quality,quality,tostring(entryAttrFlag1),tostring(entryAttrFlag2),tostring(existPartEquip))
            if ViewManager.Instance:HasWindow(CommanderWindow) then
                ViewManager.Instance:OpenWindow(NewEquipWindow)
            else
                SystemMessage.Show(TI18N("自动开箱已完成"))
            end
        else
            --Log("不达标的装备")
            --mod.CommanderFacade:SendEvent(CommanderPveView.Event.PlayAutoOpenChest)
            mod.CommanderFacade:SendMsg(11009,1)
        end
    elseif mod.TreasureChestProxy:ExistTempEquip() then
        ViewManager.Instance:OpenWindow(NewEquipWindow)
    end

    self:ShowAward(data)

    mod.TreasureChestProxy.openChestData = nil
end

function CommanderCtrl:ShowAward(data)
    if not data or #data.reward <= 0 then
        return
    end

    if ViewManager.Instance:HasWindow(CommanderWindow) then
        local rewards = {}
        for i,v in ipairs(data.reward) do
            table.insert(rewards,{item_id = v.key,count = v.val})
        end
        ViewManager.Instance:OpenWindow(AwardWindow,{itemList = rewards})
    else
        table.insert(mod.TreasureChestProxy.cacheAutoOpenRewards,data.reward)
    end
end

function CommanderCtrl:HideViewChestOpen()
    if not mod.TreasureChestProxy.autoOpenFlag then
        return
    end
    Log("HideViewChestOpen")
    self:RemoveChestChestOpen()
    self.chestOpenTimer = TimerManager.Instance:AddTimer(1,3,self:ToFunc("HideViewChestOpenTimer"))
end

function CommanderCtrl:HideViewChestClose()
    if not mod.TreasureChestProxy.autoOpenFlag then
        return
    end
    Log("HideViewChestClose")
    self:RemoveChestCloseTimer()
    self.chestCloseTimer = TimerManager.Instance:AddTimer(1,2,self:ToFunc("HideViewChestCloseTimer"))
end

function CommanderCtrl:RemoveChestChestOpen()
    if self.chestOpenTimer then
        TimerManager.Instance:RemoveTimer(self.chestOpenTimer)
        self.chestOpenTimer = nil
    end
    
end

function CommanderCtrl:RemoveChestCloseTimer()
    if self.chestCloseTimer then
        TimerManager.Instance:RemoveTimer(self.chestCloseTimer)
        self.chestCloseTimer = nil
    end
end

function CommanderCtrl:HideViewChestOpenTimer()
    Log("HideViewChestOpenTimer")
    self.chestOpenTimer = nil
    self:OpenChest(mod.TreasureChestProxy.openChestData)
end

function CommanderCtrl:HideViewChestCloseTimer()
    Log("HideViewChestCloseTimer")
    self.chestCloseTimer = nil

    if mod.TreasureChestProxy.autoOpenFlag then
        if mod.TreasureChestProxy:GetChestNum() <= 0 then
            --Log("箱子数量少于0,停止了")
            mod.TreasureChestProxy.autoOpenFlag = false
        else
            --Log("再次自动打开箱子")
            mod.CommanderFacade:SendMsg(11006)
        end
    end
end

function CommanderCtrl:ConnectDisconnect()
    self:RemoveChestChestOpen()
    self:RemoveChestCloseTimer()
end

function CommanderCtrl:CheckAutoOpenChest()
    if mod.TreasureChestProxy.autoOpenFlag and mod.TreasureChestProxy:ExistTempEquip() then
        self:OpenChest(mod.TreasureChestProxy.openChestData)
    end
end