SECBClientEntity = BaseClass("SECBClientEntity",SECBBase)

function SECBClientEntity:__Init()
    self.entity = nil --逻辑实体
    self.components = {} --组件
end

function SECBClientEntity:__Delete()
    for _,component in ipairs(self.components) do
        component:Delete()
    end
end

function SECBClientEntity:SetEntity(entity)
    self.entity = entity
end

function SECBClientEntity:AddComponent(componentType)
    local component = componentType.New()
    component:SetWorld(self.world)
    component:SetClientEntity(self)
    component:OnCreate()
    local name = component.NAME or component.__className
    self[name] = component
    table.insert(self.components,component)
end

function SECBClientEntity:InitComponent()
    for _,component in ipairs(self.components) do
        component:OnInit()
    end
end

function SECBClientEntity:AfterInitComponent()
    for _,component in ipairs(self.components) do
        component:OnLateInit()
    end
end

function SECBClientEntity:UpdateComponent()
	for _, v in ipairs(self.components) do
        v:Update()
	end
end

function SECBClientEntity:LateUpdateComponent()
    for _, v in ipairs(self.components) do
        v:LateUpdate()
	end
end

function SECBClientEntity:Update()
    self:OnUpdate()
end

function SECBClientEntity:LateUpdate()
    self:OnLateUpdate()
end

function SECBClientEntity:RemoveComponent()
    for _,component in ipairs(self.components) do
        component:Delete()
        local name = component.NAME or component.__className
        self[name] = nil
    end
    self.components = {}
end

--回调函数

function SECBClientEntity:OnUpdate()
end

function SECBClientEntity:OnLateUpdate()
end
