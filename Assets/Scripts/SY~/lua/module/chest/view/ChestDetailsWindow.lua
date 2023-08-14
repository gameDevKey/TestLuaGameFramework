ChestDetailsWindow = BaseClass("ChestDetailsWindow",BaseWindow)
-- ChestDetailsWindow.__showMainui = true
-- ChestDetailsWindow.__topInfo = false
-- ChestDetailsWindow.__bottomTab = false
function ChestDetailsWindow:__Init()
    self:SetAsset("ui/prefab/chest/chest_details_window.prefab",AssetType.Prefab)

    self.notTempHide = true
    self.rewards = {}
    self.timer = nil
    self.consumeNum = 0
end

function ChestDetailsWindow:__CacheObject()
    self.mainBg = self:Find("main/bg")
    self.pattern = self:Find("main/bg/pattern").gameObject
    self.stand = self:Find("main/bg/base_info/stand",Image)
    self.stageText = self:Find("main/bg/base_info/stage",Text)
    self.chestName = self:Find("main/bg/base_info/name",Text)
    self.rewardParent = self:Find("main/bg/reward_info")
    self.rewardItem = self:Find("main/bg/reward_info/reward_item").gameObject

    self.propItemTemp = self:Find("templete/prop_item").gameObject

    -- 暂不需要打开宝箱操作
    -- self.operateBg = self:Find("main/bg/operate_area/unlocking_bg/bg").gameObject
    -- self.otherUnlocking = self:Find("main/bg/operate_area/other_unlocking").gameObject

    -- self.unlocking = self:Find("main/bg/operate_area/unlocking_bg").gameObject
    -- self.unlockingText = self:Find("main/bg/operate_area/unlocking_bg/countdown_text",Text)

    -- self.leftBtn = self:Find("main/bg/operate_area/left_btn",Button)
    -- self.rightBtn = self:Find("main/bg/operate_area/right_btn",Button)  
    -- self.consumeObj = self:Find("main/bg/operate_area/right_btn/consume")
    -- self.consumeText = self:Find("main/bg/operate_area/right_btn/consume/num",Text)
    -- self.countdownPreview = self:Find("main/bg/operate_area/left_btn/countdown_preview/num",Text)
end

function ChestDetailsWindow:__Create()
    -- self:Find("main/bg/left_btn/text",Text).text = TI18N("开始解锁")
    -- self:Find("main/bg/right_btn/text",Text).text = TI18N("立即打开")
    -- self:Find("main/bg/operate_area/unlocking_bg/countdown_title",Text).text = TI18N("解锁倒计时:")
    -- self:Find("main/bg/operate_area/other_unlocking/other_unlocking_text",Text).text = TI18N("所有钥匙都在解锁宝箱中！")

    self:InitRewardItems()
end

function ChestDetailsWindow:__BindEvent()
end

function ChestDetailsWindow:__BindListener()
    self:Find("panel_bg",Button):SetClick( self:ToFunc("OnCloseClick") )
end

function ChestDetailsWindow:__Show()
    self.rootCanvas.sortingOrder = ViewManager.Instance:GetCurOrderLayer() + 10
    -- self.state = self.args.state -- 宝箱开启倒计时状态
    -- self.chestData = self.args.data -- 宝箱开启时间等数据
    self.itemCfg = self.args.cfg.itemCfg
    self.chestCfg = self.args.cfg.chestCfg
    self:SetBaseInfo()
    self:SetRewardPreview()
    -- self:SetOperateArea()
end

function ChestDetailsWindow:InitRewardItems()
    local column_num = 2
    for i = 1, 6 do
        local reward = GameObject.Instantiate(self.rewardItem)
        reward.transform:SetParent(self.rewardParent)
        reward.transform:Reset()
        local x = math.fmod(i,2) == 0 and 132 or -109
        local y = math.floor((i-1) /column_num) * (-62-16)    -- 62:rewardItem的height  16:rewardItem行间距
        UnityUtils.SetAnchoredPosition(reward.transform, x, y)
        reward:SetActive(false)
        local item = {}
        item.reward = reward
        -- item.icon = reward.transform:Find("icon"):GetComponent(Image)
        item.title = reward.transform:Find("title"):GetComponent(Text)
        item.value = reward.transform:Find("range"):GetComponent(Text)

        local propItem = PropItem.Create(self.propItemTemp)
        propItem:SetParent(reward.transform:Find("prop_item_parent"),0,0)
        propItem.transform:Reset()
        propItem:SetSize(74.25, 66)
        propItem:EnableTips(false)
        UnityUtils.SetAnchorMinAndMax(propItem.transform,0.5,0.5,0.5,0.5)
        UnityUtils.SetPivot(propItem.transform,0.5,0.5)
        UnityUtils.SetAnchoredPosition(propItem.transform, 0, -2.3)
        propItem:Show()
        item.propItem = propItem

        table.insert(self.rewards, item)
    end
    self.rewardItem:SetActive(false)
end

function ChestDetailsWindow:SetBaseInfo()
    self:SetSprite(self.stand,AssetPath.GetChestDetailsStand(self.itemCfg.icon),true)
    -- local division = mod.RoleProxy:GetRoleData().division
    -- local state = Config.DivisionData.data_division_info[division].remark
    -- self.stageText.text = TI18N(state.."竞技场")
    self.chestName.text = TI18N(UIUtils.GetTextColorByQuality(self.itemCfg.name, self.itemCfg.quality, false))
end

function ChestDetailsWindow:SetRewardPreview()
    local i = 1
    for k, v in pairs(self.chestCfg.reward_preview) do
        local previewItemId = v[1]
        local previewItemCfg = Config.ItemData.data_item_info[previewItemId]
        -- local itemIcon = AssetPath.GetItemIcon(previewItemId)
        -- self:SetSprite(self.rewards[i].icon,itemIcon,true)
        local itemData = {}
        itemData.item_id = previewItemId
        itemData.count = 0
        self.rewards[i].propItem:SetData(itemData)
        --[[
        if previewItemCfg.type == GDefine.ItemType.unitCard then
            UnityUtils.SetLocalScale(self.rewards[i].icon.transform,0.5,0.5,0.5)
        else
            UnityUtils.SetLocalScale(self.rewards[i].icon.transform,0.75,0.75,0.75)
        end
        --]]
        self.rewards[i].title.text = TI18N(UIUtils.GetTextColorByQuality(previewItemCfg.name, previewItemCfg.quality, false))
        self.rewards[i].value.text = v[2]--TI18N(UIUtils.GetTextColorByQuality(v[2], previewItemCfg.quality, false))
        self.rewards[i].reward:SetActive(true)
        i = i + 1
    end
    local row = math.ceil(#self.chestCfg.reward_preview / 2)
    self.pattern:SetActive(row>=3)
    local height = (176.5+160.5) + row * (62 + 16) -- 176.5+160.5 [176.5:rewardItemParent距上边距，160.5:下边距] 62+16[62:一个rewardItem的高度，16:rewardItem行间距]
    UnityUtils.SetSizeDelata(self.mainBg,555,height)  -- 555:背景底图原始width
end

function ChestDetailsWindow:SetOperateArea()
    if self.state == GDefine.ChestStateType.notUnlocked then
        self.operateBg:SetActive(true)
        self.otherUnlocking:SetActive(false)
        self.unlocking:SetActive(false)
        self.leftBtn.gameObject:SetActive(true)
        self.leftBtn:SetClick( self:ToFunc("UnlockChest") )
        self.rightBtn:SetClick( self:ToFunc("UnlockChestImmediately"))
        UnityUtils.SetLocalPosition(self.leftBtn.transform,-120,-100)
        UnityUtils.SetLocalPosition(self.rightBtn.transform,120,-100)
        UnityUtils.SetLocalPosition(self.stand.transform,0,284)
        self.countdownPreview.text = TimeUtils.GetTimeFormatDayII(self.chestCfg.count_down_time)
        local countdownChange = mod.ChestProxy.countdownChange
        self.consumeNum = math.ceil(self.chestCfg.count_down_time/countdownChange[1]) * countdownChange[2]
        self.consumeText.text = tostring(self.consumeNum)
    elseif self.state == GDefine.ChestStateType.unlocking then
        self.operateBg:SetActive(true)
        self.otherUnlocking:SetActive(false)
        self.unlocking:SetActive(true)
        self.leftBtn.gameObject:SetActive(false)
        self.leftBtn:SetClick( nil )
        self.rightBtn:SetClick( self:ToFunc("UnlockChestImmediately") )
        UnityUtils.SetLocalPosition(self.unlocking.transform,-190,-112,0)
        UnityUtils.SetLocalPosition(self.rightBtn.transform,130,-100)
        UnityUtils.SetLocalPosition(self.stand.transform,0,284)
        self:AddCountdownTimer()
    elseif self.state == GDefine.ChestStateType.otherUnlocking then
        self.operateBg:SetActive(true)
        self.otherUnlocking:SetActive(true)
        self.unlocking:SetActive(false)
        self.leftBtn.gameObject:SetActive(false)
        self.leftBtn:SetClick( nil )
        self.rightBtn:SetClick( self:ToFunc("UnlockChestImmediately") )
        local countdownChange = mod.ChestProxy.countdownChange
        self.consumeNum = math.ceil(self.chestCfg.count_down_time/countdownChange[1]) * countdownChange[2]
        self.consumeText.text = tostring(self.consumeNum)
        UnityUtils.SetLocalPosition(self.otherUnlocking.transform,-10,-97)
        UnityUtils.SetLocalPosition(self.rightBtn.transform,130,-100)
        UnityUtils.SetLocalPosition(self.stand.transform,0,284)
    end
    UnityUtils.SetSizeDelata(self.consumeText.transform,self.consumeText.preferredWidth,self.preferredHeight)
    local width = self.consumeText.transform.sizeDelta.x - self.consumeText.transform.anchoredPosition.x
    local height = self.consumeObj.sizeDelta.y
    UnityUtils.SetSizeDelata(self.consumeObj,width,height)
end

function ChestDetailsWindow:UnlockChest()
    mod.ChestFacade:SendMsg(10502,self.chestData.grid_id)
    self:OnCloseClick()
end

function ChestDetailsWindow:UnlockChestImmediately()
    if mod.RoleItemProxy:GetItemNum(GDefine.ItemId.Diamond) >= self.consumeNum then
        mod.ChestFacade:SendMsg(10504,self.chestData.grid_id,self.consumeNum)
        self:OnCloseClick()
    else
        SystemMessage.Show(TI18N("当前钻石不足以直接解锁宝箱"))
    end
end

function ChestDetailsWindow:AddCountdownTimer()
    local remoteTime = math.floor(Network.Instance:GetRemoteTimeByMS())
    local openTime = self.chestData.open_time
    local lessTime = openTime - remoteTime
    self:Countdowning(lessTime)
    self.timer = TimerManager.Instance:AddTimer(0,1, function()
        lessTime = lessTime - 1
        self:Countdowning(lessTime)
    end)
end

function ChestDetailsWindow:Countdowning(lessTime)
    local countdownChange = mod.ChestProxy.countdownChange
    local timeStr = TimeUtils.GetTimeFormatDayIII(lessTime)
    self.unlockingText.text = timeStr
    self.consumeNum = math.ceil(lessTime/countdownChange[1]) * countdownChange[2]
    self.consumeText.text = tostring(self.consumeNum)
    UnityUtils.SetSizeDelata(self.consumeText.transform,self.consumeText.preferredWidth,self.consumeText.preferredHeight)
    local width = self.consumeText.transform.sizeDelta.x - self.consumeText.transform.anchoredPosition.x
    local height = self.consumeObj.sizeDelta.y
    UnityUtils.SetSizeDelata(self.consumeObj,width,height)
    if lessTime <= 0 then
        local data = mod.ChestProxy.chestDataList
        mod.ChestFacade:SendEvent(ChestPanel.Event.RefreshChestPanel,data)
        self:OnCloseClick()
    end
end

function ChestDetailsWindow:RemoveTimer()
    if self.timer then
        TimerManager.Instance:RemoveTimer(self.timer)
        self.timer = nil
    end
end

function ChestDetailsWindow:OnCloseClick()
    for i, v in ipairs(self.rewards) do
        GameObject.Destroy(v.reward)
        v.propItem:Destroy()
    end

    self:RemoveTimer()
    ViewManager.Instance:CloseWindow(ChestDetailsWindow)
end