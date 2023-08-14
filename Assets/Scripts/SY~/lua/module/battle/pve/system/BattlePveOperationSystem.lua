BattlePveOperationSystem = BaseClass("BattlePveOperationSystem",SECBOperationSystem)
BattlePveOperationSystem.NAME = "BattleOperationSystem"

function BattlePveOperationSystem:__Init()
end

function BattlePveOperationSystem:__Delete()
end

function BattlePveOperationSystem:OnInitSystem()
    self:BindOperation(BattleDefine.Operation.select_pve_item,self:ToFunc("SelectPveItem"))
    self:BindOperation(BattleDefine.Operation.use_manual_item,self:ToFunc("UseManualItem"))
end

function BattlePveOperationSystem:SelectPveItem(frame, data)
    for i, v in ipairs(data.update_list) do
        self.world.BattleInputSystem:UnlockOp(v.operate_num)

        for _, info in ipairs(v.item_list) do
            local itemConf = self.world.BattleConfSystem:PveData_data_pve_item(info.item_group_id,info.item_id)
            if not itemConf then
                Log(info.item_group_id,info.item_id)
            end
            local selectedItem = {}
            selectedItem.itemConf = itemConf
            if itemConf.type == BattleDefine.pveItemEffectType.manual_skill then
                selectedItem.manualInfo = {}
                selectedItem.eventList = {}
                local eventId = itemConf.event_list[1]
                local eventConf = self.world.BattleConfSystem:EventData_data_event_info(eventId)
                if eventConf then
                    selectedItem.manualInfo.cd = itemConf.cd
                    selectedItem.manualInfo.cdTime = 0
                    selectedItem.manualInfo.eventId = eventId
                    selectedItem.manualInfo.skillId = eventConf.action_args.skillId
                    selectedItem.manualInfo.skillLev = eventConf.action_args.skillLev
                    -- local from =  {roleUid = v.role_uid, camp = v.camp, entityUid = v.entity_uid}
                    -- selectedItem.from = from
                else
                    assert(false,string.format("道具[%s]的事件列表中[%s]的配置不存在", info.item_group_id.."_"..info.item_id, itemConf.event_list[1]))
                end
            else
                selectedItem.eventList = {}
                for _, eventId in ipairs(itemConf.event_list) do
                    local from =  {roleUid = v.role_uid, camp = v.camp, entityUid = v.entity_uid}
                    local event = self.world.BattleMagicEventSystem:AddMagicEvent(eventId,from)
                    if event then
                        table.insert(selectedItem.eventList,event.uid)
                    end
                end
            end
            self.world.BattleDataSystem:AddSelectedItem(selectedItem)
        end
    end
end

function BattlePveOperationSystem:UseManualItem(frame,data)
    for i,v in ipairs(data.frame_list) do
        self.world.BattleInputSystem:UnlockOp(v.operate_num)

        local useInfo = TableUtils.SerializerDecode(v.data)
        local entity = self.world.EntitySystem:GetRoleCommander(v.role_uid)
        if entity then
            local selectedItems = self.world.BattleDataSystem:GetSelectedItems()
            local index = nil
            local selectedItem = nil
            for ii, vv in ipairs(selectedItems) do
                if vv.manualInfo and vv.manualInfo.eventId == v.event_id then
                    index = ii
                    selectedItem = vv
                end
            end
            local from =  {roleUid = v.role_uid, camp = v.camp, entityUid = v.entity_uid, useInfo = useInfo}
            self.world.BattleMagicEventSystem:AddMagicEvent(v.event_id,from)
            selectedItem.manualInfo.cdTime = selectedItem.manualInfo.cd
            self.world.ClientIFacdeSystem:Call("SendEvent",BattlePveItemView.Event.RefreshItemCd,index,selectedItem)
        end
    end
end

