UnitGridEventTrigger = BaseClass("UnitGridEventTrigger",SECBEventTrigger)

function UnitGridEventTrigger:__Init()

end

function UnitGridEventTrigger:__Delete()
    
end

function UnitGridEventTrigger:OnRegister()
    self:AddHandler(BattleEvent.place_unit,self:ToFunc("PlaceUnit"))
    self:AddHandler(BattleEvent.update_unit,self:ToFunc("UpdateUnit"))
    self:AddHandler(BattleEvent.cancel_unit,self:ToFunc("CancelUnit"))
    self:AddHandler(BattleEvent.sell_hero,self:ToFunc("SellHero"))
end

function UnitGridEventTrigger:PlaceUnit(listeners,roleUid,camp,unitId,grid)
    local conf = self.world.BattleConfSystem:UnitData_data_unit_info(unitId)

    local params = {}
    params.roleUid = roleUid
    params.camp = camp
    params.unitId = unitId
    params.grid = grid

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckStr(args,false,"roleUid",roleUid) 
            and self:CheckNum(args,false,"raceType",conf.race_type)
            and self:CheckNum(args,false,"camp",camp)
            and self:CheckItemInList(args,false,"raceTypeList",conf.race_type) then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function UnitGridEventTrigger:UpdateUnit(listeners,roleUid,camp,unitId,grid)
    local conf = self.world.BattleConfSystem:UnitData_data_unit_info(unitId)

    local params = {}
    params.roleUid = roleUid
    params.camp = camp
    params.unitId = unitId
    params.grid = grid

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckStr(args,false,"roleUid",roleUid) 
            and self:CheckNum(args,false,"raceType",conf.race_type) 
            and self:CheckNum(args,false,"camp",camp)
            and self:CheckItemInList(args,false,"raceTypeList",conf.race_type) then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function UnitGridEventTrigger:CancelUnit(listeners,roleUid,camp,unitId,grid)
    local conf = self.world.BattleConfSystem:UnitData_data_unit_info(unitId)

    local params = {}
    params.roleUid = roleUid
    params.camp = camp
    params.unitId = unitId
    params.grid = grid

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckStr(args,false,"roleUid",roleUid) 
            and self:CheckNum(args,false,"raceType",conf.race_type)
            and self:CheckNum(args,false,"camp",camp)
            and self:CheckItemInList(args,false,"raceTypeList",conf.race_type) then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function UnitGridEventTrigger:SellHero(listeners,roleUid,unitId)
    local params = {}
    params.roleUid = roleUid
    params.unitId = unitId

    for iter in listeners:Items() do
        local args = iter.value.args

        if self:CheckStr(args,false,"roleUid",roleUid) 
            and self:CheckNum(args,false,"unitId",unitId) then
            local toChangeMoney = iter.value.callBack(params,iter.value.uid)
            return toChangeMoney
        end
    end
end