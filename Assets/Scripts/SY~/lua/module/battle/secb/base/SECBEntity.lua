SECBEntity = BaseClass("SECBEntity",SECBBase)

function SECBEntity:__Init()
    self.entityId = 0
    self.uid = 0
    self.components = {} --组件
    self.orderToComponents = {init={},update={},delete={}}
    self.clientEntity = nil
    self.parentEntity = nil
    self.bindEntitys = {}
    self.ownerUid = nil
    self.enable = true
end

function SECBEntity:__Delete()
    for _,priority in ipairs(self.world.opts.componentDelOrder) do
        local components = self.orderToComponents.delete[priority]
        if components then
            for _,component in ipairs(components) do
                component:Delete()
            end
        end
    end
end

function SECBEntity:Init(entityId,uid)
    self.entityId = entityId
	self.uid = uid
    self.enable = true

    self:OnInit()
end

function SECBEntity:SetEnable(flag)
    self.enable = flag
end

function SECBEntity:SetOwnerUid(ownerUid)
    self.ownerUid = ownerUid
end

function SECBEntity:AddComponent(componentType)
    local component = componentType.New()
    component:SetWorld(self.world)
    component:SetEntity(self)

    local initPriority = component.INIT_PRIORITY or 0
    if not self.orderToComponents.init[initPriority] then self.orderToComponents.init[initPriority] = {} end
    table.insert(self.orderToComponents.init[initPriority],component)

    local updatePriority = component.UPDATE_PRIORITY or 0
    if not self.orderToComponents.update[updatePriority] then self.orderToComponents.update[updatePriority] = {} end
    table.insert(self.orderToComponents.update[updatePriority],component)

    local deletePriority = component.DELETE_PRIORITY or 0
    if not self.orderToComponents.delete[deletePriority] then self.orderToComponents.delete[deletePriority] = {} end
    table.insert(self.orderToComponents.delete[deletePriority],component)

    local name = component.NAME or component.__className
    self[name] = component
    table.insert(self.components,component)
end

function SECBEntity:InitComponent()
    for _,priority in ipairs(self.world.opts.componentInitOrder) do
        local components = self.orderToComponents.init[priority]
        if components then
            for _,component in ipairs(components) do
                component:Init()
            end
        end
    end
end

function SECBEntity:AfterInitComponent()
    for _,priority in ipairs(self.world.opts.componentInitOrder) do
        local components = self.orderToComponents.init[priority]
        if components then
            for _,component in ipairs(components) do
                component:LateInit()
            end
        end
    end
end

function SECBEntity:PreUpdateComponent()
    for _,priority in ipairs(self.world.opts.componentUpdateOrder) do
        local components = self.orderToComponents.update[priority]
        if components then
            for _,component in ipairs(components) do
                if component:IsEnable() then
                    component:PreUpdate()
                end
            end
        end
    end
end

function SECBEntity:UpdateComponent()
    for _,priority in ipairs(self.world.opts.componentUpdateOrder) do
        local components = self.orderToComponents.update[priority]
        if components then
            for _,component in ipairs(components) do
                if component:IsEnable() then
                    local flag = component:Update()
                    if flag then
                        return
                    end
                end
            end
        end
    end
end

function SECBEntity:LateUpdateComponent()
    for _,priority in ipairs(self.world.opts.componentUpdateOrder) do
        local components = self.orderToComponents.update[priority]
        if components then
            for _,component in ipairs(components) do
                if component:IsEnable() then
                    component:LateUpdate()
                end
            end
        end
    end
end

function SECBEntity:SetClientEntity(clientEntity)
    self.clientEntity = clientEntity
end

function SECBEntity:SetParentEntity(parentEntity)
    self.parentEntity = parentEntity
end

function SECBEntity:RemoveParentEntity()
    self.parentEntity = nil
end

function SECBEntity:PreUpdate()
    self:OnPreUpdate()
end

function SECBEntity:Update()
    self:OnUpdate()
end

function SECBEntity:LateUpdate()
    self:OnLateUpdate()
end

function SECBEntity:RemoveComponent()
    for _,priority in ipairs(self.world.opts.componentDelOrder) do
        local components = self.orderToComponents.delete[priority]
        if components then
            for _,component in ipairs(components) do
                component:Delete()
                local name = component.NAME or component.__className
                self[name] = nil
            end
        end
    end
    self.components = {}
    self.orderToComponents = {init={},update={},delete={}}
end

function SECBEntity:CallClientComponentFunc(componentName,func,...)
    if not self.clientEntity then
        return
    end

    if self.clientEntity[componentName] then
        self.clientEntity[componentName][func](self.clientEntity[componentName],...)
    end
end

function SECBEntity:Destroy()
    self:OnDestroy()
end

--实体构造回调,在__Init之后执行(world已设置)
function SECBEntity:OnInit()
end

function SECBEntity:OnPreUpdate()
    
end

function SECBEntity:OnUpdate()
end

function SECBEntity:OnLateUpdate()
end

function SECBEntity:OnDestroy()
    for _,priority in ipairs(self.world.opts.componentDelOrder) do
        local components = self.orderToComponents.delete[priority]
        if components then
            for _,component in ipairs(components) do
                component:Destroy()
            end
        end
    end
end