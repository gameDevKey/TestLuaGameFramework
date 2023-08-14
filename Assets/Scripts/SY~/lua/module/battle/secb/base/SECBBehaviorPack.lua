SECBBehaviorPack = BaseClass("SECBBehaviorPack",SECBBase)

function SECBBehaviorPack:__Init(behavior)
    self.Behavior = behavior
end

function SECBBehaviorPack:__Delete()
    
end

function SECBBehaviorPack:Init(...)
    self:OnInit(...)
end

function SECBBehaviorPack:Start(...)
    self:OnStart(...)
end

function SECBBehaviorPack:Update()
    self:OnUpdate()
end

function SECBBehaviorPack:OnInit(...)
end

function SECBBehaviorPack:OnStart(...)
end

function SECBBehaviorPack:OnUpdate()
end