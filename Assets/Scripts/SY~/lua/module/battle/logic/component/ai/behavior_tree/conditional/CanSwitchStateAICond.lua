CanSwitchStateAICond = BaseClass("CanSwitchStateAICond",BTConditional)

function CanSwitchStateAICond:__Init()

end

function CanSwitchStateAICond:__Delete()

end

function CanSwitchStateAICond:OnStart()

end

function CanSwitchStateAICond:OnUpdate(deltaTime)
    local flag = self.owner.entity.StateComponent:CanSwitchState()
    return self:CheckCond(flag)
end