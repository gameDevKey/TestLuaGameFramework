BattleMagicEventSystem = BaseClass("BattleMagicEventSystem",SECBSystem)

function BattleMagicEventSystem:__Init()
    self.magicEvents = {}
	self.magicEventList = SECBList.New()

    self.lastMap = {[-1]=true} -- 初始放一个数据，处理刚开始二者都为空列表的情况
end

function BattleMagicEventSystem:__Delete()
	for iter in self.magicEventList:Items() do
        local magicEvent = self.magicEvents[iter.value]
        self:DoRemoveEvent(magicEvent)
    end
	self.magicEventList:Delete()
end


--[[ function BattleMagicEventSystem:OnLateInitSystem()
    -- self.world.EventTriggerSystem:AddListener(BattleEvent.begin_battle,self:ToFunc("BeginBattle"))
    -- self.world.EventTriggerSystem:AddListener(BattleEvent.place_unit,self:ToFunc("PlaceUnit"))
    -- self.world.EventTriggerSystem:AddListener(BattleEvent.update_unit,self:ToFunc("UpdateUnit"))
    -- self.world.EventTriggerSystem:AddListener(BattleEvent.cancel_unit,self:ToFunc("CancelUnit"))
-- end

-- function BattleMagicEventSystem:BeginBattle()
--     for _,roleUid in ipairs(self.world.BattleDataSystem:GetCampRoleUid(BattleDefine.Camp.attack)) do
--         local commanderInfo = self.world.BattleDataSystem:GetCampCommanderInfo(roleUid)

--         local entity = self.world.EntitySystem:GetRoleCommander(roleUid)

--         for i,v in ipairs(commanderInfo.skill_list) do
--             local levConf = self.world.BattleConfSystem:SkillData_data_skill_lev(v.skill_id,v.skill_level)
--             for _,eventId in ipairs(levConf.events) do
--                 --Log("添加事件",eventId)
--                 local skill = entity.SkillComponent:GetSkill(v.skill_id)
--                 local event = self:AddMagicEvent(eventId,{roleUid = roleUid,camp = BattleDefine.Camp.attack,unitId = commanderInfo.unit_id,skill = skill})
--             end
--         end
--     end

--     for _,roleUid in ipairs(self.world.BattleDataSystem:GetCampRoleUid(BattleDefine.Camp.defence)) do
--         local commanderInfo = self.world.BattleDataSystem:GetCampCommanderInfo(roleUid)

--         local entity = self.world.EntitySystem:GetRoleCommander(roleUid)

--         for i,v in ipairs(commanderInfo.skill_list) do
--             local levConf = self.world.BattleConfSystem:SkillData_data_skill_lev(v.skill_id,v.skill_level)
--             for _,eventId in ipairs(levConf.events) do
--                 local skill = entity.SkillComponent:GetSkill(v.skill_id)
--                 local event = self:AddMagicEvent(eventId,{roleUid = roleUid,camp = BattleDefine.Camp.defence,unitId = commanderInfo.unit_id,skill = skill})
--             end
--         end
--     end
-- end

-- function BattleMagicEventSystem:PlaceUnit(args)
--     LogTable("args1111111",args)
--     self:UpdatePlaceUnitEvent(args.roleUid,args.camp,args.unitId,args.grid)
-- end

-- function BattleMagicEventSystem:UpdateUnit(args)
--     LogTable("args2222222",args)
--     self:UpdatePlaceUnitEvent(args.roleUid,args.camp,args.unitId,args.grid)
-- end

-- function BattleMagicEventSystem:UpdatePlaceUnitEvent(roleUid,camp,unitId,grid)
--     local conf = self.world.BattleConfSystem:UnitData_data_unit_info(unitId)
--     local heroInfo = self.world.BattleDataSystem:GetUnitDataByGrid(roleUid,grid)

--     if not self.roleUnitEvents[roleUid] then
--         self.roleUnitEvents[roleUid] = {}
--     end

--     if not self.roleUnitEvents[roleUid][unitId] then
--         self.roleUnitEvents[roleUid][unitId] = SECBList.New()
--     end

--     local curUnitEvents = self.roleUnitEvents[roleUid][unitId]

--     local unitEvents = {}

--     local newAddEvents = {}
--     local removeEvents = {}

--     for i,v in ipairs(heroInfo.skill_list) do
--         local levConf = self.world.BattleConfSystem:SkillData_data_skill_lev(v.skill_id,v.skill_level)
--         for _,eventId in ipairs(levConf.events) do
--             if unitEvents[eventId] then
--                 assert(false,string.format("不同的技能配置了相同的事件Id[技能ID:%s][技能等级:%s]",v.skill_id,v.skill_level))
--             end
--             unitEvents[eventId] = true
            
--             if not curUnitEvents:ExistIndex(eventId) then
--                 table.insert(newAddEvents,eventId)
--             end
--         end
--     end

--     for iter in curUnitEvents:Items() do
--         local uid = iter.value
--         local event = self:GetEventByUid(uid)
--         if not unitEvents[event.eventId] then
--             table.insert(removeEvents,uid)
--         end
--     end

--     for _,uid in ipairs(removeEvents) do
--         local event = self:GetEventByUid(uid)
--         self:DoRemoveEvent(event)
--         self.roleUnitEvents[roleUid][unitId]:RemoveByIndex(event.eventId)
--     end

--     for _,eventId in ipairs(newAddEvents) do
--         local event = self:AddMagicEvent(eventId,{roleUid = roleUid,camp = camp,unitId = unitId})
--         self.roleUnitEvents[roleUid][unitId]:Push(event.uid,event.eventId)
--     end
-- end

-- function BattleMagicEventSystem:CancelUnit(args)
--     --取消
--     local removeEvents = {}
--     local curUnitEvents = self.roleUnitEvents[args.roleUid][args.unitId]
--     for iter in curUnitEvents:Items() do
--         local uid = iter.value
--         table.insert(removeEvents,uid)
--     end

--     for _,uid in ipairs(removeEvents) do
--         local event = self:GetEventByUid(uid)
--         self:DoRemoveEvent(event)
--         self.roleUnitEvents[args.roleUid][args.unitId]:RemoveByIndex(event.eventId)
--     end
-- end]]

function BattleMagicEventSystem:OnUpdate()
	for iter in self.magicEventList:Items() do
		local magicEvent = self.magicEvents[iter.value]
		magicEvent:Update()
	end
end

function BattleMagicEventSystem:AddMagicEvent(eventId,from)
    local uid = self.world:GetUid(BattleDefine.UidType.magic_event)
	local event = MagicEvent.New()
	event:SetWorld(self.world)
	event:Init(eventId,uid,from)
	self:DoAddEvent(event)

	event:CheckExecute(0)

	if event:CheckRemove() then
        self:RemoveEventByUid(uid)
		return nil
	else
		return event
    end
end

function BattleMagicEventSystem:GetMagicEventByUid(uid)
	return self.magicEvents[uid]
end

function BattleMagicEventSystem:GetMagicEventById(eventId)
	local iter = self.magicEventList:GetIterByIndex(eventId)
	if iter then
		return self:GetMagicEventByUid(iter.value)
	end
end

function BattleMagicEventSystem:RemoveMagicEvent(eventUid)
    self:RemoveEventByUid(eventUid)
end


function BattleMagicEventSystem:RemoveEventByUid(uid)
	local event = self.magicEvents[uid]
	if event then
        self:DoRemoveEvent(event)
	end
end

function BattleMagicEventSystem:DoAddEvent(event)
	local eventUid = event.uid

	self.magicEvents[eventUid] = event
	self.magicEventList:Push(eventUid,eventUid)
end

function BattleMagicEventSystem:DoRemoveEvent(event)
	local eventUid = event.uid
	self.magicEvents[eventUid] = nil

	self.magicEventList:RemoveByIndex(eventUid)

	event:DoRemove()
	event:Delete()
end

function BattleMagicEventSystem:GetEventByUid(uid)
    return self.magicEvents[uid]
end

-- function BattleMagicEventSystem:OnLateUpdate()
--     self:UpdateValidHaloInfo()
-- end

-- function BattleMagicEventSystem:UpdateValidHaloInfo()
--     if not self.world.opts.isClient then
--         return
--     end
--     local validHalo = {}
--     local updateMap = {}
--     local hadChanged = false
--     for k,v in pairs(self.magicEvents) do
--         if v:GetIsValid() then
--             local data = {}
--             data.eventId = v.eventId
--             data.args = {roleUid = v.from.roleUid,conf = v.conf}
--             table.insert(validHalo,data)
--             updateMap[tostring(k)] = true
--         end
--     end

--     for k, v in pairs(updateMap) do  -- 更新后有数据而更新前没有 有新增
--         local map = self.lastMap[k]
--         if map == nil then
--             hadChanged = true
--             self.lastMap[k] = true
--             break
--         end
--     end

--     for k, v in pairs(self.lastMap) do  -- 更新后没有数据而更新前有数据 有删除
--         local map = updateMap[k]
--         if map == nil then
--             self.lastMap[k] = nil
--             hadChanged = true
--             break
--         end
--     end

--     if hadChanged then
--         self.world.ClientIFacdeSystem:Call("SendEvent",BattleHaloTipsView.Event.RefreshHaloList,validHalo)
--     end
-- end