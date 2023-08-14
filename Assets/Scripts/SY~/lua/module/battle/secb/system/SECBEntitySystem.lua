SECBEntitySystem = BaseClass("SECBEntitySystem",SECBSystem)
--控制逻辑实体

function SECBEntitySystem:__Init()
    self.uid = 0
    self.entitys = {}
    self.entityList = SECBList.New()

    self.removeFlag = false
    self.removeEntitys = {}
    self.removeEntityDict = {}

    self.preRemoves = {}
end

function SECBEntitySystem:__Delete()
    self.entityList:Delete()
end

function SECBEntitySystem:GetUid()
    self.uid = self.uid + 1
    return self.uid
end

function SECBEntitySystem:AddEntity(entity)
    local uid = entity.uid
    if self.entitys[uid] then
        assert(false,string.format("存在相同实体Id[%s]",entity.uid))
    end

    self.entitys[uid] = entity
    self.entityList:Push(uid,uid)
    self:OnAddEntity(entity)
end

function SECBEntitySystem:LateUpdate()
    self:OnLateUpdate()
    self:CleanRemoveEntity()
end

function SECBEntitySystem:CleanRemoveEntity()
    if not self.removeFlag then
        return
    end
    self.removeFlag = false
    
    for _,entity in ipairs(self.removeEntitys) do
        local uid = entity.uid
        self.entitys[uid] = nil
        self.entityList:RemoveByIndex(uid)
        self.preRemoves[uid] = nil
        self.removeEntityDict[uid] = nil

        self:OnRemoveEntity(entity)
        entity:Destroy()
        entity:Delete()

        if self.world.opts.isClient then
            self.world.ClientEntitySystem:RemoveEntity(uid)
        end
    end
    self.removeEntitys = {}
end

function SECBEntitySystem:PreUpdateEntity()
    for iter in self.entityList:Items() do
        local uid = iter.value
        local entity = self:GetEntity(uid)
        entity:PreUpdate()
    end
end

function SECBEntitySystem:UpdateEntity()
    for iter in self.entityList:Items() do
        local uid = iter.value
        local entity = self:GetEntity(uid)
        entity:Update()
    end
end

function SECBEntitySystem:LateUpdateEntity()
    for iter in self.entityList:Items() do
        local uid = iter.value
        local entity = self:GetEntity(uid)
        entity:LateUpdate()
    end
end

function SECBEntitySystem:GetEntity(uid)
    return self.entitys[uid]
end

function SECBEntitySystem:HasEntity(uid)
    if not self.entitys[uid] then
        return false
    end

    if self.preRemoves[uid] then
        return false
    end

    if self.removeEntityDict[uid] then
        return false
    end

    return true
end

function SECBEntitySystem:PreRemove(uid)
    self.preRemoves[uid] = true
end

function SECBEntitySystem:RemoveEntity(uid)
    local entity = self.entitys[uid]
	if not entity or self.removeEntityDict[uid] then
		return
	end

    self.removeEntityDict[uid] = true

    --self.preRemoves[uid] = true

    -- if self.preRemoves[uid] then
    --     self.preRemoves[uid] = nil
    -- end

	-- self.entitys[uid] = nil
    -- self.entityList:RemoveByIndex(uid)

    table.insert(self.removeEntitys,entity)
    self.removeFlag = true

    --self:OnRemoveEntity(entity)

    -- if self.world.opts.isClient then
	-- 	self.world.ClientEntitySystem:RemoveEntity(uid)
	-- end
end

function SECBEntitySystem:CleanEntitys()
    self:CleanRemoveEntity()

    for iter in self.entityList:Items() do
        local uid = iter.value
        local entity = self:GetEntity(uid)
        if entity then
            entity:Delete()
        end
    end
    self.entityList:Clear()
end

function SECBEntitySystem:CallEntityComponent(cName,funcName,...)
    for iter in self.entityList:Items() do
        local uid = iter.value
        local entity = self:GetEntity(uid)
        if entity and entity[cName] and entity[cName][funcName] then
            entity[cName][funcName](entity[cName],...)
        end
    end
end

--
function SECBEntitySystem:OnUpdate()
end

function SECBEntitySystem:OnAddEntity(entity)

end

function SECBEntitySystem:OnRemoveEntity(entity)
end