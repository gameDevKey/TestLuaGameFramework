ChestOpenPanel = BaseClass("ChestOpenPanel",BaseView)

function ChestOpenPanel:__Init()
    self:SetAsset("ui/prefab/chest/chest_open_panel.prefab",AssetType.Prefab)

    self.rewardDatas = {}
    self.rewards ={}

    self.soloShowIndex = 1
    self.rewardCount = 0

    self.addAnim = nil
    -- self.reduceAnim = nil

    self.canNext = true
    self.replaceCard = nil
    self.cardItem = {}
    mod.ChestProxy.backPackFlog = true
end

function ChestOpenPanel:__CacheObject()
    self:CacheSoloShow()
    self:CacheWholeShow()
end

function ChestOpenPanel:CacheSoloShow()
    self.soloShow = self:Find("main/solo_show").gameObject
    self.itemImg = self:Find("main/solo_show/item_info/item_img",Image)
    self.addValText = self:Find("main/solo_show/item_info/add_value",Text)
    self.itemName = self:Find("main/solo_show/item_info/item_name",Text)
    self.itemLevel = self:Find("main/solo_show/item_info/level_text",Text)
    self.assetIcon = self:Find("main/solo_show/item_info/count_info/asset_count/asset_icon",Image)
    self.assetPreValText = self:Find("main/solo_show/item_info/count_info/asset_count/pre_value",Text)

    self.unitQuality = self:Find("main/solo_show/item_info/item_img/add_quality",Image)
    self.groupItem = self:Find("main/solo_show/item_info/group_item").gameObject
end

function ChestOpenPanel:CacheWholeShow()
    self.wholeShow = self:Find("main/whole_show").gameObject

    self.rewardParent = self:Find("main/whole_show/rewards_con")
    -- self.rewardItem = self:Find("main/whole_show/rewards_con/reward_item").gameObject
end

function ChestOpenPanel:__Create()
    self.name = self.transform.name
    self:SetOrder()
    -- self.rewardItem:SetActive(false)
end

function ChestOpenPanel:__BindListener()
    self:Find("panel_bg",Button):SetClick( self:ToFunc("ShowNext") )
end

function ChestOpenPanel:__Show()
    self.soloShowIndex = 1
    self:ShowNext()
end

function ChestOpenPanel:SetData(data)
    self.data = data
    for k, v in pairs(self.data) do
        local rewardData = {}
        rewardData.itemId = v.item_id
        rewardData.addVal = v.count
        local itemCfg = Config.ItemData.data_item_info[v.item_id]
        rewardData.itemCfg = itemCfg
        rewardData.repeatNum = 0
        for k1, v1 in ipairs(self.rewardDatas) do
            if v.item_id == v1.itemId then
                v1.repeatNum = v1.repeatNum + v.count
            end
        end
        table.insert(self.rewardDatas,rewardData)
    end
    self.rewardCount = #self.data
end

function ChestOpenPanel:ShowNext()
    if not self.canNext then
        return
    else
        self.canNext = false
    end
    if self.soloShowIndex <= self.rewardCount then
        self.ClearItem(self)
        self.soloShow:SetActive(true)
        self.wholeShow:SetActive(false)
        self:SetSoloShow()
        self.soloShowIndex = self.soloShowIndex + 1
    else
        if self.soloShowIndex - self.rewardCount == 1 then
            self.soloShow:SetActive(false)
            self.wholeShow:SetActive(true)
            self:SetWholeShow()
            self.soloShowIndex = self.soloShowIndex + 1
        else
            self:CloseSelf()
        end
    end
end

function ChestOpenPanel:ClearItem()
    mod.ChestProxy.backPackFlag = true
    for key, value in pairs(self.cardItem) do
        UnityUtils.SetLocalScale(value.transform:Find("icon_con/name").gameObject.transform,1,1,1)
        UnityUtils.SetLocalPosition(value.transform:Find("icon_con/name").gameObject.transform,-25.5,-60.5,0)
        UnityUtils.SetPivot(value.transform,0.5,0.5)
        UnityUtils.SetAnchorMin(value.transform,0.5,0.5)
        UnityUtils.SetAnchorMax(value.transform,0.5,0.5)
        value:PushPool()
    end
    self.cardItem = {}
end

function ChestOpenPanel:SetSoloShow()
    local rewardData = self.rewardDatas[self.soloShowIndex]
    local replaceCard = BackpackCardItem.Create()
    replaceCard.transform:SetParent(self.groupItem.transform)
    replaceCard.transform:Reset()
    UnityUtils.SetLocalScale(self.groupItem.transform,1.245,1.23,1)
    local cfg= Config.UnitData.data_unit_info[rewardData.itemId]
    local cardData=mod.BackpackProxy:GetDataById(rewardData.itemId)
    replaceCard:SetData({cfg = cfg,data = cardData})
    local item = {}
    item = replaceCard.gameObject
    levelText = item.transform:Find("icon_con/level").gameObject:GetComponent(Text).text
    item.transform:Find("icon_con/level").gameObject:GetComponent(Text).text = nil
    self.itemLevel.text = string.format("Lv.%s",levelText) 
    nameText = item.transform:Find("icon_con/name").gameObject:GetComponent(Text).text
    self.itemName.text = nameText
    item.transform:Find("icon_con/name").gameObject:GetComponent(Text).text = nil
    table.insert(self.cardItem,replaceCard)
    self.canNext = true
    self.addValText.text = string.format("×%s",rewardData.addVal)
end

function ChestOpenPanel:SetWholeShow()
    local flag = false
    for k, v in pairs(self.rewardDatas) do
        for k1, v1 in pairs(self.rewards) do
            if v.itemCfg.id == v1.itemCfg.id then
                v.addVal = v.addVal + v1.addVal
                flag = true
            end
        end
        if flag == false then
            local replaceCard = BackpackCardItem.Create()
            replaceCard.transform:SetParent(self.rewardParent.transform)
            replaceCard.transform:Reset()
            UnityUtils.SetLocalScale(self.rewardParent.transform,0.77,0.77,1)
            local cfg= Config.UnitData.data_unit_info[v.itemId]
            local cardData=mod.BackpackProxy:GetDataById(v.itemId)
            replaceCard:SetData({cfg = cfg,data = cardData})
            local item = {}
            item.obj = replaceCard.gameObject
            item.obj.transform:Find("slider").gameObject:SetActive(false)
            levelText = item.obj.transform:Find("icon_con/level").gameObject:GetComponent(Text).text 
            item.obj.transform:Find("icon_con/level").gameObject:GetComponent(Text).text = nil
            self.itemLevel.text = string.format("Lv.%s",levelText) 
            nameText = item.obj.transform:Find("icon_con/name").gameObject:GetComponent(Text).text
            self.itemName.text = nameText
            UnityUtils.SetLocalScale(item.obj.transform:Find("icon_con/name").gameObject.transform,1.5,1.5,1)
            UnityUtils.SetLocalPosition(item.obj.transform:Find("icon_con/name").gameObject.transform,-36.5,-49,0)
            item.obj.transform:Find("icon_con/name").gameObject:GetComponent(Text).text = string.format("×%s",v.addVal)
            table.insert(self.cardItem,replaceCard)
            self.canNext = true
            table.insert(self.rewards,v)
        end
        flag = false
    end
    self.rewards = {}
    self.canNext = true
end

function ChestOpenPanel:SetAddValText(v)
    self.addValText.text = string.format("×%s",v)
    if v == 0 then
        self.addValText.text = ""
    end
end

function ChestOpenPanel:CloseSelf()
    self.rewardDatas = {}
    self.ClearItem(self)

    if self.addAnim then
        self.addAnim:Destroy()
        self.addAnim = nil
    end

    -- if self.reduceAnim then
    --     self.reduceAnim:Destroy()
    --     self.reduceAnim = nil
    -- end
    self.rewardType = -1
    self.canNext = true
    self:Hide()
end