WinExtraRewardPanel = BaseClass("WinExtraRewardPanel",ExtendView)

-- WinExtraRewardPanel.Event = EventEnum.New()

function WinExtraRewardPanel:__Init()
    self.maxCount = Config.ConstData.data_const_info["daily_fight_lose_offset"].val
    self.count = 0
    self.itemList = nil

    self.isRoomMode = nil

    self.baseRewardList = {}
    self.extraRewardList = {}
end

function WinExtraRewardPanel:__Delete()
    for i, v in ipairs(self.baseRewardList) do
        GameObject.Destroy(v.gameObject)
    end
    for i, v in ipairs(self.extraRewardList) do
        GameObject.Destroy(v.gameObject)
    end
end

function WinExtraRewardPanel:__BindEvent()
end

function WinExtraRewardPanel:__CacheObject()
    self.trans = self:Find("main/reward_panel/win")
    self.base = self:Find("base",nil,self.trans).gameObject
    self.baseBg = self:Find("base/bg",nil,self.trans)
    self.baseRewardCon = self:Find("base/reward_con",nil,self.trans)

    self.extra = self:Find("extra",nil,self.trans).gameObject
    self.extraRewardCon = self:Find("extra/reward_con",nil,self.trans)

    self.btn = self:Find("btn",Button,self.trans)
    self.countNum = self:Find("btn/count",Text,self.trans)
    self.rejectBtn = self:Find("reject_btn",Button,self.trans)

    -- self.cardGroup = self:Find("main/player_msg_2/card_group")
    self.rewardTemp = self:Find("main/template/reward_item").gameObject

    self.winManCanvas = self:Find("bg/win_title/bg_win_man",Canvas)
    self.winTitleCanvas = self:Find("bg/win_title/Image",Canvas)
end

function WinExtraRewardPanel:__Create()
    self:Find("base/title",Text,self.trans).text = TI18N("基础奖励")
    self:Find("extra/title",Text,self.trans).text = TI18N("额外赠礼")
    self:Find("text",Text,self.btn.transform).text = TI18N("接收赠礼")
    self:Find("text",Text,self.rejectBtn.transform).text = TI18N("残忍拒绝")

    self.originWidth = self.baseBg.transform.rect.width
    self.originHeight = self.baseBg.transform.rect.height
    self.baseRewardBgWidth = 486
end

function WinExtraRewardPanel:__BindListener()
    self.btn:SetClick( self:ToFunc("ReceiveExtraReward") )
    self.rejectBtn:SetClick( self:ToFunc("OnRejectBtnClick") )
end

function WinExtraRewardPanel:__Show()
    self.winManCanvas.sortingOrder = self:GetOrder() + GDefine.EffectOrderAdd
    self.winTitleCanvas.sortingOrder = self:GetOrder() + GDefine.EffectOrderAdd + 1
end

function WinExtraRewardPanel:__Hide()
end

function WinExtraRewardPanel:SetData(itemList,pvpId,division,trophyNum)
    self.count = mod.FightRewardProxy.fightRewardCount[BattleDefine.BattleResult.win]
    self.itemList = itemList
    self.pvpConf = Config.PvpData.data_pvp[pvpId]
    self.division = division
    self.isRoomMode = trophyNum == 0
end

function WinExtraRewardPanel:OnActive()
    self:SetBaseReward()
    local animName = ""
    if self.count >= self.maxCount or self.pvpConf.is_reward_extra == 0 or self.isRoomMode then
        self.extra:SetActive(false)
        self.btn.gameObject:SetActive(false)
        self.rejectBtn.gameObject:SetActive(false)

        UnityUtils.SetSizeDelata(self.baseBg.transform, self.baseRewardBgWidth, self.originHeight)
        UnityUtils.SetAnchoredPosition(self.base.transform, 0, 92)
        self.MainView:ActivePanelBgBtn(true)

        animName = "battle_result_window_win_base"
    else
        self.btn.gameObject:SetActive(true)
        self.rejectBtn.gameObject:SetActive(true)

        UnityUtils.SetSizeDelata(self.baseBg.transform, self.originWidth, self.originHeight)
        UnityUtils.SetAnchoredPosition(self.base.transform, -147, 92)
        self.MainView:ActivePanelBgBtn(false)
        self:SetExtraReward()

        animName = "battle_result_window_win_extra"
    end

    self.countNum.text = string.format("(%s/%s)", self.maxCount - self.count, self.maxCount)
    self.trans.gameObject:SetActive(true)

    self.MainView:PlayAnim(animName)
end

function WinExtraRewardPanel:OnInactive()
    
end

function WinExtraRewardPanel:SetBaseReward()
    for i, v in ipairs(self.itemList) do
        local item = {}
        item.gameObject = GameObject.Instantiate(self.rewardTemp)
        item.transform = item.gameObject.transform
        item.transform:SetParent(self.baseRewardCon)
        item.transform:Reset()
        -- UnityUtils.SetLocalScale(item.transform,0.8,0.8,0.8)

        item.icon = item.transform:Find("icon").gameObject:GetComponent(Image)
        item.num = item.transform:Find("num").gameObject:GetComponent(Text)

        local path = AssetPath.GetItemIcon(Config.ItemData.data_item_info[v.item_id].icon)
        self:SetSprite(item.icon,path,true)
        item.num.text = v.count

        table.insert(self.baseRewardList,item)
    end
end

function WinExtraRewardPanel:SetExtraReward()
    local extraList = Config.DivisionData.data_division_info[self.division].win_fight_reward_show
    for i, v in ipairs(extraList) do
        local item = {}
        item.gameObject = GameObject.Instantiate(self.rewardTemp)
        item.transform = item.gameObject.transform
        item.transform:SetParent(self.extraRewardCon)
        item.transform:Reset()
        -- UnityUtils.SetLocalScale(item.transform,0.8,0.8,0.8)

        item.icon = item.transform:Find("icon").gameObject:GetComponent(Image)
        item.num = item.transform:Find("num").gameObject:GetComponent(Text)

        local path = AssetPath.GetItemIcon(Config.ItemData.data_item_info[v[1]].icon)
        self:SetSprite(item.icon,path,true)
        item.num.text = v[2]

        table.insert(self.extraRewardList,item)
    end
end

function WinExtraRewardPanel:ReceiveExtraReward()
    mod.BattleFacade:SendMsg(11402,BattleDefine.BattleResult.win)
    self.MainView:CloseClick()
end

function WinExtraRewardPanel:OnRejectBtnClick()
    self.MainView:CloseClick()
end