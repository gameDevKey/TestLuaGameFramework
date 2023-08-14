RewardPanel = BaseClass("RewardPanel",BaseView)

function RewardPanel:__Init()
    self:SetAsset("ui/prefab/reward/reward_panel.prefab",AssetType.Prefab)

    self.addAnim = nil
    -- self.reduceAnim = nil
    self.skipAnim = false
end

function RewardPanel:__CacheObject()
    self.title = self:Find("main/title",Text)
    self.itemImg = self:Find("main/item_img",Image)
    self.addValText = self:Find("main/item_img/add_value",Text)
    self.itemName = self:Find("main/item_name",Text)
    self.itemTypeText = self:Find("main/item_type",Text)

    self.assetCount = self:Find("main/count_info/asset_count").gameObject
    self.assetIcon = self:Find("main/count_info/asset_count/asset_icon",Image)
    self.assetPreValText = self:Find("main/count_info/asset_count/pre_value",Text)

    self.unitCount = self:Find("main/count_info/unit_count").gameObject
    self.unitSlider = self:Find("main/count_info/unit_count/unit_slider",Slider)
    self.unitSliderFill = self:Find("main/count_info/unit_count/unit_slider/fill_area/fill",Image)
    self.blueArrow = self:Find("main/count_info/unit_count/unit_slider/arrow_blue").gameObject
    self.greenArrow = self:Find("main/count_info/unit_count/unit_slider/arrow_green").gameObject
    self.unitPreValText = self:Find("main/count_info/unit_count/unit_slider/quantity_text",Text)
end

function RewardPanel:__Create()
    self.name = self.transform.name
    self:SetOrder()

    self.title.text = TI18N("获得道具")
    self:Find("main/count_info/title",Text).text = TI18N("您已拥有：")
    self:Find("main/close_tips",Text).text = TI18N("点击空白处关闭")
end

function RewardPanel:__BindListener()
    self:Find("panel_bg",Button):SetClick( self:ToFunc("OnCloseClick"))
end

function RewardPanel:__Show()
    self:SetRewardInfo(1)

    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_open, "award")
end

function RewardPanel:ReceiveReward(data)
    self.receiveList = data
    self.rewardCount = #self.receiveList
    self.curIndex = 1
    -- local rewardData = {}
    -- rewardData.itemId = data.itemId
    -- rewardData.addVal = data.addVal
    -- rewardData.itemCfg = data.itemCfg
    -- self.data = rewardData
    self:Show()
end

function RewardPanel:SetRewardInfo(index)
    self.title.text = TI18N("获得道具")
    local itemCfg = Config.ItemData.data_item_info[self.receiveList[index].item_id]
    local iconPath = AssetPath.GetUnitIconCollection(itemCfg.icon)
    self:SetSprite(self.itemImg,iconPath,false)

    self.addValText.text = string.format("+%s",self.receiveList[index].count)
    self.itemName.text = TI18N(itemCfg.name)
    self.rewardType = itemCfg.type
    self.itemTypeText.text = TI18N(GDefine.ItemTypeToDesc[self.rewardType])
    local animArg = {}
    if self.rewardType == GDefine.ItemType.currency then
        self.assetCount:SetActive(true)
        self.unitCount:SetActive(false)

        self:SetSprite(self.assetIcon,UITex("common/common_3"..itemCfg.id))
        local addVal = self.receiveList[index].count
        local preVal = 0
        local roleItemData = mod.RoleProxy:GetRoleItemData()
        if itemCfg.id == GDefine.Assets.coin then
            preVal = roleItemData[GDefine.AssetsToName[GDefine.Assets.coin]] - addVal
        elseif itemCfg.id == GDefine.Assets.diamond then
            preVal = roleItemData[GDefine.AssetsToName[GDefine.Assets.diamond]] - addVal
        end
        animArg = {addVal = addVal , preVal = preVal}
    elseif self.rewardType == GDefine.ItemType.unitCard then
        self.assetCount:SetActive(false)
        self.unitCount:SetActive(true)

        local unitData = mod.CollectionProxy:GetDataById(self.receiveList[index].item_id)
        local key = itemCfg.id.."_"..unitData.level+1
        local nextLevInfo = Config.UnitData.data_unit_lev_info[key]
        self.consume = 0
        local val = 0
        local quantityText = ""
        local isEnough = false
        local preVal = (unitData.count - self.receiveList[index].count)
        if not nextLevInfo then
            val = 1
            quantityText = TI18N("已满级")
            self:SetActive(self.blueArrow, false)
            self:SetActive(self.greenArrow, false)
        else
            self.consume = nextLevInfo.lv_up_count
            if preVal < 0 then
                preVal = 0
            end
            val = self.consume > 0 and preVal/self.consume or preVal
            quantityText = preVal.."/"..self.consume
            isEnough = preVal >= self.consume
            self:SetActive(self.blueArrow, not isEnough)
            self:SetActive(self.greenArrow, isEnough)
        end

        self.unitSlider.value = val
        self.unitPreValText.text = quantityText
        self:SetSprite(self.unitSliderFill,isEnough and UITex("common/common_35") or UITex("common/common_34"))
        animArg = {addVal = self.receiveList[index].count, preVal = preVal}
    end
    self:ShowChangeAnim(animArg)
end

function RewardPanel:ShowChangeAnim(arg)
    if self.addAnim then
        self.addAnim:Destroy()
        self.addAnim = nil
    end

    -- if self.reduceAnim then
    --     self.reduceAnim:Destroy()
    --     self.reduceAnim = nil
    -- end

    self.addAnim = ToIntValueAnim.New(arg.preVal,arg.preVal + arg.addVal,0.7,function (v)
        self:SetPreValText(v)
    end)

    -- self.reduceAnim = ToIntValueAnim.New(arg.addVal,0,0.7,function (v)
    --     self:SetAddValText(v)
    -- end)

    if self.skipAnim then
        self:SetPreValText(0)
        self:SetAddValText(0)
    else
        self.addAnim:Play()
        -- self.reduceAnim:Play()
    end
end

function RewardPanel:SetPreValText(v)
    if self.rewardType == GDefine.ItemType.currency then
        self.assetPreValText.text = v
    elseif self.rewardType == GDefine.ItemType.unitCard then
        self.unitPreValText.text = string.format("%s/%s",v,self.consume)
        local val = self.consume > 0 and v/self.consume or v
        self.unitSlider.value = val
        local isEnough = v >= self.consume
        self:SetActive(self.blueArrow, not isEnough)
        self:SetActive(self.greenArrow, isEnough)
        self:SetSprite(self.unitSliderFill,isEnough and UITex("common/common_35") or UITex("common/common_34"))
    end
end

function RewardPanel:SetAddValText(v)
    self.addValText.text = string.format("+%s",v)
    if v == 0 then
        self.addValText.text = ""
    end
end

function RewardPanel:OnCloseClick()
    if self.curIndex < self.rewardCount then
        self.curIndex = self.curIndex + 1
        self:SetRewardInfo(self.curIndex)
    else
        if self.addAnim then
            self.addAnim:Destroy()
            self.addAnim = nil
        end

        -- if self.reduceAnim then
        --     self.reduceAnim:Destroy()
        --     self.reduceAnim = nil
        -- end
        self.receiveList = {}
        self.skipAnim = false
        self:Hide()

        mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_close, "award")
    end
end
