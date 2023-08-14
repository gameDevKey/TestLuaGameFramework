BattleChestDropSystem = BaseClass("BattleChestDropSystem",SECBEntitySystem)

function BattleChestDropSystem:__Init()
end

function BattleChestDropSystem:__Delete()
end

function BattleChestDropSystem:InitDrop(randSeed,pveId)
    self.tbChest = {}               --map[id]num 所有的掉落物 
    self.random = FPRandom(randSeed)
    self.pveId = pveId
    self.groupAwardRecorder = {}    --map[group]num
end

function BattleChestDropSystem:OnLateInitSystem()
    self.world.EventTriggerSystem:AddListener(BattleEvent.unit_die,self:ToFunc("OnKillUnit"))
end

function BattleChestDropSystem:GetRandomNum(min,max)
    return self.random:Range(min,max)
end

function BattleChestDropSystem:OnKillUnit(args)
    local entity = self.world.EntitySystem:GetEntity(args.dieEntityUid)
    local camp = entity.CampComponent:GetCamp()
    -- LogYqh("掉落系统监听到击杀 entityId,unitId,camp",args.dieEntityUid,entity.ObjectDataComponent.unitConf.id,camp)
    if camp ~= BattleDefine.Camp.attack then
        return
    end
    self:TryGetRandomChest(entity)
end

function BattleChestDropSystem:TryGetRandomChest(entity)
    if not entity then return end

    local objectData = entity.ObjectDataComponent.objectData
    local group = entity.ObjectDataComponent.group

    -- LogYqh("尝试掉落宝物 group,objectData.monsterConf",group,objectData.monsterConf)

    local groupConf = self.world.BattleConfSystem:PveData_data_pve_group(self.pveId, group)
    if not groupConf then return end

    local groupMaxAward = groupConf.max_award
    if not self.groupAwardRecorder[group] then
        self.groupAwardRecorder[group] = 0
    end
    if self.groupAwardRecorder[group] >= groupMaxAward then
        -- LogYqh("达到第",group,"波的最大掉落次数",groupMaxAward)
        return
    end

    --击杀奖励
    local chest = self:GetRandomChest(groupConf.award_rate,groupConf.award_list)
    if chest then
        self.groupAwardRecorder[group] = self.groupAwardRecorder[group] + 1
        LogYqh("击杀奖励",chest,"波数", group,"总个数", self.groupAwardRecorder[group],"/",groupMaxAward)
        self:AddChest(chest)
    end
    --额外奖励（不会被最大掉落次数限制）
    local monsterConf = objectData.monsterConf
    local exChest = self:GetRandomChest(monsterConf.award_rate,monsterConf.award_list)
    if exChest then
        LogYqh("额外奖励",exChest,"波数", group)
        self:AddChest(exChest)
    end
end

function BattleChestDropSystem:AddChest(chest)
    if not chest then return end

    if not self.tbChest[chest.id] then
        self.tbChest[chest.id] = 0
    end
    self.tbChest[chest.id] = self.tbChest[chest.id] + chest.num

    self.world.ClientIFacdeSystem:Call("SendEvent","BattlePveAwardView","RefreshAwardNum", chest.id, self.tbChest[chest.id])
end

function BattleChestDropSystem:GetRandomChest(rate,award_list)
    if not rate or not award_list or TableUtils.IsEmpty(award_list) then
        return
    end
    local num = self:GetRandomNum(0, 1000)
    if num > rate then
        return
    end
    local weights = {}
    local lastTotal = 0
    local total = 0
    for _, award in ipairs(award_list) do
        local itemId = award[1]
        local itemNum = award[2]
        local weight = award[3]
        total = total + weight
        table.insert(weights, {min = lastTotal, max = total, conf = award})
        lastTotal = total
    end
    local result = self:GetRandomNum(0,total-1)
    local target
    for _, data in ipairs(weights) do
        if result >= data.min and result < data.max then
            target = data.conf
            break
        end
    end
    if target then
        return {id = target[1],num = target[2]}
    end
end