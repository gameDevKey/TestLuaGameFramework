BattleEntitySystem = BaseClass("BattleEntitySystem",SECBEntitySystem)
BattleEntitySystem.NAME = "EntitySystem"

function BattleEntitySystem:__Init()
    self.entityRefInfo = {}
    self.magicCardEntitys = {}
end

function BattleEntitySystem:__Delete()
    self:CleanEntitys()
    self.entityRefInfo = {}
end

function BattleEntitySystem:OnInitSystem()

end

function BattleEntitySystem:OnLateInitSystem()
    
end

function BattleEntitySystem:OnPreUpdate()
    self:PreUpdateEntity()
end

function BattleEntitySystem:OnUpdate()
    self:UpdateEntity()
end

function BattleEntitySystem:OnLateUpdate()
    self:LateUpdateEntity()
end

function BattleEntitySystem:OnAddEntity(entity)
    if entity.ObjectDataComponent and entity.ObjectDataComponent.unitConf.type == BattleDefine.UnitType.magic_card then
        if not self.magicCardEntitys[entity.ObjectDataComponent.roleUid] then
            self.magicCardEntitys[entity.ObjectDataComponent.roleUid] = {}
        end
        self.magicCardEntitys[entity.ObjectDataComponent.roleUid][entity.ObjectDataComponent.unitConf.id] = entity
    end

    if entity.ObjectDataComponent then
        self.world.EventTriggerSystem:Trigger(BattleEvent.create_unit_entity,entity)
    end
end

function BattleEntitySystem:GetMagicCardEntity(roleUid,unitId)
    return self.magicCardEntitys[roleUid][unitId]
end

function BattleEntitySystem:OnRemoveEntity(entity)
    if entity.AttrComponent then
        local info = {}
        info.attrs = entity.AttrComponent:GetRefAttr()

        local lastPos = entity.TransformComponent:GetPos()
        info.pos = FPVector3(lastPos.x,lastPos.y,lastPos.z)

        info.unitId = entity.ObjectDataComponent.unitConf.id

        info.roleUid = entity.ObjectDataComponent.roleUid

        info.ownerUid = entity.ownerUid

        self.entityRefInfo[entity.uid] = info
    end

    if entity.ObjectDataComponent then
        self.world.EventTriggerSystem:Trigger(BattleEvent.remove_unit_entity,entity)
    end
end

function BattleEntitySystem:GetRefAttr(uid)
    return self.entityRefInfo[uid].attrs
end

function BattleEntitySystem:GetRefPos(uid)
    return self.entityRefInfo[uid].pos
end

function BattleEntitySystem:GetRefInfo(uid)
    return self.entityRefInfo[uid]
end

function BattleEntitySystem:GetEntityRoleUid(entityUid,isOwner)
    local entity = self:GetEntity(entityUid)
    if entity then
        if not isOwner or not entity.ownerUid then
            return entity.ObjectDataComponent.roleUid
        else
            local ownerEntity = self:GetEntity(entity.ownerUid)
            if ownerEntity then
                return ownerEntity.ObjectDataComponent.roleUid
            else
                local refInfo = self:GetRefInfo(entity.ownerUid)
                return refInfo.roleUid
            end
        end
    else
        local refInfo = self:GetRefInfo(entityUid)
        if not isOwner or not refInfo.ownerUid then
            return refInfo.roleUid
        else
            local ownerEntity = self:GetEntity(refInfo.ownerUid)
            if ownerEntity then
                return ownerEntity.ObjectDataComponent.roleUid
            else
                local refInfo = self:GetRefInfo(entity.ownerUid)
                return refInfo.roleUid
            end
        end
    end
end


function BattleEntitySystem:GetEntityOwnerUid(entityUid)
    local entity = self:GetEntity(entityUid)
    if entity then
        return entity.ownerUid
    else
        local refInfo = self:GetRefInfo(entityUid)
        return refInfo.ownerUid
    end
end

function BattleEntitySystem:GetEntityUnitId(entityUid)
    local entity = self:GetEntity(entityUid)
    if entity then
        return entity.ObjectDataComponent.unitConf.id
    else
        local refInfo = self:GetRefInfo(entityUid)
        return refInfo.unitId
    end
end

function BattleEntitySystem:GetEntityPos(entityUid)
    local entity = self:GetEntity(entityUid)
    if entity then
        return entity.TransformComponent:GetPos()
    else
        local refInfo = self:GetRefInfo(entityUid)
        return refInfo.pos
    end
end

function BattleEntitySystem:GetEntityByCamp(camp,baseId)
    for iter in self.entityList:Items() do
        local uid = iter.value
        local entity = self:GetEntity(uid)

        if entity and entity.ObjectDataComponent then
            local curCamp = entity.CampComponent:GetCamp()
            if curCamp == camp and entity.ObjectDataComponent:GetBaseId() == baseId then
                return entity
            end
        end
    end
    return nil
end

function BattleEntitySystem:GetAllEntityByCamp(camp)
    local entitys = {}
    for iter in self.entityList:Items() do
        local uid = iter.value
        local entity = self:GetEntity(uid)

        if entity and entity.ObjectDataComponent then
            local curCamp = entity.CampComponent:GetCamp()
            if curCamp == camp then
                table.insert(entitys,uid)
            end
        end
    end
    return entitys
end

function BattleEntitySystem:GetEntityNumByCamp(camp)
    local num = 0
    for iter in self.entityList:Items() do
        local uid = iter.value
        local entity = self:GetEntity(uid)

        if entity and entity.ObjectDataComponent and self:HasEntity(uid) 
            and entity.TagComponent.mainTag ~= BattleDefine.EntityTag.home 
            and entity.TagComponent.mainTag ~= BattleDefine.EntityTag.commander  then
            local curCamp = entity.CampComponent:GetCamp()
            if curCamp == camp then
                num = num + 1
            end
        end
    end
    return num
end

function BattleEntitySystem:GetRoleCommander(roleUid)
    for iter in self.entityList:Items() do
        local uid = iter.value
        local entity = self:GetEntity(uid)

        if entity and self:HasEntity(uid) 
            and entity.TagComponent.mainTag == BattleDefine.EntityTag.commander 
            and entity.ObjectDataComponent.roleUid == roleUid then
            return entity
        end
    end
end

function BattleEntitySystem:GetCommanderByCamp(camp)
    for iter in self.entityList:Items() do
        local uid = iter.value
        local entity = self:GetEntity(uid)

        if entity and self:HasEntity(uid) 
            and entity.TagComponent.mainTag == BattleDefine.EntityTag.commander 
            and entity.CampComponent.camp == camp then
            return entity
        end
    end
end

function BattleEntitySystem:GetHeroEntityNum()
    local num = 0
    for iter in self.entityList:Items() do
        local uid = iter.value
        local entity = self:GetEntity(uid)

        if entity and entity.TagComponent.mainTag == BattleDefine.EntityTag.hero 
            and not entity.StateComponent:IsState(BattleDefine.EntityState.die) then
            num = num + 1
        end
    end
    return num
end

function BattleEntitySystem:GetEntityByGroupGrid(camp,group,grids)
    local entitys = {}
    for iter in self.entityList:Items() do
        local uid = iter.value
        local entity = self:GetEntity(uid)
        if entity and entity.CampComponent:GetCamp() == camp and entity.ObjectDataComponent then
            if entity.ObjectDataComponent.group and entity.ObjectDataComponent.group == group
                and entity.ObjectDataComponent.grid and grids[entity.ObjectDataComponent.grid] then
                table.insert(entitys,uid)
            end
        end
    end
    return entitys
end

function BattleEntitySystem:GetRoleEntitys(roleUid,unitId)
    local entitys = {}
    for iter in self.entityList:Items() do
        local uid = iter.value
        local entity = self:GetEntity(uid)
        if entity.ObjectDataComponent and entity.ObjectDataComponent.roleUid == roleUid
            and entity.ObjectDataComponent.unitConf.id == unitId then
            table.insert(entitys,uid)
        end
    end
    return entitys
end