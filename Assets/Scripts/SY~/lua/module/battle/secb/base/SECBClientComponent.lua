SECBClientComponent = BaseClass("SECBClientComponent",SECBBase)

function SECBClientComponent:__Init()
    self.clientEntity = nil --客户端实体
end

function SECBClientComponent:__Delete()
    
end

function SECBClientComponent:SetClientEntity(entity)
    self.clientEntity = entity
end

function SECBClientComponent:Update(lerpTime)
    self:OnUpdate(lerpTime)
end

function SECBClientComponent:LateUpdate(lerpTime)
    self:OnLateUpdate(lerpTime)
end

--

function SECBClientComponent:OnCreate()
end

function SECBClientComponent:OnInit()
end

function SECBClientComponent:OnLateInit()
end

function SECBClientComponent:OnUpdate(lerpTime)

end

function SECBClientComponent:OnLateUpdate(lerpTime)
    
end