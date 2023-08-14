EquipTips = BaseClass("EquipTips",BaseTips)

function EquipTips:__Init()
    self:SetAsset("ui/prefab/tips/equip_tips_panel.prefab", AssetType.Prefab)

    self.equipItem = nil
end

function EquipTips:__Delete()
    if self.equipItem then
        self.equipItem:Destroy()
    end
end

function EquipTips:__CacheObject()
    self.equipParent = self:Find("main/equip_node")
    self.nameText =  self:Find("main/name",Text)

    self.attrObjs = {}
    for i = 1, 10 do self:GetAttrObj(i) end

    self.entryObjs = {}
    for i = 1, 5 do self:GetEntryObjs(i) end

    self.spaceNode = self:Find("main/content/space").gameObject


    self.contentRectTrans = self:Find("main/content",RectTransform)
    self.mainRectTrans = self:Find("main",RectTransform)

end

function EquipTips:GetAttrObj(index)
    local object = {}
    local item = self:Find("main/content/attr/"..tostring(index)).gameObject
    object.gameObject = item

    object.attr = {}

    local attrObj = {}
    attrObj.nameText = item.transform:Find("attr_name_1").gameObject:GetComponent(Text)
    attrObj.valText = item.transform:Find("attr_val_1").gameObject:GetComponent(Text)
    table.insert(object.attr,attrObj)

    local attrObj = {}
    attrObj.nameText = item.transform:Find("attr_name_2").gameObject:GetComponent(Text)
    attrObj.valText = item.transform:Find("attr_val_2").gameObject:GetComponent(Text)
    table.insert(object.attr,attrObj)

    self.attrObjs[index] = object
end

function EquipTips:GetEntryObjs(index)
    local object = {}
    local item = self:Find("main/content/entry/"..tostring(index)).gameObject
    object.gameObject = item
    object.descText = item.transform:Find("desc").gameObject:GetComponent(Text)
    self.entryObjs[index] = object
end

function EquipTips:__Create()
    self:SetOrder()
end

function EquipTips:__BindListener()

end

function EquipTips:__Show()
    self.equipItem = EquipItem.Create(self:Find("main/template/equip_item").gameObject)
    self.equipItem:SetParent(self.equipParent,0,0)
    self.equipItem.transform:Reset()
    self.equipItem:SetSize(121,122)
    self.equipItem:Show()
    self.equipItem:SetData(self.data)
    self.equipItem:EnableTips(false)

    local conf = Config.ItemData.data_item_info[self.data.item_id]
    local qualityName,qualityColor = CommanderUtils.GetEquipQualityInfo(self.data.quality or conf.quality)

    self.nameText.text = string.format("<color=#%s>【%s】%s</color>",qualityColor,qualityName,conf.name)


    ----基础属性
    local baseAttts = EquipUtils.GetAttrsByTag(self.data.attr_list,GDefine.AttrTag.base)
    AttrUtils.SortAttr(baseAttts)
    local baseAttrNum = #baseAttts

    local a = baseAttrNum % 2
    local num = (baseAttrNum - a) / 2
    if a > 0 then num =  num + 1 end

    local index = 1
    for i = 1, num do
        local attrInfo = baseAttts[index]
        local attrConf = Config.AttrData.data_attr_info[attrInfo.attr_id]

        local objs = self.attrObjs[i]
        objs.gameObject:SetActive(true)

        objs.attr[1].nameText.text = attrConf.name
        objs.attr[1].valText.text = attrInfo.attr_val

        index = index + 1

        if not baseAttts[index] then
            objs.attr[2].nameText.gameObject:SetActive(false)
            objs.attr[2].valText.gameObject:SetActive(false)
        else
            objs.attr[2].nameText.gameObject:SetActive(true)
            objs.attr[2].valText.gameObject:SetActive(true)

            local attrInfo = baseAttts[index]
            local attrConf = Config.AttrData.data_attr_info[attrInfo.attr_id]

            objs.attr[2].nameText.text = attrConf.name
            objs.attr[2].valText.text = attrInfo.attr_val

            index = index + 1
        end
    end
    for i = num + 1, #self.attrObjs do
        self.attrObjs[i].gameObject:SetActive(false)
    end


    --词条属性
    local entryAttrs = EquipUtils.GetAttrsByTag(self.data.attr_list,GDefine.AttrTag.entry)
    AttrUtils.SortAttr(entryAttrs)
    local entryAttrNum = #entryAttrs
    for i = 1, entryAttrNum do
        local attrInfo = entryAttrs[i]
        local attrConf = Config.AttrData.data_attr_info[attrInfo.attr_id]
        local objs = self.entryObjs[i]
        objs.gameObject:SetActive(true)

        local showAttrVal = string.format("%.1f",attrInfo.attr_val * 0.0001 * 100) .. "%"
        local desc = string.format("%s：<color=#%s>%s</color>%s",attrConf.name,attrConf.color,showAttrVal,attrConf.desc)
        objs.descText.text =  desc
    end
    for i = entryAttrNum + 1, #self.entryObjs do
        self.entryObjs[i].gameObject:SetActive(false)
    end

    --空格
    self.spaceNode:SetActive(entryAttrNum > 0)


    local posY = 203 
    Canvas.ForceUpdateCanvases()
    UIUtils.ForceRebuildLayoutImmediate(self.contentRectTrans.gameObject)
    self.mainRectTrans:SetSizeDelata(385,posY + self.contentRectTrans.sizeDelta.y)


    --
    self:AdaptionPos(self.mainRectTrans)
end