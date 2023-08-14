PlaceRaceUnitAddBuffBehavior = BaseClass("PlaceRaceUnitAddBuffBehavior",MagicEventBehavior)

function PlaceRaceUnitAddBuffBehavior:__Init()
    self.addBuffEntitys = SECBList.New()
    self.units = {}
end

function PlaceRaceUnitAddBuffBehavior:__Delete()
    self.addBuffEntitys:Delete()
end

function PlaceRaceUnitAddBuffBehavior:OnInit()
    local eventParam = {}
    eventParam.roleUid = self.event.from.roleUid
    self:AddEvent(BattleEvent.create_unit_entity,self:ToFunc("OnCreateUnitEntity"),eventParam)
    self:AddEvent(BattleEvent.remove_unit_entity,self:ToFunc("OnRemoveUnitEntity"),eventParam)

    self:AllEntityAddBuff()
end

function PlaceRaceUnitAddBuffBehavior:AllEntityAddBuff()
    --TODO 替换为根据condID来检索添加buff的单位
    local from = self.event.from
    for v in self.world.EntitySystem.entityList:Items() do
        local uid = v.value
        local entity = self.world.EntitySystem:GetEntity(uid)
        if entity and entity.ObjectDataComponent and from.roleUid == entity.ObjectDataComponent.roleUid 
        and  (not entity.StateComponent or not entity.StateComponent:IsState(BattleDefine.EntityState.die)) then
            local unitType = entity.ObjectDataComponent.unitConf.type
            if unitType == BattleDefine.UnitType.hero or unitType == BattleDefine.UnitType.summon then
                self:ActiveEntityBuff(entity,true)
            end
        end
    end
end

function PlaceRaceUnitAddBuffBehavior:OnCreateUnitEntity(args)
    local entity = self.world.EntitySystem:GetEntity(args.entityUid)
    self:ActiveEntityBuff(entity,true)
end

function PlaceRaceUnitAddBuffBehavior:OnRemoveUnitEntity(args)
    self.addBuffEntitys:RemoveByIndex(args.entityUid)
end

function PlaceRaceUnitAddBuffBehavior:CancelValidEntity()
    for v in self.addBuffEntitys:Items() do
        local uid = v.value
        local entity = self.world.EntitySystem:GetEntity(uid)
        if entity then
            self.addBuffEntitys:RemoveByIndex(uid)
            self:ActiveEntityBuff(entity,false)
        end
    end
end

function PlaceRaceUnitAddBuffBehavior:ActiveEntityBuff(entity,flag)
    if flag then
        -- LogTable(entity.uid.." addBuff",self.event.conf.action_args.buffId)
        for _,buffId in ipairs(self.event.conf.action_args.buffId) do
            entity.BuffComponent:AddBuff(nil,buffId)
        end
        self.addBuffEntitys:Push(entity.uid,entity.uid)
    else
        for _,buffId in ipairs(self.event.conf.action_args.buffId) do
            entity.BuffComponent:RemoveBuffById(buffId)
        end
    end
end

function PlaceRaceUnitAddBuffBehavior:OnDestroy()
    self:CancelValidEntity()
end