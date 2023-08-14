SECBClientWorld = BaseClass("SECBClientWorld")

function SECBClientWorld:__Init(world)
    self.world = world
end

function SECBClientWorld:__Delete()
end

function SECBClientWorld:Enter()
end

function SECBClientWorld:OnEnter()
end

function SECBClientWorld:Update()
    self:OnUpdate()
end

function SECBClientWorld:LateUpdate()
    self:OnLateUpdate()
end

function SECBClientWorld:OnUpdate()
end

function SECBClientWorld:OnLateUpdate()
end