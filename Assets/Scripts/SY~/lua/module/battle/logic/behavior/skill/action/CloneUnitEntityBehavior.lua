CloneUnitEntityBehavior = BaseClass("CloneUnitEntityBehavior",SkillBehavior)

function CloneUnitEntityBehavior:__Init()
    self:InitData()
end

function CloneUnitEntityBehavior:__Delete()

end

function CloneUnitEntityBehavior:InitData()
    self.isReachLifeTime = false
    self.lifeTime = 0
    self.currentTime = 0
end

function CloneUnitEntityBehavior:OnInit()
    self.skill:AddRefNum(1)
    self:InitData()

    self.lifeTime = self.actionParam.lifeTime or 0

    self:AddKvTypeToOwner()

    local eventArgs = {}
    eventArgs.entityUid = self.entity.uid
    self:AddEvent(BattleEvent.unit_die, self:ToFunc("OnUnitDie"), eventArgs)
end

function CloneUnitEntityBehavior:OnUpdate()
    self:CheckLifeTime()
end

function CloneUnitEntityBehavior:OnReachLifeTime()
    if self.isReachLifeTime then
        return
    end
    self.isReachLifeTime = true
    self.world.BattleHitSystem:ImmedDie(self.entity)
end

function CloneUnitEntityBehavior:CheckLifeTime()
    if self.lifeTime > 0 and not self.isReachLifeTime then
        self.currentTime = self.currentTime + self.world.opts.frameDeltaTime
        if self.currentTime >= self.lifeTime then
            self:OnReachLifeTime()
        end
    end
end

function CloneUnitEntityBehavior:OnUnitDie()
    local ownerUid = self.entity.ownerUid
    local ownerEntity = ownerUid and self.world.EntitySystem:GetEntity(ownerUid)
    if ownerEntity then
        for _,buffId in ipairs(self.actionParam.buffList or {}) do
            ownerEntity.BuffComponent:AddBuff(self.entity.uid,buffId)
        end
    end
    self:RemoveKvTypeFromOwner()
end

function CloneUnitEntityBehavior:AddKvTypeToOwner()
    local ownerUid = self.entity.ownerUid
    local ownerEntity = ownerUid and self.world.EntitySystem:GetEntity(ownerUid)
    if ownerEntity then
        local kvType = BattleDefine.EntityKvType.clone_units
        local units = ownerEntity.KvDataComponent:GetData(kvType) or {}
        for i= #units,1,-1 do
            local uid = units[i]
            if uid == self.entity.uid then
                table.remove(units,i)
            end
        end
        table.insert(units, self.entity.uid)
        ownerEntity.KvDataComponent:SetData(kvType, units)
        -- if not self.world.isCheck then
        --     LogYqh(ownerUid,"召唤分身 缓存分身Uid",self.entity.uid)
        -- end
    end
end

function CloneUnitEntityBehavior:RemoveKvTypeFromOwner()
    local ownerUid = self.entity.ownerUid
    local ownerEntity = ownerUid and self.world.EntitySystem:GetEntity(ownerUid)
    if ownerEntity then
        local kvType = BattleDefine.EntityKvType.clone_units
        local units = ownerEntity.KvDataComponent:GetData(kvType) or {}
        for i= #units,1,-1 do
            local uid = units[i]
            if uid == self.entity.uid then
                table.remove(units,i)
            end
        end
        -- if not self.world.isCheck then
        --     LogYqh(ownerUid,"召唤分身 移除分身Uid",self.entity.uid)
        -- end
    end
end