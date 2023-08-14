TreasureChestExpediteWindow = BaseClass("TreasureChestExpediteWindow", BaseWindow)
TreasureChestExpediteWindow.__topInfo = true
TreasureChestExpediteWindow.__bottomTab = true

TreasureChestExpediteWindow.Event = EventEnum.New(
    "RefreshExpeditetInfo"
)

function TreasureChestExpediteWindow:__Init()
    self:SetAsset("ui/prefab/commander/treasure_chest_expedite_window.prefab", AssetType.Prefab)
    self.maxNum = 0
    self.curNum = 0
    self.typeIndex = 0
    self.propItem = nil
end

function TreasureChestExpediteWindow:__Delete()
    if self.propItem then
        self.propItem:Destroy()
    end
end

function TreasureChestExpediteWindow:__ExtendView()
end

function TreasureChestExpediteWindow:__CacheObject()
    self.expediteNum = self:Find("main/expedite_num",Text)
    self.expediteTime = self:Find("main/reduce_time",Text)
    self.itemParent = self:Find("main/item_node")
end

function TreasureChestExpediteWindow:__BindListener()
    self:Find("main/close_btn",Button):SetClick(self:ToFunc("CloseClick"))
    self:Find("main/reduce_btn",Button):SetClick(self:ToFunc("ReduceItemClick"))
    self:Find("main/add_btn",Button):SetClick(self:ToFunc("AddItemClick"))
    self:Find("main/confirm_btn",Button):SetClick(self:ToFunc("ConfirmClick"))
end

function TreasureChestExpediteWindow:__BindEvent()
    self:BindEvent(TreasureChestExpediteWindow.Event.RefreshExpeditetInfo)
end

function TreasureChestExpediteWindow:__Create()

end

function TreasureChestExpediteWindow:__Show()
    self:RefreshExpeditetInfo()
end

function TreasureChestExpediteWindow:RefreshExpeditetInfo()
    local itemId,typeIndex,maxNum = mod.TreasureChestProxy:GetExpeditetItemInfo()
    self.typeIndex = typeIndex
    self.maxNum = maxNum

   
   
    if self.maxNum > 0 then
        local remainTime = Network.Instance:GetRemoteRemainTime(mod.TreasureChestProxy.treasureChestInfo.up_time)
        local reduceTime = Config.TreasureBox.data_chest_expedite_info[typeIndex].reduce_time
        local diff = remainTime % reduceTime
        self.curNum = (remainTime - diff) / reduceTime
        if diff > 0 then
            self.curNum = self.curNum + 1
        end

        if self.curNum > self.maxNum then
            self.curNum = self.maxNum
        end
    end

    local conf = Config.ItemData.data_item_info[itemId]

    self:RefreshItemNumInfo()

    local itemData = {}
    itemData.item_id = itemId
    self.propItem = PropItem.Create()
    self.propItem:SetParent(self.itemParent,0,0)
    self.propItem.transform:Reset()
    self.propItem:SetSize(135,120)
    self.propItem:Show()
    self.propItem:SetData(itemData)
end

function TreasureChestExpediteWindow:GetItemNum(itemId,minNum)
    local num = mod.RoleItemProxy:GetItemNum(itemId)
    if num < minNum then
        return false,0
    else
        return true,tonumber((num - (num % minNum)) / minNum)
    end
end

function TreasureChestExpediteWindow:AddItemClick()
    if self.curNum + 1 <= self.maxNum then
        self.curNum = self.curNum + 1
        self:RefreshItemNumInfo()
    end
end

function TreasureChestExpediteWindow:ReduceItemClick()
    if self.curNum - 1 >= 0 then
        self.curNum = self.curNum - 1
        self:RefreshItemNumInfo()
    end
end

function TreasureChestExpediteWindow:RefreshItemNumInfo()
    self.expediteNum.text = self.curNum .. "/" .. self.maxNum
    local expediteTime = Config.TreasureBox.data_chest_expedite_info[self.typeIndex].reduce_time * self.curNum
    self.expediteTime.text = "可加速时间：" .. TimeUtils.GetTimeFormat(expediteTime)
end

function TreasureChestExpediteWindow:ConfirmClick()
    if self.curNum <= 0 then
        SystemMessage.Show("选择数量少于0,无法加速")
    else
        mod.CommanderFacade:SendMsg(11005,self.typeIndex,self.curNum)
        self:CloseClick()
    end
end

function TreasureChestExpediteWindow:CloseClick()
    ViewManager.Instance:CloseWindow(TreasureChestExpediteWindow)
end

