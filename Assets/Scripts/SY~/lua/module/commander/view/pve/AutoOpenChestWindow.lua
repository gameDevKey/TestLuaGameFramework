AutoOpenChestWindow = BaseClass("AutoOpenChestWindow", BaseWindow)
AutoOpenChestWindow.__topInfo = true
AutoOpenChestWindow.__bottomTab = true
AutoOpenChestWindow.notTempHide = true

AutoOpenChestWindow.Event = EventEnum.New(
    "RefreshAutoOpenChest"
)

function AutoOpenChestWindow:__Init()
    self:SetAsset("ui/prefab/commander/auto_open_chest_window.prefab", AssetType.Prefab)

    self.curQuality = nil
    self.curEntryAttrId1 = nil
    self.curEntryAttrId2 = nil

    self.existEntryAttr = false

    self.qualityItems = {}
    self.entryItems1 = {}
    self.entryItems2 = {}
end

function AutoOpenChestWindow:__Delete()
end

function AutoOpenChestWindow:__ExtendView()
end

function AutoOpenChestWindow:__CacheObject()
    self.qualityItem = self:Find("main/quality_dropdown/select_panel/Viewport/Content/Item").gameObject
    self.qualityArrow = self:Find("main/quality_dropdown/arrow")
    self.qualitySelectNode = self:Find("main/quality_dropdown/select_panel").gameObject
    self.qualitySelectRectTrans = self:Find("main/quality_dropdown/select_panel",RectTransform)
    self.qualitySelectParent = self:Find("main/quality_dropdown/select_panel/Viewport/Content")
    self.qualitySelectText = self:Find("main/quality_dropdown/select",Text)
    
    self.entryItem1 = self:Find("main/entry_dropdown_1/select_panel/Viewport/Content/Item").gameObject
    self.entryItemArrow1 = self:Find("main/entry_dropdown_1/arrow")
    self.entryItemSelectNode1 = self:Find("main/entry_dropdown_1/select_panel").gameObject
    self.entryItemSelectRectTrans1 = self:Find("main/entry_dropdown_1/select_panel",RectTransform)
    self.entryItemSelectParent1 = self:Find("main/entry_dropdown_1/select_panel/Viewport/Content")
    self.entryItemSelectText1 = self:Find("main/entry_dropdown_1/select",Text)

    self.entryItem2 = self:Find("main/entry_dropdown_2/select_panel/Viewport/Content/Item").gameObject
    self.entryItemArrow2 = self:Find("main/entry_dropdown_2/arrow")
    self.entryItemSelectNode2 = self:Find("main/entry_dropdown_2/select_panel").gameObject
    self.entryItemSelectRectTrans2 = self:Find("main/entry_dropdown_2/select_panel",RectTransform)
    self.entryItemSelectParent2 = self:Find("main/entry_dropdown_2/select_panel/Viewport/Content")
    self.entryItemSelectText2 = self:Find("main/entry_dropdown_2/select",Text)
end

function AutoOpenChestWindow:__BindListener()
    self:Find("main/quality_dropdown",Button):SetClick(self:ToFunc("SelectQualityPanelClick"))
    self:Find("main/quality_dropdown/select_panel/close",Button):SetClick(self:ToFunc("SelectQualityPanelCloseClick"))

    self:Find("main/entry_dropdown_1",Button):SetClick(self:ToFunc("SelectEntryPanelClick1"))
    self:Find("main/entry_dropdown_1/select_panel/close",Button):SetClick(self:ToFunc("SelectEntryPanelCloseClick1"))

    self:Find("main/entry_dropdown_2",Button):SetClick(self:ToFunc("SelectEntryPanelClick2"))
    self:Find("main/entry_dropdown_2/select_panel/close",Button):SetClick(self:ToFunc("SelectEntryPanelCloseClick2"))

    self:Find("main/begin_btn",Button):SetClick(self:ToFunc("BeginClick"))

    self:Find("bg",Button):SetClick(self:ToFunc("CloseClick"))
end

function AutoOpenChestWindow:__BindEvent()
    self:BindEvent(AutoOpenChestWindow.Event.RefreshAutoOpenChest)
end

function AutoOpenChestWindow:__Create()

end

function AutoOpenChestWindow:__Show()
    self.curQuality = mod.TreasureChestProxy:GetAutoOpenQuality()

    local autoOpenEntry = mod.TreasureChestProxy:GetAutoOpenEntry()
    self.curEntryAttrId1 = autoOpenEntry[1] or 0
    self.curEntryAttrId2 = autoOpenEntry[2] or 0

    local entryAttrs = mod.TreasureChestProxy:GetAllEntryAttrs()
    self.existEntryAttr = #entryAttrs > 0

    self:CreateQualitySelect()
    self:CreateEntrySelect1()
    self:CreateEntrySelect2()
    self:RefreshAutoOpenChest()
end

function AutoOpenChestWindow:CreateQualitySelect()
    for i,quality in ipairs(GDefine.QualityLowToHigh) do
        local item = GameObject.Instantiate(self.qualityItem)
        item:SetActive(true)

        local qualityName,qualityColor = CommanderUtils.GetEquipQualityInfo(quality)
        item.transform:Find("text").gameObject:GetComponent(Text).text = string.format("<color=#%s>%s及以上</color>",qualityColor,qualityName)
        item.gameObject:GetComponent(Button):SetClick(self:ToFunc("SelectQualityItemClick"),quality)

        item.transform:SetParent(self.qualitySelectParent)
        item.transform:SetLocalScale(1,1,1)

        self.qualityItems[quality] = {selectNode = item.transform:Find("select").gameObject}
    end

    self.qualitySelectNode:SetActive(true)
    UIUtils.ForceRebuildLayoutImmediate(self.qualitySelectParent.gameObject)
    self.qualitySelectRectTrans:SetSizeDelata(308,10 + self.qualitySelectParent.sizeDelta.y)
    self.qualitySelectNode:SetActive(false)
end

function AutoOpenChestWindow:CreateEntrySelect1()
    local item = GameObject.Instantiate(self.entryItem1)
    item:SetActive(true)

    item.transform:Find("text").gameObject:GetComponent(Text).text = "无"
    item.gameObject:GetComponent(Button):SetClick(self:ToFunc("SelectEntryItemClick1"),0)

    item.transform:SetParent(self.entryItemSelectParent1)
    item.transform:SetLocalScale(1,1,1)

    self.entryItems1[0] = {selectNode = item.transform:Find("select").gameObject}

    local entryAttrs = mod.TreasureChestProxy:GetAllEntryAttrs()
    for i,attrId in ipairs(entryAttrs) do
        local conf = Config.AttrData.data_attr_info[attrId]
        local item = GameObject.Instantiate(self.entryItem1)
        item:SetActive(true)

        item.transform:Find("text").gameObject:GetComponent(Text).text = conf.name
        item.gameObject:GetComponent(Button):SetClick(self:ToFunc("SelectEntryItemClick1"),attrId)

        item.transform:SetParent(self.entryItemSelectParent1)
        item.transform:SetLocalScale(1,1,1)

        self.entryItems1[attrId] = {selectNode = item.transform:Find("select").gameObject}
    end

    self.entryItemSelectNode1:SetActive(true)
    UIUtils.ForceRebuildLayoutImmediate(self.entryItemSelectParent1.gameObject)
    self.entryItemSelectRectTrans1:SetSizeDelata(308,10 + self.entryItemSelectParent1.sizeDelta.y)
    self.entryItemSelectNode1:SetActive(false)
end


function AutoOpenChestWindow:CreateEntrySelect2()
    local item = GameObject.Instantiate(self.entryItem2)
    item:SetActive(true)

    item.transform:Find("text").gameObject:GetComponent(Text).text = "无"
    item.gameObject:GetComponent(Button):SetClick(self:ToFunc("SelectEntryItemClick2"),0)

    item.transform:SetParent(self.entryItemSelectParent2)
    item.transform:SetLocalScale(1,1,1)

    self.entryItems2[0] = {selectNode = item.transform:Find("select").gameObject}

    local entryAttrs = mod.TreasureChestProxy:GetAllEntryAttrs()
    for i,attrId in ipairs(entryAttrs) do
        local conf = Config.AttrData.data_attr_info[attrId]
        local item = GameObject.Instantiate(self.entryItem2)
        item:SetActive(true)

        item.transform:Find("text").gameObject:GetComponent(Text).text = conf.name
        item.gameObject:GetComponent(Button):SetClick(self:ToFunc("SelectEntryItemClick2"),attrId)

        item.transform:SetParent(self.entryItemSelectParent2)
        item.transform:SetLocalScale(1,1,1)

        self.entryItems2[attrId] = {selectNode = item.transform:Find("select").gameObject}
    end

    self.entryItemSelectNode2:SetActive(true)
    UIUtils.ForceRebuildLayoutImmediate(self.entryItemSelectParent2.gameObject)
    self.entryItemSelectRectTrans2:SetSizeDelata(308,10 + self.entryItemSelectParent2.sizeDelta.y)
    self.entryItemSelectNode2:SetActive(false)
end

function AutoOpenChestWindow:RefreshAutoOpenChest()
    for k,v in pairs(self.qualityItems) do
        v.selectNode:SetActive(k == self.curQuality)
    end
    local qualityName,qualityColor = CommanderUtils.GetEquipQualityInfo(self.curQuality)
    self.qualitySelectText.text = string.format("<color=#%s>%s及以上</color>",qualityColor,qualityName)


    local attrConf = Config.AttrData.data_attr_info[self.curEntryAttrId1]
    self.entryItemSelectText1.text = attrConf and attrConf.name or "无"

    local attrConf = Config.AttrData.data_attr_info[self.curEntryAttrId2]
    self.entryItemSelectText2.text = attrConf and attrConf.name or "无"
end

--
function AutoOpenChestWindow:SelectQualityPanelClick()
    self.qualitySelectNode:SetActive(true)
    self.qualityArrow:SetLocalScale(1,-1,1)
end
function AutoOpenChestWindow:SelectQualityItemClick(quality)
    --发送协议
    self.curQuality = quality
    self.qualitySelectNode:SetActive(false)
    self.qualityArrow:SetLocalScale(1,1,1)
    self:SendSetting()
end
function AutoOpenChestWindow:SelectQualityPanelCloseClick()
    self.qualitySelectNode:SetActive(false)
    self.qualityArrow:SetLocalScale(1,1,1)
end

--
function AutoOpenChestWindow:SelectEntryPanelClick1()
    if not self.existEntryAttr then
        SystemMessage.Show("不存在词条属性")
        return
    end
    self.entryItemSelectNode1:SetActive(true)
    self.entryItemArrow1:SetLocalScale(1,-1,1)
end
function AutoOpenChestWindow:SelectEntryItemClick1(attrId)
    self.curEntryAttrId1 = attrId
    self.entryItemSelectNode1:SetActive(false)
    self.entryItemArrow1:SetLocalScale(1,1,1)
    self:SendSetting()
end
function AutoOpenChestWindow:SelectEntryPanelCloseClick1()
    self.entryItemSelectNode1:SetActive(false)
    self.entryItemArrow1:SetLocalScale(1,1,1)
end

--
function AutoOpenChestWindow:SelectEntryPanelClick2()
    if not self.existEntryAttr then
        SystemMessage.Show("不存在词条属性")
        return
    end
    self.entryItemSelectNode2:SetActive(true)
    self.entryItemArrow2:SetLocalScale(1,-1,1)
end
function AutoOpenChestWindow:SelectEntryItemClick2(attrId)
    self.curEntryAttrId2 = attrId
    self.entryItemSelectNode2:SetActive(false)
    self.entryItemArrow2:SetLocalScale(1,1,1)
    self:SendSetting()
end
function AutoOpenChestWindow:SelectEntryPanelCloseClick2()
    self.entryItemSelectNode2:SetActive(false)
    self.entryItemArrow2:SetLocalScale(1,1,1)
end


function AutoOpenChestWindow:SendSetting()
    local data = {}
    table.insert(data,{key = 1,val = self.curQuality})
    table.insert(data,{key = 2,val = self.curEntryAttrId1})
    table.insert(data,{key = 2,val = self.curEntryAttrId2})
    mod.CommanderFacade:SendMsg(11008,data)
end

function AutoOpenChestWindow:BeginClick()
    if mod.TreasureChestProxy:GetChestNum() <= 0 then
        SystemMessage.Show("没有宝箱")
    else
        local tempBag = mod.RoleItemProxy:GetRoleItemType(GDefine.BagType.temp)
        if tempBag and tempBag[1] then
            SystemMessage.Show("已存在开启装备")
        else
            Log("开始自动打开")
            mod.TreasureChestProxy.autoOpenFlag = true
            mod.CommanderFacade:SendMsg(11006)
        end
    end

    self:CloseClick()
end

function AutoOpenChestWindow:CloseClick()
    ViewManager.Instance:CloseWindow(AutoOpenChestWindow)
end

