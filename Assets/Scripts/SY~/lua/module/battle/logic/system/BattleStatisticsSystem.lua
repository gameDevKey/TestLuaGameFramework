BattleStatisticsSystem = BaseClass("BattleStatisticsSystem",SECBEntitySystem)

function BattleStatisticsSystem:__Init()
    self.roleInfos = {}
    self.heroOutputRefresh = false
    self.heroOutputUpdateIdx = {}
end

function BattleStatisticsSystem:__Delete()

end

function BattleStatisticsSystem:OnInitSystem()

end

function BattleStatisticsSystem:OnLateInitSystem()

end

function BattleStatisticsSystem:GetInfo(roleUid)
    return self.roleInfos[roleUid]
end

function BattleStatisticsSystem:AddUnitOutput(roleUid,unitId,value,valueType)
    local roleInfo = self.roleInfos[roleUid] or self:CreateRoleInfo(roleUid)

    if not roleUid or not unitId then
        assert(false,string.format("添加了未知的输出信息[玩家Id:%s][单位Id:nil]",tostring(roleUid),tostring(unitId)))
    end

    local outputInfo = roleInfo.outputInfos[unitId]
    if not outputInfo then
        outputInfo = {}
        outputInfo.unitId = unitId
        outputInfo.maxVal = 0
        outputInfo.maxValueType = BattleDefine.OutputType.atk
        outputInfo.valueList = {
            [BattleDefine.OutputType.atk] = { value = 0,valueType = BattleDefine.OutputType.atk},
            [BattleDefine.OutputType.heal] = { value = 0,valueType = BattleDefine.OutputType.heal},
            [BattleDefine.OutputType.def] = { value = 0,valueType = BattleDefine.OutputType.def},
        }
        roleInfo.output = outputInfo
        table.insert(roleInfo.outputInfoList,outputInfo)
        roleInfo.outputInfos[unitId] = outputInfo
    end

    if not roleInfo.outputMaxVals[valueType] then
        roleInfo.outputMaxVals[valueType] = 0
    end
    roleInfo.outputMaxVals[valueType] = roleInfo.outputMaxVals[valueType] + value

    outputInfo.valueList[valueType].value = outputInfo.valueList[valueType].value + value
    for k, v in pairs(outputInfo.valueList) do
        if v.value > outputInfo.maxVal then
            outputInfo.maxVal = v.value
            outputInfo.maxValueType = v.valueType
        end
    end

    if roleUid == self.world.BattleDataSystem.roleUid then
        if not self.heroOutputUpdateIdx[valueType] then
            self.heroOutputUpdateIdx[valueType] = 0
        end
        self.heroOutputUpdateIdx[valueType] = self.heroOutputUpdateIdx[valueType] + 1
        self.heroOutputRefresh = true
    end
end

function BattleStatisticsSystem:SortHeroOutputByType(tpe)
    local statisticsInfo = self.roleInfos[self.world.BattleDataSystem.roleUid]
    table.sort(statisticsInfo.outputInfoList,function (a,b)
        return a.valueList[tpe].value > b.valueList[tpe].value
    end)
end

function BattleStatisticsSystem:SortHeroOutput()
    local statisticsInfo = self.roleInfos[self.world.BattleDataSystem.roleUid]
    table.sort(statisticsInfo.outputInfoList,self:ToFunc("SortHeroOutputRule"))
    self.heroOutputRefresh = false
end

function BattleStatisticsSystem:SortHeroOutputRule(a,b)
    return a.maxVal > b.maxVal
end


function BattleStatisticsSystem:SortOutputByAtk()
    for roleUid,v in pairs(self.roleInfos) do
        table.sort(v.outputInfoList,self:ToFunc("SortOutputRuleByAtk"))
    end
end

function BattleStatisticsSystem:SortOutputByTotal()
    for roleUid,v in pairs(self.roleInfos) do
        table.sort(v.outputInfoList,self:ToFunc("SortOutputRuleByTotal"))
    end
end

function BattleStatisticsSystem:SortOutputRuleByAtk(a,b)
    return a.valueList[BattleDefine.OutputType.atk].value > b.valueList[BattleDefine.OutputType.atk].value
end

function BattleStatisticsSystem:SortOutputRuleByTotal(a,b)
    local aTotal = a.valueList[BattleDefine.OutputType.atk].value
    aTotal = aTotal + a.valueList[BattleDefine.OutputType.heal].value
    aTotal = aTotal + a.valueList[BattleDefine.OutputType.def].value

    local bTotal = b.valueList[BattleDefine.OutputType.atk].value
    bTotal = bTotal + b.valueList[BattleDefine.OutputType.heal].value
    bTotal = bTotal + b.valueList[BattleDefine.OutputType.def].value

    return aTotal > bTotal
end



function BattleStatisticsSystem:AddMoney(roleUid,money)
    local roleInfo = self.roleInfos[roleUid] or self:CreateRoleInfo(roleUid)
    roleInfo.money = roleInfo.money + money
end

function BattleStatisticsSystem:CreateRoleInfo(roleUid)
    local roleInfo = {}
    roleInfo.outputInfos = {}
    roleInfo.outputInfoList = {}
    roleInfo.outputMaxVals = {}
    roleInfo.money = 0
    self.roleInfos[roleUid] = roleInfo
    return roleInfo
end