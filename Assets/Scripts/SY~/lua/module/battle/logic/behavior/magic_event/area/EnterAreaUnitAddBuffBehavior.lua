EnterAreaUnitAddBuffBehavior = BaseClass("EnterAreaUnitAddBuffBehavior",MagicEventBehavior)

function EnterAreaUnitAddBuffBehavior:__Init()
    self.areaCamp = nil
    self.addBuffEntitys = SECBList.New()
end

function EnterAreaUnitAddBuffBehavior:__Delete()
    self.addBuffEntitys:Delete()
end

function EnterAreaUnitAddBuffBehavior:OnInit()
    if self.event.conf.action_args.areaFrom == 1 then
        self.areaCamp = self.event.from.camp
    elseif self.event.conf.action_args.areaFrom == -1 then
        self.areaCamp = CampComponent.GetEnemyCampByCamp(self.event.from.camp)
    end

    local unitCamp = nil
    if self.event.conf.action_args.campFrom == 1 then
        unitCamp = self.event.from.camp
    elseif self.event.conf.action_args.campFrom == -1 then
        unitCamp = CampComponent.GetEnemyCampByCamp(self.event.from.camp)
    end

    local eventParam = {}
    eventParam.roleUid = self.event.from.roleUid
    eventParam.areaCamp = 0
    eventParam.camp = unitCamp
    self:AddEvent(BattleEvent.enter_camp_area,self:ToFunc("OnEnterCampArea"),eventParam)


    local eventParam = {}
    eventParam.roleUid = self.event.from.roleUid
    self:AddEvent(BattleEvent.remove_unit_entity,self:ToFunc("OnRemoveUnitEntity"),eventParam)

    self:AllEntityAddBuff()
end

function EnterAreaUnitAddBuffBehavior:OnEnterCampArea(args)
    local entity = self.world.EntitySystem:GetEntity(args.fromEntityUid)
    if args.areaCamp == self.areaCamp then
        self:ActiveEntityBuff(entity,true)
    else
        self:ActiveEntityBuff(entity,false)
        self.addBuffEntitys:RemoveByIndex(args.fromEntityUid)
    end
end

function EnterAreaUnitAddBuffBehavior:OnRemoveUnitEntity(args)
    self.addBuffEntitys:RemoveByIndex(args.entityUid)
end

function EnterAreaUnitAddBuffBehavior:AllEntityAddBuff()
    local from = self.event.from
    for v in self.world.EntitySystem.entityList:Items() do
        local uid = v.value
        local entity = self.world.EntitySystem:GetEntity(uid)
        if entity and entity.AreaComponent 
            and entity.AreaComponent.areaCamp == self.areaCamp
            and (not entity.StateComponent or not entity.StateComponent:IsState(BattleDefine.EntityState.die)) then
            self:ActiveEntityBuff(entity,true)
        end
    end
end

function EnterAreaUnitAddBuffBehavior:CancelValidEntity()
    for v in self.addBuffEntitys:Items() do
        local uid = v.value
        local entity = self.world.EntitySystem:GetEntity(uid)
        if entity then
            self.addBuffEntitys:RemoveByIndex(uid)
            self:ActiveEntityBuff(entity,false)
        end
    end
end

function EnterAreaUnitAddBuffBehavior:ActiveEntityBuff(entity,flag)
    if flag then
        for _,buffId in ipairs(self.event.conf.action_args.buffId) do
            if not entity.BuffComponent:HasBuffId() then
                entity.BuffComponent:AddBuff(nil,buffId)
                self.addBuffEntitys:Push(entity.uid,entity.uid)
            end
        end
    else
        for _,buffId in ipairs(self.event.conf.action_args.buffId) do
            entity.BuffComponent:RemoveBuffById(buffId)
        end
    end
end

function EnterAreaUnitAddBuffBehavior:OnDestroy()
    self:CancelValidEntity()
end