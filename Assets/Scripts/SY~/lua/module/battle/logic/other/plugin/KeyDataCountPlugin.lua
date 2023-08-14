KeyDataCountPlugin = BaseClass("KeyDataCountPlugin",SECBPlugin)
KeyDataCountPlugin.NAME = "KeyDataCount"

function KeyDataCountPlugin:__Init()
    self.keyData = {}

    self.countKeyOrder =
    {
        [1] = BattleDefine.CountKey.debuff_all_entity,
    }

    self.countKeyMapping =
    {
        [BattleDefine.CountKey.debuff_all_entity] = {InitFunc = "InitDebuffAllEntityCount", AddFunc = "AddDebuffAllEntityCount", ReduceFunc = "ReduceDebuffAllEntityCount", DelFunc = "DelDebuffAllEntityCount"},
    }

    self:InitCountKeyMapping()
end

function KeyDataCountPlugin:__Delete()
    for i, countKey in ipairs(self.countKeyOrder) do
        self[self.countKeyMapping[countKey].DelFunc](self)
    end
end

function KeyDataCountPlugin:InitCountKeyMapping()
    for i, countKey in ipairs(self.countKeyOrder) do
        self[self.countKeyMapping[countKey].InitFunc](self)
    end
end

function KeyDataCountPlugin:GetCountByCountKey(countKey)
    return self.keyData[countKey].count
end

function KeyDataCountPlugin:AddCount(countKey,args)
    self[self.countKeyMapping[countKey].AddFunc](self, args)
end

function KeyDataCountPlugin:ReduceCount(countKey,args)
    self[self.countKeyMapping[countKey].ReduceFunc](self,args)
end

function KeyDataCountPlugin:OnKeyDataCountChange(countKey)
    self.world.EventTriggerSystem:Trigger(BattleEvent.key_data_count_change,countKey,self:GetCountByCountKey(countKey))
end

function KeyDataCountPlugin:InitDebuffAllEntityCount()
    local data = {}
    self.keyData[BattleDefine.CountKey.debuff_all_entity] = data

    data.debuffDict = {}
    data.debuffList = {}
    data.debuffList[BattleDefine.Camp.attack] = SECBList.New()
    data.debuffList[BattleDefine.Camp.defence] = SECBList.New()
    data.count = self:GetDebuffAllEntityCount()
end

function KeyDataCountPlugin:DelDebuffAllEntityCount()
    for i, v in ipairs(self.keyData[BattleDefine.CountKey.debuff_all_entity].debuffList) do
        v:Delete()
    end
end

function KeyDataCountPlugin:AddDebuffAllEntityCount(args)
    local data = self.keyData[BattleDefine.CountKey.debuff_all_entity]

    if not data.debuffList[args.camp]:ExistIndex(args.groupKey) then
        data.debuffList[args.camp]:Push({},args.groupKey)
    end

    if not data.debuffDict[args.buffKey] then
        table.insert(data.debuffList[args.camp]:GetIterByIndex(args.groupKey).value,args.buffKey)
    end

    data.debuffDict[args.buffKey] = args.overlay

    -- LogTable("afterAdd"..args.groupKey.." "..args.buffKey.." "..args.overlay, data.debuffList[args.camp]:GetIterByIndex(args.groupKey))

    data.count = self:GetDebuffAllEntityCount()
    self:OnKeyDataCountChange(BattleDefine.CountKey.debuff_all_entity)
end

function KeyDataCountPlugin:ReduceDebuffAllEntityCount(args)
    local data = self.keyData[BattleDefine.CountKey.debuff_all_entity]
    if not data.debuffDict[args.buffKey] then
        assert(false,string.format("减益效果计数移除数据异常,数据中不存在entityUid_buffGroup[%s];buffId_buffUid[%s]的数据",args.groupKey,args.buffKey))
    end

    data.debuffDict[args.buffKey] = nil

    local iter = data.debuffList[args.camp]:GetIterByIndex(args.groupKey)

    local index = nil
    for i, v in ipairs(iter.value) do
        if v == args.buffKey then
            index = i
            break
        end
    end
    table.remove(iter.value,index)
    -- LogTable("afterReduce"..args.groupKey.." "..args.buffKey, iter)
    if #iter.value == 0 then
        data.debuffList[args.camp]:RemoveByIndex(args.groupKey)
    end
    data.count = self:GetDebuffAllEntityCount()
    self:OnKeyDataCountChange(BattleDefine.CountKey.debuff_all_entity)
end

function KeyDataCountPlugin:GetDebuffAllEntityCount()
    local count = 0
    local data = self.keyData[BattleDefine.CountKey.debuff_all_entity]
    local overlayData = data.debuffDict

    for i, debuffList in ipairs(data.debuffList) do
        for iter in debuffList:Items() do
            local maxOverlay = 0
            for ii, buffKey in ipairs(iter.value) do
                if overlayData[buffKey] > maxOverlay then
                    maxOverlay = overlayData[buffKey]
                end
            end
            count = count + maxOverlay
        end
    end
    return count
end