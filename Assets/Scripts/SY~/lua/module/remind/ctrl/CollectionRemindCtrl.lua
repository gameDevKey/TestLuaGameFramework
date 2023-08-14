CollectionRemindCtrl = BaseClass("CollectionRemindCtrl",Controller)

function CollectionRemindCtrl:__Init()
    self.initCollection = false
    self.lastCollectionUnits = {}
    self.lastEmbattledUnits = {}
end

function CollectionRemindCtrl:__Delete()
end

function CollectionRemindCtrl:__InitComplete()
end

function CollectionRemindCtrl:CollectionObtainNewCard(info,data,protoId)
    if protoId == 10200 and not self.initCollection then
        self.initCollection = true
        for unitId,v in pairs(mod.CollectionProxy.unitDataDict) do
            self.lastCollectionUnits[unitId] = true
        end
    end

    for unitId,v in pairs(mod.CollectionProxy.unitDataDict) do
        local conf = Config.UnitData.data_unit_info[unitId]
        if not self.lastCollectionUnits[unitId] and conf.type == GDefine.UnitType.hero then
            self.lastCollectionUnits[unitId] = true
            info:SetFlag(true,unitId)
        end
    end
end

--已上阵卡牌可升级
function CollectionRemindCtrl:CollectionEmbattledCardCanUpgrade(info,data,protoId)
    local unitList = mod.CollectionProxy.embattleGroupData[mod.CollectionProxy.curEmbattleGroupIndex]
    for key, flag in pairs(self.lastEmbattledUnits) do
        if flag then
            local isExist = false
            for i, v in ipairs(unitList) do
                if v.unit_id == key then
                    isExist = true
                end
            end
            if not isExist then
                info:SetFlag(false,key)
                self.lastEmbattledUnits[key] = false
            end
        end
    end
    for i, v in ipairs(unitList) do
        local conf = Config.UnitData.data_unit_info[v.unit_id]
        if conf.type == GDefine.UnitType.hero then
            local key = v.unit_id
            local flag = mod.CollectionProxy:CanUnitUpgrade(v.unit_id)
            self.lastEmbattledUnits[key] = flag
            info:SetFlag(flag,key)
        end
    end
end

--未上阵卡牌可升级
function CollectionRemindCtrl:CollectionLibraryCardCanUpgrade(info,data,protoId)
    local unitList = mod.CollectionProxy.obtainedCard
    for i, v in ipairs(unitList) do
        local conf = Config.UnitData.data_unit_info[v.unit_id]
        if conf.type == GDefine.UnitType.hero and not mod.CollectionProxy:IsEmbattled(v.unit_id) then
            local key = v.unit_id
            local flag = mod.CollectionProxy:CanUnitUpgrade(v.unit_id)
            info:SetFlag(flag,key)
        end
    end
end