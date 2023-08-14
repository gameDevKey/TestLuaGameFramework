TransportBehavior = BaseClass("TransportBehavior",SkillBehavior)

function TransportBehavior:__Init()
    self.ctrlEntitys = {}
    self.eventUid = nil
    self.levParam = nil
end

function TransportBehavior:__Delete()
    if self.eventUid then
        self.world.EventTriggerSystem:RemoveListener(self.eventUid)
        self.eventUid = nil
    end
end

function TransportBehavior:OnInit()
    self.skill:AddRefNum(1)

    local ownerEntity = self.world.EntitySystem:GetEntity(self.entity.ownerUid)
    local ownerPos = ownerEntity.TransformComponent:GetPos()

    self.levParam = self.actionParam.params[self.skill.skillLev] or self.actionParam.params[0]

    local grids = self.world.BattleMixedSystem:GetGridDictByOffset(ownerEntity.ObjectDataComponent.grid,self.levParam.offsetGrids)

    local entitys = self.world.EntitySystem:GetEntityByGroupGrid(self.entity.CampComponent:GetCamp(),ownerEntity.ObjectDataComponent.group,grids)

    for i,entityUid in ipairs(entitys) do
        local targetEntity = self.world.EntitySystem:GetEntity(entityUid)
        if targetEntity.ObjectDataComponent:IsSameWalkType(BattleDefine.WalkType.floor) 
            and targetEntity.CollistionComponent.mass < ownerEntity.CollistionComponent.mass then
            targetEntity:SetEnable(false)
            targetEntity.MoveComponent:StopMove()
            self.world.ClientIFacdeSystem:Call("ActiveEntity",entityUid,false)
            self.hpBarHideUid = self.world.ClientIFacdeSystem:Call("ForceHideHPByLock",entityUid)

            local targetPos = targetEntity.TransformComponent:GetPos()
            local offsetPos = {x = targetPos.x - ownerPos.x,z = targetPos.z - ownerPos.z}
            table.insert(self.ctrlEntitys,{entityUid = entityUid,offsetPos = offsetPos})
        end
    end

    local eventArgs = {}
    eventArgs.entityUid = self.entity.ownerUid
    self.eventUid = self.world.EventTriggerSystem:AddListener(BattleEvent.unit_ready_die,self:ToFunc("OwnerReadyDie"),eventArgs)
end


function TransportBehavior:OnUpdate()

end


function TransportBehavior:OwnerReadyDie(params)
    local ownerEntity = self.world.EntitySystem:GetEntity(self.entity.ownerUid)
    local ownerPos = ownerEntity.TransformComponent:GetPos()
    local ownerForward = ownerEntity.TransformComponent:GetForward()

    local num = #self.ctrlEntitys
    for i,v in ipairs(self.ctrlEntitys) do
        local targetEntity = self.world.EntitySystem:GetEntity(v.entityUid)
        targetEntity:SetEnable(true)
        self.world.ClientIFacdeSystem:Call("ActiveEntity",v.entityUid,true)
        if self.hpBarHideUid then
            self.world.ClientIFacdeSystem:Call("ForceShowHPByLock",v.entityUid, self.hpBarHideUid)
            self.hpBarHideUid = nil
        end

        local targetPos = targetEntity.TransformComponent:GetPos()
        local x = ownerPos.x + v.offsetPos.x
        local z = ownerPos.z + v.offsetPos.z

        x,z = self.world.BattleTerrainSystem:PosFix(targetEntity,x,z)
        targetEntity.TransformComponent:SetFixedPos(x,targetPos.y,z)

        self.world.ClientIFacdeSystem:Call("EntitySyncPos",v.entityUid)

        self.world.PluginSystem.EntityFunc:EntityAddBuff(targetEntity,self.entity.ownerUid,self.levParam.buffId)
    end

    self:SetRemove(true)
end