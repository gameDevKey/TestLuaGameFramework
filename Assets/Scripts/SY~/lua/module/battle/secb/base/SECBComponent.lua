SECBComponent = BaseClass("SECBComponent",SECBBase)
SECBComponent.PRIORITY = 0

function SECBComponent:__Init()
    self.entity = nil
    self.type = nil
    self.args = nil
    self.enable = true
end

function SECBComponent:__Delete()
    
end

function SECBComponent:SetEntity(entity)
    self.entity = entity
end

function SECBComponent:SetEnable(flag)
    self.enable = flag
end

function SECBComponent:IsEnable()
    return self.enable and self.entity.enable 
end

function SECBComponent:SetArgs(args)
    self.args = args
end

function SECBComponent:Init()
    self.enable = true
    self:OnInit()
end

function SECBComponent:LateInit()
    self:OnLateInit()
end

function SECBComponent:PreUpdate()
    if self.OnPreUpdate then
        self:OnPreUpdate()
    end
end

function SECBComponent:Update()
    if self.OnUpdate then
        self:OnUpdate()
    end
end

function SECBComponent:LateUpdate()
    if self.OnLateUpdate then
        self:OnLateUpdate()
    end
end

function SECBComponent:Destroy()
    self:OnDestroy()
end

--
function SECBComponent:OnInit()
end

function SECBComponent:OnLateInit()
end

-- function SECBComponent:OnPreUpdate()
-- end

-- function SECBComponent:OnUpdate()
-- end

-- function SECBComponent:OnLateUpdate()
-- end

function SECBComponent:OnEnable(flag)
end

function SECBComponent:OnDestroy()
end