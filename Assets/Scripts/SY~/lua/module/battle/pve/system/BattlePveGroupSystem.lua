BattlePveGroupSystem = BaseClass("BattlePveGroupSystem",SECBEntitySystem)
BattlePveGroupSystem.NAME = "BattleGroupSystem"

function BattlePveGroupSystem:__Init()
end

function BattlePveGroupSystem:__Delete()
end

function BattlePveGroupSystem:InitGroup(pveId)
    LogYqh("初始化出怪系统 pveId",pveId)
    self.totalTimer = 0                 --总时长
    self.groupTimer = 0                 --每波时长
    self.genTimer = 0                   --每次出兵时长
    self.killCounter = 0                --击杀数量
    self.existCounter = 0               --存活数量
    self.currentGroup = 0               --当前波数
    self.totalGen = 0                   --总生成个数
    self.genRecord = {}                 --本波生成怪物个数
    self.roadRandomRecord = {}          --控制怪物在每条路上的分布随机尽可能平均
    self.isSpeicalTipsShowing = false   --特殊提示是否正在显示，显示时不生成怪物
    self.isWaitForSkillSelect = false
    self.pveId = pveId
    self.conf = self.world.BattleConfSystem:PveData_data_pve(pveId)
    self.maxGroup = self.conf.max_group
end

function BattlePveGroupSystem:OnLateInitSystem()
    self.world.EventTriggerSystem:AddListener(BattleEvent.unit_die,self:ToFunc("OnKillUnit"))
    self.world.EventTriggerSystem:AddListener(BattleEvent.begin_logic_running, self:ToFunc("OnLogicBegin"))
    self.world.EventTriggerSystem:AddListener(BattleEvent.pve_select_item_begin, self:ToFunc("OnPveSelectItemBegin"))
    self.world.EventTriggerSystem:AddListener(BattleEvent.pve_select_item, self:ToFunc("OnPveSelectItem"))
end

function BattlePveGroupSystem:GetAllMonsterConfInfo(groupId)
    return self.world.BattleConfSystem:PveData_data_pve_monsters(groupId)
end

function BattlePveGroupSystem:GetGroupConfInfo(group)
    return self.world.BattleConfSystem:PveData_data_pve_group(self.pveId,group)
end

function BattlePveGroupSystem:GetMonsterConfInfo(group, unitId)
    return self.world.BattleConfSystem:PveData_data_pve_monster(group, unitId)
end

function BattlePveGroupSystem:UpdateAllTimer()
    local deltaTime = self.world.opts.frameDeltaTime
    self.totalTimer = self.totalTimer + deltaTime
    if not self.isWaitForSkillSelect and not self.isSpeicalTipsShowing then --非三选一且非等待tips结束才能推进波数和怪物生成
        self.groupTimer = self.groupTimer + deltaTime
        self.genTimer = self.genTimer + deltaTime
    end

    self.world.ClientIFacdeSystem:Call("SendEvent",BattlePveInfoView.Event.RefreshTimeShow, self.totalTimer)
end

function BattlePveGroupSystem:TryGenUnit()
    if not self.groupConf then
        return
    end
    -- if self.existCounter > self.groupConf.max_exist then
    --     return
    -- end
    -- local totalGen = 0
    -- for _, num in pairs(self.genRecord) do
    --     totalGen = totalGen + num
    -- end
    -- if totalGen > self.groupConf.max_gen then
    --     return
    -- end
    if self.genTimer > self.groupConf.gen_delta then
        self.genTimer = 0
        self:GenUnitEntitys()
    end
end

function BattlePveGroupSystem:GetRandomNum(min,max)
    return self.world.BattleRandomSystem:Random(min,max)
end

function BattlePveGroupSystem:GetUnitArrtList(attrList)
    local result = {}
    for _, data in ipairs(attrList) do
        local item = {}
        item.attr_id = GDefine.AttrNameToId[data[1]]
        assert(item.attr_id, string.format("非法属性[%s]",tostring(data[1])))
        item.attr_val = data[2] or 0
        table.insert(result, item)
    end
    return result
end

function BattlePveGroupSystem:GetUnitSkillList(unitId,lv)
    local conf = self.world.BattleConfSystem:UnitData_data_unit_lev_info(unitId,lv)
    assert(conf, string.format("无法找到单位等级数据[UnitId=%s][Lv=%s]",tostring(unitId),tostring(lv)))
    local list = conf.skill_list
    local result = {}
    for _, data in ipairs(list) do
        local item = {}
        item.skill_id = data[1]
        item.skill_level = data[2]
        table.insert(result, item)
    end
    return result
end

function BattlePveGroupSystem:PackUnitData(monsterConf)
    local data = {}
    data.attr_list = self:GetUnitArrtList(monsterConf.attr_list)
    data.grid_id = 1
    data.skill_list = self:GetUnitSkillList(monsterConf.unit_id,monsterConf.level)
    data.star = monsterConf.star
    data.unit_id = monsterConf.unit_id
    data.monsterConf = monsterConf
    return data
end

function BattlePveGroupSystem:ResetRoadRandomRecord()
    self.roadRandomRecord = {}
end

function BattlePveGroupSystem:GetRandomRoadIndex(min, max)
    local originWeight = 100    --初始权重
    local offset = 60           --衰减
    local weights = {}
    local total = 0
    local lastTotal = 0
    for i = min, max do
        if not self.roadRandomRecord[i] or self.roadRandomRecord[i] < 0 then
            self.roadRandomRecord[i] = originWeight
        end
        total = total + self.roadRandomRecord[i]
        table.insert(weights,{min = lastTotal,max = total,index = i})
        lastTotal = total
    end
    local result = self:GetRandomNum(0, total-1)
    local index = 1
    for _, w in ipairs(weights) do
        if result >= w.min and result < w.max then
            index = w.index
            break
        end
    end
    self.roadRandomRecord[index] = self.roadRandomRecord[index] - offset
    return index
end

--[[
    posType：位置类型，0为随机位置，1为固定哪条路
    roleIndex：当posType为1时，配置此项代表哪条路(1/2/3)，-1代表随机一条路
]]--
function BattlePveGroupSystem:GetUnitRandomGenPos(posType, roleIndex, offsetPos)
    local pos
    if posType == 0 then
        local leftPos = self.world.BattleMixedSystem:GetStancePos(BattleDefine.Camp.attack,  2)
        local rightPos = self.world.BattleMixedSystem:GetStancePos(BattleDefine.Camp.defence, 9)
        local x = self:GetRandomNum(leftPos.x, rightPos.x)
        local z = self:GetRandomNum(leftPos.z, rightPos.z)
        pos = Vector3(x, leftPos.y, z)
    else
        if roleIndex <= 0 then
            roleIndex = self:GetRandomRoadIndex(1,3)
        end
        pos = self.world.BattleMixedSystem:GetStancePos(BattleDefine.Camp.attack,roleIndex+1) --第1/2/3路其实是2/3/4
    end
    if not TableUtils.IsEmpty(offsetPos) then
        local offsetX = 0
        local offsetZ = 0
        if not TableUtils.IsEmpty(offsetPos[1]) then
            offsetX = self:GetRandomNum(offsetPos[1][1],offsetPos[1][2])
        end
        if not TableUtils.IsEmpty(offsetPos[2]) then
            offsetZ = self:GetRandomNum(offsetPos[2][1],offsetPos[2][2])
        end
        pos = Vector3(pos.x + offsetX, pos.y, pos.z + offsetZ)
    end
    return pos
end

function BattlePveGroupSystem:GetWeightMap(monsterConfs)
    local weights = {}
    local total = 0
    local lastTotal = 0
    for _, conf in ipairs(monsterConfs) do
        local id = conf.unit_id
        if not self.genRecord[id] then self.genRecord[id] = 0 end
        if self.genRecord[id] <= conf.max_gen then
            total = total + conf.weight
            table.insert(weights,{min = lastTotal,max = total,conf = conf})
            -- LogYqh("权重计算 unitId,min,max",conf.unit_id, lastTotal,total)
            lastTotal = total
        end
    end
    return weights,total
end

function BattlePveGroupSystem:GetUnitRandomData(groupId,limitNum)
    local list = {}
    local monsters = self:GetAllMonsterConfInfo(groupId)
    local weights,total = self:GetWeightMap(monsters)
    local genMap = {}
    for i = 1, limitNum do
        if total <= 0 then
            break
        end
        local result = self:GetRandomNum(0,total-1)
        -- LogYqh("随机结果",result,"范围：[ 0,",total-1,"]")
        local target
        for _, data in ipairs(weights) do
            if result >= data.min and result < data.max then
                target = data.conf
                break
            end
        end
        if target then
            local id = target.unit_id
            local find = false
            for _, genData in ipairs(genMap) do
                if genData.conf.unit_id == id then
                    genData.count = genData.count + 1
                    find = true
                    break
                end
            end
            if not find then
                table.insert(genMap, {count = 1, conf = target})
            end
            if not self.genRecord[id] then self.genRecord[id] = 0 end
            self.genRecord[id] = self.genRecord[id] + 1
            if self.genRecord[id] > target.max_gen then
                --本波生成该怪物的数量达到了上限，移出随机范围
                LogYqh("本波生成该怪物的数量达到了上限，移出随机范围", id)
                weights,total = self:GetWeightMap(monsters)
            end
        end
    end
    for _, data in ipairs(genMap) do
        local unitData = self:PackUnitData(data.conf)
        table.insert(list,{unit_id = data.conf.unit_id, num = data.count, unitData = unitData})
    end
    return list
end

function BattlePveGroupSystem:CalcPerGenNum()
    local max = self.groupConf.max_exist - self.existCounter
    if max <= 0 then
        return 0
    end
    local hasGen = 0
    for id, num in pairs(self.genRecord) do
        hasGen = hasGen + num
    end
    local canGen = math.min((self.groupConf.max_gen - hasGen), max)
    local gen = math.min(canGen, self.groupConf.per_gen)
    LogYqh(string.format("本次生成数量 group:%d (maxExist:%d   exist:%d  hasGen:%d  maxGen:%d  perGen:%d) = gen:%d",
            self.currentGroup,self.groupConf.max_exist,self.existCounter,hasGen,self.groupConf.max_gen,self.groupConf.per_gen,gen))
    return math.max(0, gen)

    -- local max_amount = math.min(self.groupConf.max_gen, self.groupConf.max_exist)
    -- local can_gen = math.abs(max_amount - self.existCounter)
    -- local min = math.min(can_gen, self.groupConf.per_gen)
    -- return math.max(0, min)
end

function BattlePveGroupSystem:GenUnitEntitys()
    if not self.groupConf then
        return
    end
    local want_amount = self:CalcPerGenNum()
    if want_amount == 0 then
        -- LogYqh("无法生成怪物, 数量被限制 group,maxExist,exist,maxGen,perGen",
        --     self.currentGroup,self.groupConf.max_exist,self.existCounter,self.groupConf.max_gen,self.groupConf.per_gen)
        return
    end
    LogYqh("尝试生成怪物 want_amount,rules",want_amount,self.groupConf.gen_rules)
    self:ResetRoadRandomRecord()
    local offsetPos = self.groupConf.offset_pos
    for _, rule in ipairs(self.groupConf.gen_rules) do
        local groupId = rule[1] --怪物组id
        local posType = rule[2]
        local roleIndex = rule[3]
        local units = self:GetUnitRandomData(groupId,want_amount)
        LogYqh("随机生成怪物 group,want_amount,rule",self.currentGroup,want_amount,rule)
        for _, unit in ipairs(units) do
            local unitId = unit.unit_id
            local num = unit.num
            local unitData = unit.unitData
            local pos = self:GetUnitRandomGenPos(posType, roleIndex, offsetPos)
            LogYqh("生成怪物 group,id,num,pos",self.currentGroup,unitId,num,pos)
            self.existCounter = self.existCounter + num
            self.totalGen = self.totalGen + num
            for i = 1, num do
                local entity = self.world.BattleEntityCreateSystem:CreatePveUnitEntity(unitId, unitData, pos, self.currentGroup)
                entity.CollistionComponent:SetEnable(false)

                local walkType = entity.ObjectDataComponent:GetWalkType()
                if walkType == BattleDefine.WalkType.floor then
                    entity.AIComponent:AddAI(1005)
                elseif walkType == BattleDefine.WalkType.fly then
                    entity.AIComponent:AddAI(1002)
                end

                local entityPos = entity.TransformComponent:GetPos()
                self.world.ClientIFacdeSystem:Call("SendEvent",BattleMixedEffectView.Event.PlayUnitBornEffect,entityPos)
            end
        end
        want_amount = self:CalcPerGenNum()
    end
    LogYqh("当前存在单位个数",self.existCounter)
end

function BattlePveGroupSystem:NextGroup()
    self.genRecord = {}
    self.groupTimer = 0
    self.genTimer = 0
    self.killCounter = 0
    self.currentGroup = self.currentGroup + 1
    self.groupConf = self:GetGroupConfInfo(self.currentGroup)
    self.isSpeicalTipsShowing = false

    LogYqh("进入下一波",self.currentGroup,"/",self.maxGroup)

    self:InvokeEvents()
    self:TryShowSpecialTips()
end

function BattlePveGroupSystem:InvokeEvents()
    self.world.EventTriggerSystem:Trigger(BattleEvent.enter_round, self.currentGroup)
    self.world.ClientIFacdeSystem:Call("SendEvent",BattlePveInfoView.Event.RefreshGroupShow, self.currentGroup, self.maxGroup)
    self.world.ClientIFacdeSystem:Call("SendGuideEvent",PlayerGuideDefine.Event.on_pve_group_begin, self.pveId, self.currentGroup)
end

function BattlePveGroupSystem:OnPveSelectItemBegin()
    self.isWaitForSkillSelect = true
end

function BattlePveGroupSystem:OnPveSelectItem(index)
    if self.isWaitForSkillSelect then
        self.isWaitForSkillSelect = false
        self:TryShowSpecialTips()
    end
end

function BattlePveGroupSystem:TryShowSpecialTips()
    local tipsData = self.groupConf and self.groupConf.group_type
    LogYqh("尝试显示特殊提示",tipsData,"是否正在等待选择",self.isWaitForSkillSelect)
    if self.isWaitForSkillSelect then
        return
    end
    if not TableUtils.IsEmpty(tipsData) then
        local tpe = tipsData[1]
        local time = tipsData[2] / 1000
        local content = tipsData[3]
        self:ShowSpecialTips(tpe,time,content)
    end
end

function BattlePveGroupSystem:ShowSpecialTips(tipsType,time,content)
    LogYqh("显示特殊提示",tipsType,time,content)
    self.isSpeicalTipsShowing = true

    local effectId

    if tipsType == 1 then
        effectId = 10037
    elseif tipsType == 2 then
        effectId = 10038
    elseif tipsType == 3 then
        effectId = 10039
    end

    self.world.ClientIFacdeSystem:Call("SendEvent",PveMixedEffectView.Event.PlayUIEffect,
        effectId,self:ToFunc("OnShowSpecialTipsFinish"))
end

function BattlePveGroupSystem:OnShowSpecialTipsFinish()
    LogYqh("显示特殊提示结束")
    self.isSpeicalTipsShowing = false
end

function BattlePveGroupSystem:CheckGroupTimeOver()
    if not self.groupConf then
        return
    end
    if self.groupConf.max_time == 0 then
        return
    end
    if self.groupTimer >= self.groupConf.max_time and self.currentGroup <= self.maxGroup then
        LogYqh("本轮持续时间结束，进入下一轮")
        self:NextGroup()
    end
end

--判定是否跑完了所有波数
--达到本回合所需击杀数或者最后一波的时间结束了，就会出现 currentGroup > maxGroup
function BattlePveGroupSystem:IsFinishAllGroup()
    return self.currentGroup > self.maxGroup
end

function BattlePveGroupSystem:OnKillUnit(args)
    local entity = self.world.EntitySystem:GetEntity(args.dieEntityUid)
    local camp = entity.CampComponent:GetCamp()
    local unitId = entity.ObjectDataComponent.unitConf.id

    if camp == BattleDefine.Camp.attack and entity.ownerUid ~= nil then
        -- 被召唤出来的敌方单位
        return
    end

    if camp == BattleDefine.Camp.defence then
        if entity.BuffComponent:HasBuffState(BattleDefine.BuffState.reverse_camp) then
            -- 被策反的敌方单位
        else
            -- 防守方单位
            return
        end
    end

    self.killCounter = self.killCounter + 1
    self.existCounter = self.existCounter - 1

    LogYqh("击杀数",self.killCounter,"击杀单位",unitId,"存活数",self.existCounter)

    if self.groupConf and self.killCounter >= self.groupConf.need_kill then    --本回合击杀数量满足击杀数量的要求，进入下一轮
        LogYqh("本回合击杀数量满足击杀数量的要求，进入下一轮")
        self:NextGroup()
    elseif self.existCounter == 0 and self.currentGroup == self.maxGroup then   --最终回合击杀了所有怪物，进入下一轮(游戏结束)
        LogYqh("最终回合击杀了所有怪物，进入下一轮(游戏结束)")
        self:NextGroup()
    end

    if self.existCounter < 0 then
        assert(false, "统计存活数有误")
    end
end

function BattlePveGroupSystem:OnLogicBegin()
    LogYqh("游戏开始，进入下一轮")
    self:NextGroup()
end

function BattlePveGroupSystem:OnUpdate()
    self:UpdateAllTimer()
    self:CheckGroupTimeOver()
    self:TryGenUnit()
end