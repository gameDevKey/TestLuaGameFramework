SkillHitTargetCostEnergyCond = BaseClass("SkillHitTargetCostEnergyCond",PassiveCondBase)

function SkillHitTargetCostEnergyCond:__Init()
    self.records = {}
    self.recordsDict = {}
end

function SkillHitTargetCostEnergyCond:OnInit()
	local eventParam = {}
	eventParam.entityUid = self.passive.entity.uid
    self:AddEvent(BattleEvent.skill_hit,self:ToFunc("OnSkillHit"),eventParam)

    -- LogYqh("SkillHitTargetCostEnergyCond 绑定触发器", self.passive.entity.uid)
end

function SkillHitTargetCostEnergyCond:OnSkillHit(param)
    local key = param.skillId .. "_" .. param.relUid

    if not self.recordsDict[key] then
        local data = {}
        data.key = key
        data.frame = self.world.frame
        data.param = param
        data.dmgVal = 0
        data.energy = 0
        table.insert(self.records,data)
        self.recordsDict[key] = data
    end

    local info = self.recordsDict[key]

    if param.hitType == BattleDefine.HitType.energy and param.resultVal < 0 then --能量增加不考虑
        info.energy = info.energy + math.abs(param.resultVal)
    elseif param.hitType == BattleDefine.HitType.dmg then
        info.dmgVal = info.dmgVal + math.abs(param.resultVal)
    end

    -- LogYqh("SkillHitTargetCostEnergyCond ",self.passive.entity.uid,"命中", param.skillId,'[',param.relUid,'] 累计能量', info.energy , '累计伤害', info.dmgVal, "参数", param)
end

function SkillHitTargetCostEnergyCond:OnUpdate()
    local curFrame = self.world.frame
    local removeIndex = {}
    for i, data in ipairs(self.records) do
        if curFrame ~= data.frame then --下一帧清空
            if data.energy > 0 and data.dmgVal > 0 then
                -- LogYqh("SkillHitTargetCostEnergyCond 触发", self.passive.entity.uid)
                local param = {}
                param.calcNum = data.energy
                param.calcVal = data.dmgVal
                param.fromEntityUid = data.param.fromEntityUid
                param.targetEntityUids = data.param.targetEntityUids
                self:TriggerCond(param)
            end
            table.insert(removeIndex, i)
        end
    end
    for i = #removeIndex, 1, -1 do
        local index = removeIndex[i]
        local data = self.records[index]
        self.recordsDict[data.key] = nil
        table.remove(self.records, index)
    end
end
