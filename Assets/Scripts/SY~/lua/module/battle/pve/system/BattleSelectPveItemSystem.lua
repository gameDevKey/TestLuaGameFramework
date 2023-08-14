BattleSelectPveItemSystem = BaseClass("BattleSelectPveItemSystem",SECBSystem)
BattleSelectPveItemSystem.NAME = "SelectPveItemSystem"

function BattleSelectPveItemSystem:__Init()
    self.selectTimer = nil
    self.waitForRemoveFlag = false
end

function BattleSelectPveItemSystem:__Delete()
    self:RemoveSelectTimer()
    self:RemoveSelectedItems()
end

function BattleSelectPveItemSystem:OnInitSystem()
end

function BattleSelectPveItemSystem:OnLateInitSystem()
    self.world.EventTriggerSystem:AddListener(BattleEvent.enter_round,self:ToFunc("OnEnterRound"))
end

function BattleSelectPveItemSystem:OnEnterRound(params)
    local pveId = self.world.BattleGroupSystem.pveId
    local groupConf = self.world.BattleConfSystem:PveData_data_pve_group(pveId,params.round)
    if groupConf and not TableUtils.IsEmpty(groupConf.pve_item_group) then
        self:RandomPveItems()
    end
end

function BattleSelectPveItemSystem:RandomPveItems()
    local selectedItems = self.world.BattleDataSystem:GetSelectedItems()
    if selectedItems and #selectedItems >= 4 then --TODO 4 修改为读取配置
        LogError(false,string.format("道具已经为最大值%s，但仍进入了获得随机道具逻辑",4))
        return
    end

    mod.BattleCtrl:CancelOperate()

    self.pveId = self.world.BattleDataSystem.data.pve_base_id
    self.currentGroup = self.world.BattleGroupSystem.currentGroup
    local groupInfo =  self.world.BattleConfSystem:PveData_data_pve_group(self.pveId,self.currentGroup)
    local pveItemGroupList = groupInfo.pve_item_group
    local index = 1
    if #pveItemGroupList > 1 then
        index = self.world.BattleRandomSystem:Random(1,#pveItemGroupList)
    end
    self.pveItemGroup = pveItemGroupList[index]
    local itemList = self.world.BattleConfSystem:PveData_data_group_pve_item(self.pveItemGroup)
    local toSelectItemList = TableUtils.CopyTable(itemList)
    local waitSelectItems = self.world.PveReserveItemSystem:GetReserveSelectItems() or self:GetWaitSelectItems(selectedItems, toSelectItemList)
    self.world.BattleDataSystem:SetWaitSelectItems(waitSelectItems)

    self.world.BattleMixedSystem:BattlePause(true)

    local selectTime = FPMath.Divide(self.world.BattleDataSystem.pveConf.select_pve_item_time,1000)
    self.countDown = selectTime
    if not self.world.BattleStateSystem.isReplay then
        self.world.ClientIFacdeSystem:Call("SendEvent",BattlePveSelectItemView.Event.RefreshSelectItems,waitSelectItems)
        self.world.ClientIFacdeSystem:Call("SendEvent",BattlePveSelectItemView.Event.RefreshCountDownTime,self.countDown)
        self.world.EventTriggerSystem:Trigger(BattleEvent.pve_select_item_begin)
    end

    self:StartSelectTimer(selectTime)
end

function BattleSelectPveItemSystem:GetWaitSelectItems(selectedItems, toSelectItemList)
    for i, v in ipairs(toSelectItemList) do
        v.item_group_id = self.pveItemGroup
    end
    for _, selectedItem in ipairs(selectedItems) do
        for i, v in ipairs(toSelectItemList) do
            if v.item_id == selectedItem.itemConf.item_id then
                table.remove(toSelectItemList,i)
            end
        end
    end

    local itemListLen = #toSelectItemList
    if itemListLen < 3 then
        assert(false,string.format("道具效果数量过少[pve_id:%s][group:%s] [item_group:%s]",self.pveId,self.currentGroup,self.pveItemGroup))
    elseif itemListLen == 3 then
        return toSelectItemList
    end

    local waitSelectItems = {}
    for i = 1, 3 do
        local index = self.world.BattleRandomSystem:Random(1,#toSelectItemList)
        table.insert(waitSelectItems,toSelectItemList[index])
        table.remove(toSelectItemList,index)
    end
    return waitSelectItems
end

function BattleSelectPveItemSystem:OnSelectTimer()
    self.countDown = self.countDown - 1
    self.world.ClientIFacdeSystem:Call("SendEvent",BattlePveSelectItemView.Event.RefreshCountDownTime,self.countDown)
    if self.countDown == 0 then
        local waitSelectSkills = self.world.BattleDataSystem:GetWaitSelectItems()
        self.world.BattleRandomSystem:SetRenderRandom(true)
        local index = self.world.BattleRandomSystem:Random(1,#waitSelectSkills)
        self.world.BattleRandomSystem:SetRenderRandom(false)
        self.world.ClientIFacdeSystem:Call("SendEvent",BattlePveSelectItemView.Event.SelectItem,index)
    end
end

function BattleSelectPveItemSystem:SelectPveItem(index)
    self:RemoveSelectTimer()
    local waitSelectSkills = self.world.BattleDataSystem:GetWaitSelectItems()
    local item_id = waitSelectSkills[index].item_id
    self.world.BattleInputSystem:AddSelectPveItem(self.pveItemGroup,item_id)

    self.world.EventTriggerSystem:Trigger(BattleEvent.pve_select_item, index)

    if self.world.PveReserveItemSystem.isReserveRandom then
        self.world.PveReserveItemSystem.reserveIndex = self.world.PveReserveItemSystem.reserveIndex + 1
    end

    self.world.BattleMixedSystem:BattlePause(false)
end

function BattleSelectPveItemSystem:StartSelectTimer(selectTime)
    self:RemoveSelectTimer()
    if self.waitForRemoveFlag then
        self.waitForRemoveFlag = false
        return
    end
    self.selectTimer = TimerManager.Instance:AddTimer(selectTime, 1, self:ToFunc("OnSelectTimer"))
end

function BattleSelectPveItemSystem:RemoveSelectTimer()
    if self.selectTimer then
        TimerManager.Instance:RemoveTimer(self.selectTimer)
        self.selectTimer = nil
    end
end

function BattleSelectPveItemSystem:PauseSelectTimer()
    if self.selectTimer then
        self:RemoveSelectTimer()
    else
        self.waitForRemoveFlag = true
    end
end

function BattleSelectPveItemSystem:RemoveSelectedItems()
    local selectedItems = self.world.BattleDataSystem:GetSelectedItems()
    --TODO 移除event
    for i, v in ipairs(selectedItems) do
        if next(v.eventList) ~= nil then
            for _, eventUid in ipairs(v.eventList) do
                self.world.BattleMagicEventSystem:RemoveMagicEvent(eventUid)
            end
        end
    end
    selectedItems = nil
end