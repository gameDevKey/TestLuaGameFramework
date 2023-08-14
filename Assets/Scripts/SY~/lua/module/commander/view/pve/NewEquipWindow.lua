NewEquipWindow = BaseClass("NewEquipWindow", BaseWindow)
NewEquipWindow.__topInfo = true
NewEquipWindow.__bottomTab = true
NewEquipWindow.__adaptive = true
NewEquipWindow.notTempHide = true

NewEquipWindow.Event = EventEnum.New(
    "RefreshNewEquip"
)

function NewEquipWindow:__Init()
    self:SetAsset("ui/prefab/commander/new_equip_window.prefab", AssetType.Prefab)

    self.equipItems = {}
    self.sellTips = false

    self.entryEffects = {}
end

function NewEquipWindow:__Delete()
    self:RemoveEquipItems()
    self:RemoveEntryEffects()
end

function NewEquipWindow:__ExtendView()
end

function NewEquipWindow:__CacheObject()
    self.equipObjs = {}
    self:GetEquipObj("cur_node",1)
    self:GetEquipObj("bag_node",2,true)

    self.equipItem = self:Find("template/equip_item").gameObject
    self.entryAttrItem = self:Find("template/entry_item").gameObject

    self.sellPrice = self:Find("main/op_node/sell_btn/price",Text)

    self.mainRectTrans = self:Find("main",RectTransform)

    self.infoRectTrans = self:Find("main/info_node",RectTransform)

    self.infoVerticalLayoutGroup = self:Find("main/info_node",VerticalLayoutGroup)

    self.sellBtnNode = self:Find("main/op_node/sell_btn").gameObject
end

function NewEquipWindow:__BindListener()
    self:Find("main/op_node/sell_btn",Button):SetClick(self:ToFunc("SellClick"))
    self:Find("main/op_node/put_on_btn",Button):SetClick(self:ToFunc("ReplaceClick"))
    self:Find("main/close_btn",Button):SetClick(self:ToFunc("CloseClick"))
end

function NewEquipWindow:__BindEvent()
    self:BindEvent(NewEquipWindow.Event.RefreshNewEquip)
end

function NewEquipWindow:GetEquipObj(name,index,isBag)
    local object = {}
    local root = self:Find(string.format("main/info_node/%s",name)).gameObject
    object.gameObject = root
    object.transform = root.transform
    object.equipParent = root.transform:Find("info/equip_node")
    object.nameText = root.transform:Find("info/name").gameObject:GetComponent(Text)
    object.newGetNode = root.transform:Find("info/new_get_node")

    object.attrs = {}
    object.attrs[GDefine.Attr.max_hp] = {}
    object.attrs[GDefine.Attr.max_hp].valText = root.transform:Find("info/max_hp/val").gameObject:GetComponent(Text)

    object.attrs[GDefine.Attr.atk] = {}
    object.attrs[GDefine.Attr.atk].valText = root.transform:Find("info/atk/val").gameObject:GetComponent(Text)

    object.attrs[GDefine.Attr.atk_speed] = {}
    object.attrs[GDefine.Attr.atk_speed].valText = root.transform:Find("info/atk_speed/val").gameObject:GetComponent(Text)


    object.attrs[GDefine.Attr.atk_distance] = {}
    object.attrs[GDefine.Attr.atk_distance].valText = root.transform:Find("info/atk_distance/val").gameObject:GetComponent(Text)

    if isBag then
        object.battlePowerDown = root.transform:Find("info/name/battle_power_down").gameObject
        object.battlePowerUp = root.transform:Find("info/name/battle_power_up").gameObject
        object.battlePower = root.transform:Find("info/name/battle_power").gameObject:GetComponent(Text)

        object.attrs[GDefine.Attr.max_hp].diffText = root.transform:Find("info/max_hp/val/diff").gameObject:GetComponent(Text)
        object.attrs[GDefine.Attr.atk].diffText = root.transform:Find("info/atk/val/diff").gameObject:GetComponent(Text)
        object.attrs[GDefine.Attr.atk_speed].diffText = root.transform:Find("info/atk_speed/val/diff").gameObject:GetComponent(Text)
        object.attrs[GDefine.Attr.atk_distance].diffText = root.transform:Find("info/atk_distance/val/diff").gameObject:GetComponent(Text)

        object.attrs[GDefine.Attr.max_hp].downNode = root.transform:Find("info/max_hp/val/down").gameObject
        object.attrs[GDefine.Attr.max_hp].upNode = root.transform:Find("info/max_hp/val/up").gameObject

        object.attrs[GDefine.Attr.atk].downNode = root.transform:Find("info/atk/val/down").gameObject
        object.attrs[GDefine.Attr.atk].upNode = root.transform:Find("info/atk/val/up").gameObject

        object.attrs[GDefine.Attr.atk_speed].downNode = root.transform:Find("info/atk_speed/val/down").gameObject
        object.attrs[GDefine.Attr.atk_speed].upNode = root.transform:Find("info/atk_speed/val/up").gameObject

        object.attrs[GDefine.Attr.atk_distance].downNode = root.transform:Find("info/atk_distance/val/down").gameObject
        object.attrs[GDefine.Attr.atk_distance].upNode = root.transform:Find("info/atk_distance/val/up").gameObject
    end

    object.entryItemParent = root.transform:Find("entry_list")

    object.entryAttrItems = {}

    self.equipObjs[index] = object
end

function NewEquipWindow:__Show()
    self:RefreshNewEquip(true)
    TimerManager.Instance:AddTimer(1,0.1,self:ToFunc("TriggerGuideEvent"))
end

function NewEquipWindow:TriggerGuideEvent()
    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_open, "new_equip")
end

function NewEquipWindow:RemoveEquipItems()
    for i,v in ipairs(self.equipItems) do
        v:Destroy()
    end
end

function NewEquipWindow:RemoveEntryEffects()
    for i,v in ipairs(self.entryEffects) do
        v:Delete()
    end
    self.entryEffects = {}
end

function NewEquipWindow:RefreshNewEquip(isNewGet)
    self:RemoveEquipItems()
    self:RemoveEntryEffects()

    local tempBag = mod.RoleItemProxy:GetRoleItemType(GDefine.BagType.temp)
    local tempEquipData = tempBag and tempBag[1] or nil
    local tempEquipConf = Config.ItemData.data_item_info[tempEquipData.item_id]

    local equipData = mod.RoleItemProxy:GetEquipByPart(tempEquipConf.equip_type)

    local _,_ = self:SetEquip(1,equipData,nil,false)
    local upArrowNum,downArrowNum = self:SetEquip(2,tempEquipData,equipData,isNewGet)

    local conf = Config.TreasureBox.data_chest_quality_info[tempEquipData.quality]

    self.sellPrice.text = conf.reward[1][2]
    
    UIUtils.ForceRebuildLayoutImmediate(self.infoRectTrans.gameObject)
    self.mainRectTrans:SetSizeDelata(665,421.5 + self.infoRectTrans.sizeDelta.y)

    if not equipData then
        self.sellTips = false
        self.sellBtnNode:SetActive(false)
    else
        self.sellBtnNode:SetActive(true)
        local equipConf = Config.ItemData.data_item_info[equipData.item_id]
        if tempEquipConf.quality > equipConf.quality and upArrowNum > downArrowNum then
            self.sellTips = true
        else
            self.sellTips = false
        end
    end
end

function NewEquipWindow:SetEquip(index,equipData,compEquipData,isNewGet)
    local objs = self.equipObjs[index]
    objs.gameObject:SetActive(equipData ~= nil)

    if not equipData then
        return
    end

    local upArrowNum = 0
    local downArrowNum = 0

    local equipConf = Config.ItemData.data_item_info[equipData.item_id]

    local equipItem = EquipItem.Create(self.equipItem)
    equipItem:EnableTips(false)
    equipItem:SetParent(objs.equipParent)
    equipItem:SetSize(121,122)
    equipItem:Show()
    equipItem:SetData(equipData)
    table.insert(self.equipItems,equipItem)


    local qualityName,qualityColor = CommanderUtils.GetEquipQualityInfo(equipData.quality)

    objs.nameText.text = string.format("<color=#%s>【%s】%s</color>"
        ,qualityColor,qualityName,equipConf.name)

    if objs.newGetNode then
        objs.newGetNode.gameObject:SetActive(isNewGet == true)
    end

    local maxHpVal = CommanderUtils.GetAttrVal(equipData.attr_list,GDefine.Attr.max_hp)
    local compMaxHpVal = compEquipData and CommanderUtils.GetAttrVal(compEquipData.attr_list,GDefine.Attr.max_hp) or nil
    objs.attrs[GDefine.Attr.max_hp].valText.text = maxHpVal
    if compMaxHpVal then
        objs.attrs[GDefine.Attr.max_hp].downNode:SetActive(maxHpVal < compMaxHpVal)
        objs.attrs[GDefine.Attr.max_hp].upNode:SetActive(maxHpVal > compMaxHpVal)

        local diffVal = maxHpVal - compMaxHpVal
        if diffVal > 0 then
            objs.attrs[GDefine.Attr.max_hp].diffText.text = string.format("<color=#25cb6b>(+%s)</color>",diffVal)
        elseif diffVal < 0 then
            objs.attrs[GDefine.Attr.max_hp].diffText.text = string.format("<color=#cb5425>(%s)</color>",diffVal)
        else
            objs.attrs[GDefine.Attr.max_hp].diffText.text = ""
        end 

        if maxHpVal > compMaxHpVal then 
            upArrowNum = upArrowNum + 1
        else
            downArrowNum = downArrowNum + 1
        end
    elseif objs.attrs[GDefine.Attr.max_hp].downNode then
        objs.attrs[GDefine.Attr.max_hp].downNode:SetActive(false)
        objs.attrs[GDefine.Attr.max_hp].upNode:SetActive(false)
        objs.attrs[GDefine.Attr.max_hp].diffText.text = ""
    end

    local atkVal = CommanderUtils.GetAttrVal(equipData.attr_list,GDefine.Attr.atk)
    local compAtkVal = compEquipData and CommanderUtils.GetAttrVal(compEquipData.attr_list,GDefine.Attr.atk) or nil
    objs.attrs[GDefine.Attr.atk].valText.text = atkVal
    if compAtkVal then
        objs.attrs[GDefine.Attr.atk].downNode:SetActive(atkVal < compAtkVal)
        objs.attrs[GDefine.Attr.atk].upNode:SetActive(atkVal > compAtkVal)

        local diffVal = atkVal - compAtkVal
        if diffVal > 0 then
            objs.attrs[GDefine.Attr.atk].diffText.text = string.format("<color=#25cb6b>(+%s)</color>",diffVal)
        elseif diffVal < 0 then
            objs.attrs[GDefine.Attr.atk].diffText.text = string.format("<color=#cb5425>(%s)</color>",diffVal)
        else
            objs.attrs[GDefine.Attr.atk].diffText.text = ""
        end 

        if atkVal > compAtkVal then 
            upArrowNum = upArrowNum + 1
        else
            downArrowNum = downArrowNum + 1
        end
    elseif objs.attrs[GDefine.Attr.atk].downNode then
        objs.attrs[GDefine.Attr.atk].downNode:SetActive(false)
        objs.attrs[GDefine.Attr.atk].upNode:SetActive(false)
        objs.attrs[GDefine.Attr.atk].diffText.text = ""
    end
    
    local atkSpeedVal = CommanderUtils.GetAttrVal(equipData.attr_list,GDefine.Attr.atk_speed)
    local compAtkSpeedVal = compEquipData and CommanderUtils.GetAttrVal(compEquipData.attr_list,GDefine.Attr.atk_speed) or nil
    objs.attrs[GDefine.Attr.atk_speed].valText.text = atkSpeedVal
    if compAtkSpeedVal then
        objs.attrs[GDefine.Attr.atk_speed].downNode:SetActive(atkSpeedVal < compAtkSpeedVal)
        objs.attrs[GDefine.Attr.atk_speed].upNode:SetActive(atkSpeedVal > compAtkSpeedVal)

        local diffVal = atkSpeedVal - compAtkSpeedVal
        if diffVal > 0 then
            objs.attrs[GDefine.Attr.atk_speed].diffText.text = string.format("<color=#25cb6b>(+%s)</color>",diffVal)
        elseif diffVal < 0 then
            objs.attrs[GDefine.Attr.atk_speed].diffText.text = string.format("<color=#cb5425>(%s)</color>",diffVal)
        else
            objs.attrs[GDefine.Attr.atk_speed].diffText.text = ""
        end 

        if atkSpeedVal > compAtkSpeedVal then 
            upArrowNum = upArrowNum + 1
        else
            downArrowNum = downArrowNum + 1
        end
    elseif objs.attrs[GDefine.Attr.atk_speed].downNode then
        objs.attrs[GDefine.Attr.atk_speed].downNode:SetActive(false)
        objs.attrs[GDefine.Attr.atk_speed].upNode:SetActive(false)
        objs.attrs[GDefine.Attr.atk_speed].diffText.text = ""
    end

    local atkDistanceVal = CommanderUtils.GetAttrVal(equipData.attr_list,GDefine.Attr.atk_distance)
    local compAtkDistanceVal = compEquipData and CommanderUtils.GetAttrVal(compEquipData.attr_list,GDefine.Attr.atk_distance) or nil
    objs.attrs[GDefine.Attr.atk_distance].valText.text = atkDistanceVal
    if compAtkDistanceVal then
        objs.attrs[GDefine.Attr.atk_distance].downNode:SetActive(atkDistanceVal < compAtkDistanceVal)
        objs.attrs[GDefine.Attr.atk_distance].upNode:SetActive(atkDistanceVal > compAtkDistanceVal)

        local diffVal = atkDistanceVal - compAtkDistanceVal
        if diffVal > 0 then
            objs.attrs[GDefine.Attr.atk_distance].diffText.text = string.format("<color=#25cb6b>(+%s)</color>",diffVal)
        elseif diffVal < 0 then
            objs.attrs[GDefine.Attr.atk_distance].diffText.text = string.format("<color=#cb5425>(%s)</color>",diffVal)
        else
            objs.attrs[GDefine.Attr.atk_distance].diffText.text = ""
        end

        if atkDistanceVal > compAtkDistanceVal then
            upArrowNum = upArrowNum + 1
        else
            downArrowNum = downArrowNum + 1
        end
    elseif objs.attrs[GDefine.Attr.atk_distance].downNode then
        objs.attrs[GDefine.Attr.atk_distance].downNode:SetActive(false)
        objs.attrs[GDefine.Attr.atk_distance].upNode:SetActive(false)
        objs.attrs[GDefine.Attr.atk_distance].diffText.text = ""
    end


    local battlePowerVal = CommanderUtils.GetAttrVal(equipData.attr_list,GDefine.Attr.battle_power)
    local compBattlePowerVal = compEquipData and CommanderUtils.GetAttrVal(compEquipData.attr_list,GDefine.Attr.battle_power) or nil
    if compBattlePowerVal then
        local diffVal = battlePowerVal - compBattlePowerVal
        if diffVal > 0 then
            objs.battlePowerDown:SetActive(false)
            objs.battlePowerUp:SetActive(true)
            objs.battlePower.text = string.format("<color=#25cb6b>(战力 +%s)</color>",diffVal)
        elseif diffVal < 0 then
            objs.battlePowerDown:SetActive(true)
            objs.battlePowerUp:SetActive(false)
            objs.battlePower.text = string.format("<color=#cb5425>(战力 %s)</color>",diffVal)
        else
            objs.battlePowerDown:SetActive(false)
            objs.battlePowerUp:SetActive(false)
            objs.battlePower.text = ""
        end
    elseif objs.battlePowerDown then
        objs.battlePowerDown:SetActive(false)
        objs.battlePowerUp:SetActive(true)
        objs.battlePower.text = string.format("<color=#25cb6b>(战力 +%s)</color>",battlePowerVal)
    end


    local entryAttrs = CommanderUtils.GetEntryAttrs(equipData.attr_list)
    for i,v in ipairs(entryAttrs) do
        local conf = Config.AttrData.data_attr_info[v.attr_id]

        local entryAttrItem = objs.entryAttrItems[i]
        if not entryAttrItem then
            entryAttrItem =  GameObject.Instantiate(self.entryAttrItem)
            table.insert(objs.entryAttrItems,entryAttrItem)
        end
        entryAttrItem:SetActive(true)

        entryAttrItem.transform:SetParent(objs.entryItemParent)
        entryAttrItem.transform:SetLocalScale(1,1,1)

        local showAttrVal = string.format("%.1f",v.attr_val * 0.0001 * 100) .. "%"
        local desc = string.format("%s：<color=#%s>%s</color>%s",conf.name,conf.color,showAttrVal,conf.desc)
        entryAttrItem.transform:Find("desc").gameObject:GetComponent(Text).text =  desc

        --isNewGet
        if isNewGet then
            local setting = {}
            setting.confId = 9300018
            setting.parent = entryAttrItem.transform
            setting.order = ViewManager.Instance:GetMaxOrderLayer()
    
            local effect = UIEffect.New()
            effect:Init(setting)
            effect:Play()
            table.insert(self.entryEffects,effect)
        end
    end
    for i = #entryAttrs + 1, #objs.entryAttrItems do
        objs.entryAttrItems[i].gameObject:SetActive(false)
    end


    return upArrowNum,downArrowNum
end

function NewEquipWindow:SellClick()
    if not mod.TreasureChestProxy:ExistTempEquip() then
        self:CloseClick()
    elseif self.sellTips then
        local data = {}
        data.content = "即将出售的装备品质或属性可能比当前装备好是否出售？"
        data.notShowKey = "sell_equip"
        data.onConfirm = self:ToFunc("ConfirmSell")
        SystemDialog.Show(data)
    else
        self:ConfirmSell()
    end
end

function NewEquipWindow:ConfirmSell()
    mod.CommanderFacade:SendMsg(11009,1)
end

function NewEquipWindow:ReplaceClick()
    if not mod.TreasureChestProxy:ExistTempEquip() then
        self:CloseClick()
    else
        mod.CommanderFacade:SendMsg(11009,2)
    end
end

function NewEquipWindow:CloseClick()
    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_close, "new_equip")
    ViewManager.Instance:CloseWindow(NewEquipWindow)
    
    if mod.TreasureChestProxy.autoOpenFlag and mod.TreasureChestProxy:ExistTempEquip() then
        mod.CommanderFacade:SendMsg(11009,1)
    end
end