EntityEventTrigger = BaseClass("EntityEventTrigger",SECBEventTrigger)

function EntityEventTrigger:__Init()

end

function EntityEventTrigger:__Delete()
    
end

function EntityEventTrigger:OnRegister()
    self:AddHandler(BattleEvent.create_unit_entity,self:ToFunc("CreateUnitEntity"))
    self:AddHandler(BattleEvent.remove_unit_entity,self:ToFunc("RemoveUnitEntity"))
    self:AddHandler(BattleEvent.enter_camp_area,self:ToFunc("EnterCampArea"))
    self:AddHandler(BattleEvent.priority_select_unit,self:ToFunc("PrioritySelectUnit"))
    self:AddHandler(BattleEvent.do_control,self:ToFunc("DoControl"))

    
end


function EntityEventTrigger:CreateUnitEntity(listeners,entity)
    local params = {}
    params.roleUid = entity.ObjectDataComponent.roleUid
    params.entityUid = entity.uid
    params.unitId = entity.ObjectDataComponent.unitConf.unit_id

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckStr(args,false,"roleUid",params.roleUid) then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function EntityEventTrigger:RemoveUnitEntity(listeners,entity)
    local params = {}
    params.roleUid = entity.ObjectDataComponent.roleUid
    params.entityUid = entity.uid
    params.unitId = entity.ObjectDataComponent.unitConf.unit_id

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckStr(args,false,"roleUid",params.roleUid) then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function EntityEventTrigger:EnterCampArea(listeners,entityUid,areaCamp,unitCamp)
    local entity = self.world.EntitySystem:GetEntity(entityUid)
    local roleUid = entity.ObjectDataComponent.roleUid

    local params = {}
    params.fromEntityUid = entityUid
    params.areaCamp = areaCamp

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckStr(args,false,"roleUid",roleUid) 
            and self:CheckNum(args,false,"areaCamp",areaCamp)
            and self:CheckNum(args,false,"camp",unitCamp) then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function EntityEventTrigger:PrioritySelectUnit(listeners,entityUid,entityDict)
    local params = {}
    params.entityDict = entityDict
    local firstEntity = nil
    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args, true, "entityUid", entityUid) then
            local toSelectEntityUid = iter.value.callBack(params,iter.value.uid)
            if toSelectEntityUid then
                firstEntity = toSelectEntityUid
            end
        end
    end
    return firstEntity
end

function EntityEventTrigger:DoControl(listeners,entityUid)
    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args, true, "entityUid", entityUid) then
            iter.value.callBack(nil,iter.value.uid)
        end
    end
end