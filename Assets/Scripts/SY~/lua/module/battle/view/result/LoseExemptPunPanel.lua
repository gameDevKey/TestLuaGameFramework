LoseExemptPunPanel = BaseClass("LoseExemptPunPanel",ExtendView)

-- LoseExemptPunPanel.Event = EventEnum.New()

function LoseExemptPunPanel:__Init()
    self.maxCount = Config.ConstData.data_const_info["daily_fight_lose_offset"].val
    self.count = 0
    self.toReduceTrophy = 0
end

function LoseExemptPunPanel:__Delete()

end

function LoseExemptPunPanel:__BindEvent()
end

function LoseExemptPunPanel:__CacheObject()
    self.trans = self:Find("main/reward_panel/lose")
    self.base = self:Find("base",nil,self.trans).gameObject
    self.baseBg = self:Find("base/bg",nil,self.trans)
    self.num = self:Find("base/num",Text,self.trans)

    self.extra = self:Find("extra",nil,self.trans).gameObject
    self.btn = self:Find("extra/btn",Button,self.trans)
    self.countNum = self:Find("extra/btn/count",Text,self.trans)
    self.rejectBtn = self:Find("extra/reject_btn",Button,self.trans)

    -- self.cardGroup = self:Find("main/player_msg_2/card_group")
end

function LoseExemptPunPanel:__Create()
    self:Find("base/title",Text,self.trans).text = TI18N("失败惩罚")
    self:Find("extra/title",Text,self.trans).text = TI18N("额外庇护")
    self:Find("extra/content",Text,self.trans).text = TI18N("接受庇护，免除扣杯")
    self:Find("text",Text,self.btn.transform).text = TI18N("接收庇护")
    self:Find("text",Text,self.rejectBtn.transform).text = TI18N("残忍拒绝")

    self.originWidth = self.baseBg.transform.rect.width
    self.originHeight = self.baseBg.transform.rect.height
    self.baseRewardBgWidth = 486
end

function LoseExemptPunPanel:__BindListener()
    self.btn:SetClick( self:ToFunc("ExemptPunishment") )
    self.rejectBtn:SetClick( self:ToFunc("OnRejectBtnClick") )
end

function LoseExemptPunPanel:__Show()

end

function LoseExemptPunPanel:__Hide()
end

function LoseExemptPunPanel:SetData(toReduceTrophy,pvpId)
    self.count = mod.FightRewardProxy.fightRewardCount[BattleDefine.BattleResult.lose]
    self.toReduceTrophy = toReduceTrophy

    self.pvpConf = Config.PvpData.data_pvp[pvpId]
end

function LoseExemptPunPanel:OnActive()
    if self.count >= self.maxCount or self.toReduceTrophy == 0 or self.pvpConf.is_reward_extra == 0 then
        self.extra:SetActive(false)
        UnityUtils.SetSizeDelata(self.baseBg.transform, self.baseRewardBgWidth, self.originHeight)
        UnityUtils.SetAnchoredPosition(self.base.transform, 0, 92)
        self.MainView:ActivePanelBgBtn(true)
    else
        UnityUtils.SetSizeDelata(self.baseBg.transform, self.originWidth, self.originHeight)
        UnityUtils.SetAnchoredPosition(self.base.transform, -147, 92)
        self.MainView:ActivePanelBgBtn(false)
    end
    local trophyNum = self.toReduceTrophy == 0 and "-0" or self.toReduceTrophy
    self.num.text = trophyNum
    self.countNum.text = string.format("(%s/%s)", self.maxCount - self.count, self.maxCount)
    self.trans.gameObject:SetActive(true)
end

function LoseExemptPunPanel:OnInactive()
    self.trans.gameObject:SetActive(false)
end

function LoseExemptPunPanel:ExemptPunishment()
    mod.BattleFacade:SendMsg(11402,BattleDefine.BattleResult.lose)
    self.MainView:CloseClick()
end

function LoseExemptPunPanel:OnRejectBtnClick()
    self.MainView:CloseClick()
end