PropTips = BaseClass("PropTips",BaseTips)

function PropTips:__Init()
    self:SetAsset("ui/prefab/tips/prop_tips_panel.prefab", AssetType.Prefab)
    self.porpItem = nil
end

function PropTips:__Delete()
    if self.porpItem then
        self.porpItem:Destroy()
    end
end

function PropTips:__CacheObject()
    self.itemParent = self:Find("main/item_node")
    self.nameText =  self:Find("main/name",Text)
    self.descText =  self:Find("main/content/desc",Text)

    self.wayObjs = {}
    for i = 1, 5 do self:GetWayObjs(i) end

    self.waySpaceNode = self:Find("main/content/way_space").gameObject

    self.contentRectTrans = self:Find("main/content",RectTransform)
    self.mainRectTrans = self:Find("main",RectTransform)
end

function PropTips:GetWayObjs(index)
    local object = {}
    local item = self:Find("main/content/way_list/"..tostring(index)).gameObject
    object.gameObject = item
    object.btn = item:GetComponent(Button)
    object.nameText = item.transform:Find("name").gameObject:GetComponent(Text)
    self.wayObjs[index] = object
end

function PropTips:__Create()
    self:SetOrder()
end

function PropTips:__BindListener()

end

function PropTips:__Show()
    self.porpItem = PropItem.Create(self:Find("template/prop_item").gameObject)
    self.porpItem:SetParent(self.itemParent,0,0)
    self.porpItem.transform:Reset()
    self.porpItem:SetScale(0.8,0.8)
    self.porpItem:Show()
    self.porpItem:SetData(self.data)
    self.porpItem:EnableTips(false)

    local conf = Config.ItemData.data_item_info[self.data.item_id]
    local _,qualityColor = CommanderUtils.GetEquipQualityInfo(conf.quality)

    self.nameText.text = string.format("<color=#%s>%s</color>",qualityColor,conf.name)


    self.descText.text = conf.desc


    --设置获取方式
    for i = 1, #self.wayObjs do
        self.wayObjs[i].gameObject:SetActive(false)
    end

    --空格
    self.waySpaceNode:SetActive(false)

    UIUtils.ForceRebuildLayoutImmediate(self.contentRectTrans.gameObject)
    self.mainRectTrans:SetSizeDelata(385,167 + self.contentRectTrans.sizeDelta.y)

    --自适应
    self:AdaptionPos(self.mainRectTrans)
end