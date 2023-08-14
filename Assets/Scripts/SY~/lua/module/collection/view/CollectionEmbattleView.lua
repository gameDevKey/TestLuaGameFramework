CollectionEmbattleView = BaseClass("CollectionEmbattleView",ExtendView)

CollectionEmbattleView.Event = EventEnum.New(
    "RefreshEmbattleView"
)

function CollectionEmbattleView:__Init()
    self.tabs = {}
    self.embattleCards = {}
    self.cardGroupUnitCount = nil
    self.cardGroupUnlockUnitCount = nil
end

function CollectionEmbattleView:__Delete()
    for i, tab in ipairs(self.tabs) do
        GameObject.Destroy(tab.gameObject)
    end

    for i, v in ipairs(self.embattleCards) do
        v:Destroy()
    end
end

function CollectionEmbattleView:__CacheObject()
    self.embattleCardParent = self:Find("main/scroll_view/view_port/content/embattle_node/embattle_card_con")
    self.tabGroup = self:Find("main/scroll_view/view_port/content/embattle_node/embattle_tab_group")
    self.tabTemp = self:Find("main/scroll_view/view_port/content/embattle_node/embattle_tab_group/tab_temp").gameObject

    self.itemTemp = self:Find("template/item").gameObject
end

function CollectionEmbattleView:__Create()
    self.cardGroupCount = Config.ConstData.data_const_info["card_group_count"].val  -- 最大卡组数量
    self.cardGroupUnitCount = Config.ConstData.data_const_info["card_group_unit_count"].val  -- 最大卡组单位数量
    local division = mod.RoleProxy:GetRoleData().division
    self.cardGroupUnlockUnitCount = Config.DivisionData.data_division_info[division].card_group_unlock_unit_count

    self:CreateEmbattleCards()
    self:CreateTabs()
end

function CollectionEmbattleView:__BindEvent()
    self:BindEvent(CollectionEmbattleView.Event.RefreshEmbattleView)
end

function CollectionEmbattleView:__BindListener()
    for index, tab in ipairs(self.tabs) do
        tab.btn:SetClick(self:ToFunc("SwitchTab"),index)
    end
end

function CollectionEmbattleView:__Show()
    local data = mod.CollectionProxy:GetEmbattleGroupData()
    for index, tab in ipairs(self.tabs) do
        if index == data.index then
            tab.isOn = true
            tab.normalNode:SetActive(false)
            tab.selectedNode:SetActive(true)
        else
            tab.isOn = false
            tab.normalNode:SetActive(true)
            tab.selectedNode:SetActive(false)
        end
    end
    self:RefreshEmbattleView(data)
end

function CollectionEmbattleView:CreateEmbattleCards()
    for i = 1, self.cardGroupUnitCount do
        local card = CollectionItem.Create(self.itemTemp)
        card.transform:SetParent(self.embattleCardParent)
        card.transform:Reset()
        self.embattleCards[i] = card
    end
end

function CollectionEmbattleView:CreateTabs()
    for i = 1, self.cardGroupCount do
        local obj = GameObject.Instantiate(self.tabTemp)
        obj.transform:SetParent(self.tabGroup)
        obj.transform:Reset()

        local tab = {}
        tab.gameObject = obj
        tab.transform = obj.transform
        tab.btn = obj:GetComponent(Button)
        tab.normalNode = tab.transform:Find("normal").gameObject
        tab.normalNode.transform:Find("text").gameObject:GetComponent(Text).text = i
        tab.selectedNode = tab.transform:Find("selected").gameObject
        tab.selectedNode.transform:Find("text").gameObject:GetComponent(Text).text = i
        tab.isOn = false
        tab.normalNode:SetActive(true)
        tab.selectedNode:SetActive(false)
        table.insert(self.tabs,tab)
    end
    self.tabTemp:SetActive(false)
end

function CollectionEmbattleView:SwitchTab(index)
    if self.tabs[index].isOn then
        return
    end

    if not mod.OpenFuncProxy:JudgeFuncUnlockAndMsg(GDefine.FuncUnlockId.ChangeCardGroup) then
        return
    end

    for i, v in ipairs(self.tabs) do
        if i == index then
            v.isOn = true
            v.normalNode:SetActive(false)
            v.selectedNode:SetActive(true)
        else
            v.isOn = false
            v.normalNode:SetActive(true)
            v.selectedNode:SetActive(false)
        end
    end

    mod.CollectionFacade:SendMsg(10205, index)
end

function CollectionEmbattleView:RefreshEmbattleView(data)
    local embattleGroupData = data.embattleGroupData

    self.emptyIndex = 11
    local commanderSlot = Config.ConstData.data_const_info["commander_slot"].val
    local indexMap = {}
    for i = 1, self.cardGroupUnlockUnitCount do
        indexMap[i] = false
    end
    for k, v in pairs(embattleGroupData) do
        local slot = v.slot
        if slot then
            if slot ~= commanderSlot then
                self:SetBattleCard(slot, v.unit_id, false)
                indexMap[slot] = true
            end
        end
    end

    for k, v in pairs(indexMap) do
        if v == false then
            if k < self.emptyIndex then
                self.emptyIndex = k
            end
            self:SetBattleCard(k, nil, false)
        end
    end
    for i = self.cardGroupUnlockUnitCount + 1, self.cardGroupUnitCount do
        self:SetBattleCard(i, nil, true)
    end
end

function CollectionEmbattleView:SetBattleCard(slot,unitId,isLock)
    local card = self.embattleCards[slot]
    if not card then
        card = CollectionItem.Create(self.itemTemp)
        card.transform:SetParent(self.embattleCardParent)
        card.transform:Reset()
        self.embattleCards[slot] = card
    end
    local conf = nil
    local cardData = nil
    local data = {}
    if unitId then
        conf = Config.UnitData.data_unit_info[unitId]
        cardData = mod.CollectionProxy:GetDataById(unitId)
        data = {conf = conf, data = cardData, isLock = isLock}
    else
        data = {conf = nil, data = nil, isLock = isLock}
    end
    card:SetAnim(AssetPath.collectionItemCtrl, self.MainView.collectionItemCtrl)
    card:SetData(data)
    card:Show()
    if conf and conf.id then
        card:SetClickCb(self:ToFunc("ShowDetails"),conf.id)
    end
    card:RemoveRemind()
    card.newRemindNode:SetActive(false)
    card:SetNewRemind()
    card:SetEmbattledUpgradeRemind()
end

function CollectionEmbattleView:ShowDetails(unitId)
    self.MainView:ShowDetails(unitId)
end