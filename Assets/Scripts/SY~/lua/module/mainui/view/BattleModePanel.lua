BattleModePanel = BaseClass("BattleModePanel",BaseView)
BattleModePanel.Event = EventEnum.New(
    "RefreshBattleCardGroup"
)

function BattleModePanel:__Init()
    self:SetViewType(UIDefine.ViewType.panel)
    self:SetAsset("ui/prefab/mainui/mode_panel.prefab",AssetType.Prefab)

    self.isFullToBattle = true
    self.cardGroupUnitCount = Config.ConstData.data_const_info["card_group_unit_count"].val  -- 卡组单位数量
    self.unitItems = {}
end

function BattleModePanel:__Delete()
end

function BattleModePanel:__ExtendView()
    self.roomModePanel = self:ExtendView(RoomModePanel)
end

function BattleModePanel:__CacheObject()
    self.commanderQualityBg = self:Find("main/commander_node/quality_bg",Image)
    self.commanderHead = self:Find("main/commander_node/head",Image)
    self.btnFriendMode = self:Find("main/friend_btn",Button)
    self.btnMatchMode = self:Find("main/match_btn",Button)
    self.imgFriendMode = self:Find("main/friend_btn",Image)
    self.imgMatchMode = self:Find("main/match_btn",Image)

    self:CacheBattleCardGroupTabGroup()

    for i = 1, self.cardGroupUnitCount do
        local item = {}
        local root = self:Find(string.format("main/unit_list/%s",i))
        item.qualityBg = root.transform:Find("quality_bg").gameObject:GetComponent(Image)
        item.headIcon = root.transform:Find("head").gameObject:GetComponent(Image)
        root.gameObject:SetActive(true)
        table.insert(self.unitItems,item)
    end
end

function BattleModePanel:CacheBattleCardGroupTabGroup()
    self.tabs = {}
    for i=1, 5 do
        local tab = {}
        local root = self:Find(string.format("main/tab_group/tab_%s",i))
        tab.btn = root.transform:Find("normal/btn").gameObject:GetComponent(Button)
        tab.normal = root.transform:Find("normal").gameObject
        tab.select = root.transform:Find("select").gameObject
        tab.posX = root.gameObject:GetComponent(RectTransform).anchoredPosition.x
        tab.posY = root.gameObject:GetComponent(RectTransform).anchoredPosition.y
        table.insert(self.tabs, tab)
    end
    self.tabSelectState = self:Find("main/tab_group/select_state",RectTransform)
end

function BattleModePanel:__Create()
end

function BattleModePanel:__BindEvent()
    self:BindEvent(BattleModePanel.Event.RefreshBattleCardGroup)
end

function BattleModePanel:__BindListener()
    self:Find("panel_bg",Button):SetClick(self:ToFunc("OnCloseClick"))
    for i, v in ipairs(self.tabs) do
        v.btn:SetClick( self:ToFunc("SwitchTab"),i)
    end
    --TODO 绑定左右两边按钮功能
    self.btnFriendMode:SetClick(self:ToFunc("EnterRoomMode"))
    self.btnMatchMode:SetClick(self:ToFunc("EnterBattle"))
end
function BattleModePanel:__Show()
    -- 设置当前出战卡组数据显示
    local division = mod.RoleProxy:GetRoleData().division
    self.cardGroupUnlockUnitCount = Config.DivisionData.data_division_info[division].card_group_unlock_unit_count

    local data = mod.CollectionProxy:GetCommanderLibrary()
    self:RefreshTabGroup(data.index)
    self:RefreshBattleCardGroup(data)

    UIUtils.Grey(self.imgFriendMode, not mod.OpenFuncProxy:IsFuncUnlock(GDefine.FuncUnlockId.RoomBattle))
end

function BattleModePanel:__Hide()
    self.roomModePanel:CloseRoomMode()
end

function BattleModePanel:RefreshBattleCardGroup(data)
    self.isFullToBattle = true
    local commanderFlag = false
    local commanderSlot = Config.ConstData.data_const_info["commander_slot"].val
    local indexMap = {}
    for i = 1, self.cardGroupUnlockUnitCount do
        indexMap[i] = false
    end
    for k, v in pairs(data.battleGroup) do
        local slot = v.slot
        if slot then
            if slot ~= commanderSlot then
                self:SetBattleCard(slot,v.unit_id)
                indexMap[slot] = true
            else
                self:SetCurCommander(v.unit_id)
                commanderFlag = true
            end
        end
    end
    if not commanderFlag then
        self.isFullToBattle = false
        self:SetCurCommander(nil)
    end
    local count = 0
    for k, v in pairs(indexMap) do
        if v == false then
            self:SetBattleCard(k,nil)
        else
            count = count + 1
        end
    end
    -- TODO: 设置上锁状态背景图
    for i = self.cardGroupUnlockUnitCount + 1, self.cardGroupUnitCount do
        self:SetBattleCard(i,-1)
    end
    local division = mod.RoleProxy:GetRoleData().division
    local unlockCount = Config.DivisionData.data_division_info[division].card_group_unlock_unit_count
    self.isFullToBattle = count >= unlockCount
end

function BattleModePanel:SetBattleCard(slot,unitId)
    local card = self.unitItems[slot]

    
    card.headIcon.gameObject:SetActive(unitId ~= nil)
    --card.frame.gameObject:SetActive(unitId ~= nil)

    if unitId then
        if unitId == -1 then
            self:SetSprite(card.qualityBg,AssetPath.QualityToUnitDetailsIconBg[-1])
            card.headIcon.gameObject:SetActive(false)
        else
            local cfg = Config.UnitData.data_unit_info[unitId]
            self:SetSprite(card.qualityBg,AssetPath.QualityToUnitDetailsIconBg[cfg.quality])
            self:SetSprite(card.headIcon, AssetPath.GetUnitIconHeadObliqueSquare(cfg.head))
        end
    else
        self:SetSprite(card.qualityBg,AssetPath.QualityToUnitDetailsIconBg[0])
    end

    -- card.btn:SetClick( self:ToFunc("ClickEmbattleCard"),unitId,0 )
    -- if not unitId then
    --     return
    -- end
    -- local cfg = Config.UnitData.data_unit_info[unitId]
    -- self:SetSprite(card.frame,AssetPath.QualityToFrame[cfg.quality])
end

function BattleModePanel:SetCurCommander(id)
    self.commanderHead.gameObject:SetActive(id ~= nil)
    if id then
        local cfg = Config.UnitData.data_unit_info[id]
        self:SetSprite(self.commanderHead,AssetPath.GetCommanderHeadIconObliqueSquare(cfg.head), true)
        self:SetSprite(self.commanderQualityBg,AssetPath.QualityToUnitItemBg[cfg.quality])
    else
        self:SetSprite(self.commanderQualityBg,AssetPath.QualityToUnitItemBg[0])
    end
end

function BattleModePanel:SwitchTab(index)
    -- 切换出战卡组
    -- 先检测是否当前组，是否已解锁，然后发送协议，根据返回设置当前出战卡组英雄与卡牌

    --Todo 调用Proxy的方法判断是否已经解锁
    -- if not battleGroupData.unlocked then
    --     SystemMessage.Show("当前卡组未解锁")
    --     return
    -- end

    if not mod.OpenFuncProxy:JudgeFuncUnlockAndMsg(GDefine.FuncUnlockId.ChangeCardGroup) then
        return
    end

    self:RefreshTabGroup(index)
    mod.CollectionProxy:SendMsg(10205, index)
end

function BattleModePanel:RefreshTabGroup(index)
    for i, v in ipairs(self.tabs) do
        v.normal:SetActive(i ~= index)
        v.select:SetActive(i == index)
    end

    local tabInfo = self.tabs[index]
    self.tabSelectState:SetAnchoredPosition(tabInfo.posX,tabInfo.posY)
    --UnityUtils.SetAnchoredPosition(self.tabGroupSelected,(v.index-3)*91.4,-2.5)
end

function BattleModePanel:EnterRoomMode()
    -- if not mod.OpenFuncCtrl:IsOpenFuncAndMsg(1002) then
    --     return
    -- end

    if not mod.OpenFuncProxy:JudgeFuncUnlockAndMsg(GDefine.FuncUnlockId.RoomBattle) then
        return
    end

    if not self.isFullToBattle then
        SystemMessage.Show("出战队列必须满！")
        return
    end
    self.roomModePanel:OnActive()
end

function BattleModePanel:EnterBattle()
    -- if not self.isFullToBattle then
    --     SystemMessage.Show("出战队列必须满！")
    --     return
    -- end
    --mod.BattleFacade:SendMsg(10210)
    mod.BattleFacade:SendMsg(10400,"1","1")
    -- mod.BattleFacade:SendMsg(10900)
    --ViewManager.Instance:OpenWindow(MatchingWindow)
    self:OnCloseClick()
    --mod.BattleCtrl:EnterPK({})
end

function BattleModePanel:OnCloseClick()
    self:Hide()
end