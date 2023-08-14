PersonalInfoPanel = BaseClass("PersonalInfoPanel",BaseWindow)
PersonalInfoPanel.__showMainui = true
PersonalInfoPanel.__topInfo = true
PersonalInfoPanel.__bottomTab = true
PersonalInfoPanel.__topBebind = true
PersonalInfoPanel.__bottomBebind = true
PersonalInfoPanel.notTempHide = true

PersonalInfoPanel.CARDS_LEN = 8
PersonalInfoPanel.ACHI_LEN = 5

function PersonalInfoPanel:__Init()
    self:SetAsset("ui/prefab/personal_info/personal_info_panel.prefab",AssetType.Prefab)
    self.tbCards = {}
    self.tbAchieves = {}
    self.isLocalPlayer = false
end

function PersonalInfoPanel:__Delete()
end

function PersonalInfoPanel:__CacheObject()
    --panel
    self.btnClose = self:Find("main/btn_close",Button)
    self.btnBgClose = self:Find("btn_bg_close",Button)

    --base info
    self.imgIcon = self:Find("main/base_info_view/img_head",Image)
    self.txtLv = self:Find("main/base_info_view/img_head/img_lv/txt_lv",Text)
    self.txtName = self:Find("main/base_info_view/txt_name",Text)
    self.txtUid = self:Find("main/base_info_view/txt_account",Text)
    self.btnChangeName = self:Find("main/base_info_view/btn_changename",Button)
    self.txtTrophy = self:Find("main/base_info_view/image_6/txt_trophy",Text)
    self.txtUnion = self:Find("main/base_info_view/txt_union",Text)
    self.txtRankTitle = self:Find("main/base_info_view/image_13/txt_ranktitle",Text)

    --battle
    self.txtBattleWins = self:Find("main/battle_info_view/img_battle_bg/txt_winrate",Text)
    self.txtBattleCount = self:Find("main/battle_info_view/img_battle_bg/txt_battlecount",Text)

    --season
    self.txtLastRank = self:Find("main/battle_info_view/img_his_bg/txt_lastrank",Text)
    self.txtLastTrophy = self:Find("main/battle_info_view/img_his_bg/txt_lasttrophy",Text)
    self.txtMaxRank = self:Find("main/battle_info_view/img_his_bg/txt_maxrank",Text)
    self.txtMaxTrophy = self:Find("main/battle_info_view/img_his_bg/txt_maxtrophy",Text)

    --achieve
    self.contentAchieve = self:Find("main/achieve_info_view/content")
    self.achieveTemplate = self:Find("main/achieve_info_view/content/achieve_item").gameObject
    self.achieveTemplate:SetActive(false)

    --cards
    self.objCardView = self:Find("main/card_info_view").gameObject
    self.btnCopyCard = self:Find("main/card_info_view/btn_copy",Button)
    self.contentCards = self:Find("main/card_info_view/content")

    --function
    self.objFuncView = self:Find("main/function_info_view").gameObject
    self.btnChat = self:Find("main/function_info_view/btn_chat",Button)
    self.btnBattle = self:Find("main/function_info_view/btn_battle",Button)
    self.btnAddFriend = self:Find("main/function_info_view/btn_addfriend",Button)
    self.btnDelFriend = self:Find("main/function_info_view/btn_delfriend",Button)
    self.btnAddBlack = self:Find("main/function_info_view/btn_addblack",Button)
    self.btnRemoveBlack = self:Find("main/function_info_view/btn_delblack",Button)
end

function PersonalInfoPanel:__ExtendView()
    self:ExtendView(PersonalInfoAchieveView)
end

function PersonalInfoPanel:__Create()
end

function PersonalInfoPanel:__BindListener()
    self.btnChangeName:SetClick(self:ToFunc("OnChangeNameBtnClick"))
    self.btnAddFriend:SetClick(self:ToFunc("OnAddFriendBtnClick"))
    self.btnDelFriend:SetClick(self:ToFunc("OnDelFriendBtnClick"))
    self.btnBattle:SetClick(self:ToFunc("OnBattleBtnClick"))
    self.btnAddBlack:SetClick(self:ToFunc("OnAddBlackBtnClick"))
    self.btnRemoveBlack:SetClick(self:ToFunc("OnRemoveBlackBtnClick"))
    self.btnChat:SetClick(self:ToFunc("OnChatBtnClick"))
    self.btnCopyCard:SetClick(self:ToFunc("OnCopyCardsBtnClick"))
    self.btnClose:SetClick(self:ToFunc("OnCloseBtnClick"))
    self.btnBgClose:SetClick(self:ToFunc("OnCloseBtnClick"))
end

function PersonalInfoPanel:__BindEvent()
    self:BindEvent(PersonalInfoFacade.Event.ShowOtherPersonalInfo)
end

function PersonalInfoPanel:__Show()
    self.isLocalPlayer = mod.FriendProxy:IsLocal(self.args.uid)
    if self.isLocalPlayer then
        local roleData = mod.RoleProxy:GetRoleFullData()
        self:RefreshAllData(roleData,false,false)
    else
        mod.PersonalInfoFacade:SendMsg(10112,self.args.uid)
    end
end

function PersonalInfoPanel:__Hide()
    self:RemoveAllAchieveItem()
    self:RemoveAllCardItem()
end

function PersonalInfoPanel:ShowOtherPersonalInfo(uid)
    local roleData = mod.PersonalInfoProxy:GetRoleData(uid)
    if not roleData then
        LogErrorAny("无法获取玩家数据 UID=",uid)
        return
    end
    self:RefreshAllData(roleData,true,true)
end

--[[
    data = {
        role_base_info,
        role_detail_info,
    }
]]--
function PersonalInfoPanel:RefreshAllData(data,showCards,showFuncs)
    self.data = data
    self.objCardView:SetActive(showCards)
    self.objFuncView:SetActive(showFuncs)
    if showCards then
        self:RefreshCardInfo(data.role_detail_info)
    end
    if showFuncs then
        self:RefreshFuncInfo(data.role_base_info)
    end
    self:RefreshBaseInfo(data)
    self:RefreshBattleInfo(data)
    self:RefreshAchieveInfo(data.role_detail_info)
end

function PersonalInfoPanel:RefreshBaseInfo(data)
    local roleData = data.role_base_info
    local detailData = data.role_detail_info

    self.txtName.text = roleData.name
    self.txtUid.text = roleData.role_uid
    self.txtTrophy.text = roleData.trophy
    self.txtRankTitle.text = "暂无称号"
    self.txtUnion.text = detailData.guild_name or "暂无联盟"
end

function PersonalInfoPanel:RefreshBattleInfo(data)
    local roleData = data.role_base_info
    local detailData = data.role_detail_info

    self.txtBattleWins.text = UIUtils.GetWinrateText(roleData.win_count,roleData.battle_count,1)
    self.txtBattleCount.text = roleData.battle_count
    self.txtLastRank.text = detailData.last_rank
    self.txtLastTrophy.text = detailData.last_trophy
    self.txtMaxRank.text = detailData.top_rank
    self.txtMaxTrophy.text = detailData.top_trophy
end

function PersonalInfoPanel:RefreshFuncInfo(data)
    local isFri = mod.FriendProxy:IsFriend(data.role_uid)
    local isBlack = mod.FriendProxy:IsBlackList(data.role_uid)

    self.btnAddFriend.gameObject:SetActive(not isFri) --拉黑之后还能不能添加好友?
    self.btnDelFriend.gameObject:SetActive(isFri)

    self.btnAddBlack.gameObject:SetActive(not isBlack)
    self.btnRemoveBlack.gameObject:SetActive(isBlack)
end

function PersonalInfoPanel:RefreshCardInfo(data)
    self:LoadAllCardItem(data.unit_list)
end

function PersonalInfoPanel:RefreshAchieveInfo(data)
    self:LoadAllAchieveItem(data.medal_list)
end

function PersonalInfoPanel:OnCloseBtnClick()
    ViewManager.Instance:CloseWindow(PersonalInfoPanel)
end

function PersonalInfoPanel:OnChangeNameBtnClick()
    SystemMessage.Show(TI18N("功能未开放"))
end

function PersonalInfoPanel:OnAddFriendBtnClick()
    mod.FriendProxy:SendMsg(11902, self.data.role_base_info.role_uid)
end

function PersonalInfoPanel:OnDelFriendBtnClick()
    mod.FriendCtrl:ReqDelFriendByDialog(self.data.role_base_info.role_uid)
end

function PersonalInfoPanel:OnBattleBtnClick()
    SystemMessage.Show(TI18N("功能未开放"))
end

function PersonalInfoPanel:OnAddBlackBtnClick()
    mod.FriendCtrl:ReqAddBlackByDialog(self.data.role_base_info.role_uid)
end

function PersonalInfoPanel:OnRemoveBlackBtnClick()
    mod.FriendProxy:SendMsg(11911, self.data.role_base_info.role_uid)
end

function PersonalInfoPanel:OnChatBtnClick()
    SystemMessage.Show(TI18N("功能未开放"))
end

function PersonalInfoPanel:OnCopyCardsBtnClick()
    SystemMessage.Show(TI18N("已复制卡组"))
    mod.PersonalInfoProxy:SaveCardsToClipboard(self.data.cards)
end

function PersonalInfoPanel:LoadAllCardItem(datas)
    self:RemoveAllCardItem()
    local list = {}
    for _, data in ipairs(datas) do
        list[data.slot] = data
    end
    for i=1,PersonalInfoPanel.CARDS_LEN do
        local item = HeroItem.Create()
        item:SetParent(self.contentCards)
        item.transform:Reset()
        local data = list[i] or {isEmpty = true}
        item:SetData(data,i)
        table.insert(self.tbCards, item)
    end
end

function PersonalInfoPanel:RemoveAllCardItem()
    for _, item in ipairs(self.tbCards) do
        item:Destroy()
    end
    self.tbCards = {}
end

function PersonalInfoPanel:LoadAllAchieveItem(datas)
    self:RemoveAllAchieveItem()
    local list = {}
    for _, data in ipairs(datas) do
        list[data.slot] = data
    end
    for i = 1, PersonalInfoPanel.ACHI_LEN do
        local data = list[i]
        local obj = GameObject.Instantiate(self.achieveTemplate)
        obj:SetActive(true)
        obj.transform:SetParent(self.contentAchieve)
        obj.transform:Reset()
        local imgIcon = obj.transform:Find("img_icon"):GetComponent(Image)
        local objEmpty = obj.transform:Find("img_empty").gameObject
        local btn = obj:GetComponent(Button)
        btn:SetClick(self:ToFunc("OnAchieveItemClick"), data)
        if data then
            objEmpty:SetActive(false)
            --TODO 读表，显示Icon
        else
            objEmpty:SetActive(true)
        end
        table.insert(self.tbAchieves, obj)
    end
end

function PersonalInfoPanel:RemoveAllAchieveItem()
    for _, obj in ipairs(self.tbAchieves) do
        GameObject.Destroy(obj)
    end
    self.tbAchieves = {}
end

function PersonalInfoPanel:OnAchieveItemClick(data)
    if not self.isLocalPlayer then
        return
    end
    SystemMessage.Show(TI18N("暂无可佩戴勋章"))
    -- mod.PersonalInfoFacade:SendEvent(PersonalInfoAchieveView.Event.ShowAchieveView, self.data)
end