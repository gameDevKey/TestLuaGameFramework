UnitLevelUpPanel = BaseClass("UnitLevelUpPanel", BaseView)

function UnitLevelUpPanel:__Init()
    self:SetAsset("ui/prefab/backpack/unit_level_up_panel.prefab",AssetType.Prefab)

    self.attrList = {}
    self.attrToImg = {
        [GDefine.Attr.atk] = UITex("backpack/backpack_2003"),
        [GDefine.Attr.max_hp] = UITex("backpack/backpack_2005"),
    }
end

function UnitLevelUpPanel:__Delete()
    if self.richTextTipsPanel then
        self.richTextTipsPanel:Destroy()
    end
end

function UnitLevelUpPanel:__CacheObject()
    self.stand = self:Find("main/unit_con/stand_parent/stand",Image)

    self.slider = self:Find("main/slider")
    self.mask = self:Find("main/slider/mask")
    self.fill = self:Find("main/slider/mask/fill",Image)
    self.arrow = self:Find("main/slider/arrow",Image)
    self.quantity = self:Find("main/slider/quantity",Text)

    self.levelNode = self:Find("main/lev_bg/lev")
    self.levelNum = self:Find("main/lev_bg/lev/lev_num",Text)

    for i = 1, 3 do
        self:GetAttrItem(i)
    end

    self.desc ={
        obj = self:Find("main/desc_bg").gameObject,
        [1] = {
            node = self:Find("main/desc_bg/unlock_soon").gameObject,
            text = self:Find("main/desc_bg/unlock_soon/desc",Text),
            richTextParent = self:Find("main/desc_bg/unlock_soon/rich_text"),
        },
        [2] = {
            node = self:Find("main/desc_bg/unlock_now").gameObject,
            text = self:Find("main/desc_bg/unlock_now/desc",Text),
            richTextParent = self:Find("main/desc_bg/unlock_now/rich_text"),
        }
    }

    self.standParentCanvas = self:Find("main/unit_con/stand_parent",Canvas)
end

function UnitLevelUpPanel:GetAttrItem(index)
    local item = {}
    item.gameObject = self:Find("main/attr_con/item_"..index).gameObject
    item.icon = self:Find("main/attr_con/item_"..index.."/icon",Image)
    item.value = self:Find("main/attr_con/item_"..index.."/value",Text)
    item.addValue = self:Find("main/attr_con/item_"..index.."/add_value",Text)

    table.insert(self.attrList, item)
end

function UnitLevelUpPanel:__Create()
    self.name = self.transform.name
    self:SetOrder()
    self:Find("main/desc_bg/unlock_soon/title",Text).text = TI18N("即将解锁：")
    self:Find("main/btn/text",Text).text = TI18N("确认")

    if not self.richTextTipsPanel then
        self.richTextTipsPanel = RichTextTipsPanel.New()
        self.richTextTipsPanel:SetParent(self:Find("main"))
    end
    self.richTextTipsPanel:Show()
end

function UnitLevelUpPanel:__BindListener()
    self:Find("main/btn",Button):SetClick( self:ToFunc("OnCloseClick") )

    self:AddAnimEffectListener("unit_level_up_panel",self:ToFunc("OnAnimEffectPlay"))
end

function UnitLevelUpPanel:__Show()
    self.standParentCanvas.sortingOrder = self:GetOrder() + GDefine.EffectOrderAdd + 1
    self:SetInfo()
    self:SetQuantity()
    self:SetAttr()
    self:SetDesc()
end

function UnitLevelUpPanel:SetData(data)
    self.data = data

    self.unitCfg = Config.UnitData.data_unit_info[data.unit_id]
    local nextKey = data.unit_id.."_"..data.level+1
    self.nextCfg = Config.UnitData.data_unit_lev_info[nextKey]

    local lastKey = data.unit_id.."_"..data.level-1
    self.lastAttr = Config.UnitData.data_unit_lev_info[lastKey].attr_list
end

function UnitLevelUpPanel:SetInfo()
    self:SetSprite(self.stand,AssetPath.GetUnitStandLevUp(self.unitCfg.head) ,true)
    self.levelNum.text = self.data.level
    local width = self.levelNum.preferredWidth
    local height = self.levelNum.transform.sizeDelta.y
    UnityUtils.SetSizeDelata(self.levelNum.transform,width,height)
    width = width + self.levelNum.transform.anchoredPosition.x
    height = self.levelNode.sizeDelta.y
    UnityUtils.SetSizeDelata(self.levelNode.transform,width,height)
    self:SetSprite(self.arrow,AssetPath.QualityToArrow[self.unitCfg.quality])
    self:SetSprite(self.fill,AssetPath.QualityToSliderFill[self.unitCfg.quality])
end

function UnitLevelUpPanel:SetQuantity()
    local consume = 0
    local val = 0
    local quantityText = ""
    local isEnough = false
    if not self.nextCfg then
        val = 1
        quantityText = TI18N("已满级")
        self:SetActive(self.arrow.transform, false)
    else
        consume = self.nextCfg.lv_up_count
        val = consume > 0 and self.data.count/consume or self.data.count
        if val > 1 then
            val = 1
        end
        quantityText = self.data.count.."/"..consume
        isEnough = self.data.count >= consume
        self:SetActive(self.arrow.transform, isEnough)
    end
    local x = self.fill.transform.sizeDelta.x
    local y = self.mask.sizeDelta.y
    UnityUtils.SetSizeDelata(self.mask,val*x,y)
    self.quantity.text = quantityText
end

function UnitLevelUpPanel:SetAttr()
    local k = 1
    for i, v in ipairs(self.data.attr_list) do
        local iconPath = AssetPath.AttrIdToIcon[v.attr_id]
        local attrName = GDefine.AttrIdToName[v.attr_id]
        if iconPath and attrName then
            local lastVal = 0
            for i2, v2 in ipairs(self.lastAttr) do
                if v.attr_id == GDefine.AttrNameToId[v2[1]] then
                    lastVal = v2[2]
                end
            end
            local addVal = v.attr_val - lastVal
            if addVal > 0 then
                local item = self.attrList[k]
                self:SetSprite(item.icon,self.attrToImg[v.attr_id],true)
                item.value.text = lastVal
                item.addValue.text = "+"..addVal
                item.gameObject:SetActive(true)
                k = k+1
            end
        end
    end
    for i = k, #self.attrList do
        self.attrList[i].gameObject:SetActive(false)
    end
end

function UnitLevelUpPanel:SetDesc()
    local levUpDesc = self.unitCfg.lev_up_desc
    local descData = Config.UnitData.data_unit_up_desc
    local unlockNow = false
    local nextDesc = 0
    for i, v in ipairs(levUpDesc) do
        if self.data.level == v[1] then
            unlockNow = true
            nextDesc = v[2]
            break
        elseif self.data.level <v[1] then
            nextDesc = v[2]
            break
        end
    end
    if unlockNow then
        self.desc[2].text.text = TI18N(descData[nextDesc].desc)
        self:CreateRichText(descData[nextDesc].desc,self.desc[2].richTextParent)
        self.desc[1].node:SetActive(false)
        self.desc[2].node:SetActive(true)
        self.desc.obj:SetActive(true)
    elseif nextDesc ~= 0 then
        self.desc[1].text.text = TI18N(descData[nextDesc].desc)
        self:CreateRichText(descData[nextDesc].desc,self.desc[1].richTextParent)
        self.desc[1].node:SetActive(true)
        self.desc[2].node:SetActive(false)
        self.desc.obj:SetActive(true)
    else
        self.desc[1].node:SetActive(false)
        self.desc[2].node:SetActive(false)
        self.desc.obj:SetActive(false)
    end
end

function UnitLevelUpPanel:CreateRichText(content,parent)
    local richTextInfo = RichTextInfo.New()
    richTextInfo.content = TI18N(content)
    richTextInfo.lineSpacing = 1
    richTextInfo.viewWidth = 512
    richTextInfo.elementTemplate =
    {
        [RichTextDefine.Element.none_text] ={original = self:Find("rich_text_templete/normal_text")
            ,textComponent = self:Find("rich_text_templete/normal_text/text",Text)},
        [RichTextDefine.Element.rich_text] ={original = self:Find("rich_text_templete/normal_text")
            ,textComponent = self:Find("rich_text_templete/normal_text/text",Text)},
        [RichTextDefine.Element.click_text] ={ original = self:Find("rich_text_templete/click_text")
            ,textComponent = self:Find("rich_text_templete/click_text/text",Text)},
    }

    richTextInfo.parent = parent
    richTextInfo.onClick = self:ToFunc("ShowRichTextTips")
    richTextInfo.toColor = {["6381c7"] = "b2ff8d"}
    if self.richTextItem then
        self.richTextItem:Delete()
        self.richTextItem = nil
    end
    self.richTextItem = RichText.Create(richTextInfo)
end

function UnitLevelUpPanel:ShowRichTextTips(logicElementType,args,richTextTrans)
    self.richTextTipsPanel:ShowRichTextTips(logicElementType,args,richTextTrans)
end

function UnitLevelUpPanel:HideRichTextTips()
    self.richTextTipsPanel:HideRichTextTips()
end

function UnitLevelUpPanel:OnAnimEffectPlay(animName,data)
    self:LoadUIEffectByAnimData(data,true)
end

function UnitLevelUpPanel:OnCloseClick()
    self:Hide()
end