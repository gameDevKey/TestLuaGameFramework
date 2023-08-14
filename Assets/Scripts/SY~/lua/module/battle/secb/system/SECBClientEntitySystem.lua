SECBClientEntitySystem = BaseClass("SECBClientEntitySystem",SECBSystem)
--控制客户端实体

function SECBClientEntitySystem:__Init()
    self.entitys = {}
    self.entityList = SECBList.New()
end

function SECBClientEntitySystem:__Delete()
    self.entityList:Delete()
end

function SECBClientEntitySystem:AddEntity(clientEntity)
    local uid = clientEntity.entity.uid
    self.entitys[uid] = clientEntity
    self.entityList:Push(uid,uid)
end

function SECBClientEntitySystem:CleanEntitys()
    for iter in self.entityList:Items() do
        local uid = iter.value
        local entity = self:GetEntity(uid)
        if entity then
            entity:Delete()
        end
    end
    self.entityList:Clear()
end

function SECBClientEntitySystem:RemoveEntity(uid)
	local entity = self:GetEntity(uid)
    if not entity then
        return
    end

    self.entitys[uid] = nil
    self.entityList:RemoveByIndex(uid)

    entity:Delete()
end

function SECBClientEntitySystem:UpdateEntity()
    for iter in self.entityList:Items() do
        local uid = iter.value
        local entity = self:GetEntity(uid)
        entity:Update()
    end
end

function SECBClientEntitySystem:LateUpdateEntity(lerpTime)
    for iter in self.entityList:Items() do
        local uid = iter.value
        local entity = self:GetEntity(uid)
        entity:LateUpdate(lerpTime)
    end
end

function SECBClientEntitySystem:GetEntity(uid)
    return self.entitys[uid]
end

--
function SECBClientEntitySystem:OnUpdate()
end