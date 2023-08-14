ObtainView = BaseClass("ObtainView",BaseWindow)

function ObtainView:__Init()
    self:SetAsset("ui/prefab/obtain/obtain_firstitem_window.prefab", AssetType.Prefab)

    self.groupitem = {}
end

function ObtainView:__CacheObject()
    self.backItem = self:Find("main/group_item/back_item").gameObject
    self.megItem = self:Find("main/group_item/megroup").gameObject
    self.nameText = self:Find("main/name_text",Text)
    self.itemLevel = self:Find("main/group_item/level_text",Text)
end

function ObtainView:__BindListener()
    self:Find("bg",Button):SetClick(self:ToFunc("CloseClick"))
end

function ObtainView:__Show()
    self:SetOther()
end

function ObtainView:SetOther()
    self.megItem:SetActive(false)
    local replaceCard = BackpackCardItem.Create()
    replaceCard.transform:SetParent(self.backItem.transform)
    replaceCard.transform:Reset()
    UnityUtils.SetLocalScale(self.backItem.transform,1.14,1.06,1)
    local cfg= Config.UnitData.data_unit_info[1011]
    local cardData=mod.BackpackProxy:GetDataById(1011)
    replaceCard:SetData({cfg = cfg,data = cardData})
    local item = {}
    item = replaceCard.gameObject
    local levelText = item.transform:Find("icon_con/level").gameObject:GetComponent(Text).text
    item.transform:Find("icon_con/level").gameObject:GetComponent(Text).text = nil
    self.itemLevel.text = string.format("Lv.%s",levelText) 
    local nameText = item.transform:Find("icon_con/name").gameObject:GetComponent(Text).text
    local numText = string.format("×%s",cardData.count) 
    self.nameText.text = nameText..numText
    item.transform:Find("icon_con/name").gameObject:GetComponent(Text).text = nil
    table.insert(self.groupitem,replaceCard)
end

function ObtainView:CloseClick()
    for key, value in pairs(self.groupitem) do
        value:PushPool()
    end
    self.groupitem = {}
    ViewManager.Instance:CloseWindow(ObtainView)
end