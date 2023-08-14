ClientBuffComponent = BaseClass("ClientBuffComponent",SECBClientComponent)

ClientBuffComponent.BuffStateMapping =
{
    [BattleDefine.BuffState.frozen] = "ActiveFrozen",
    [BattleDefine.BuffState.petrifying] = "ActivePetrifying"
}

function ClientBuffComponent:__Init()

end

function ClientBuffComponent:__Delete()

end

function ClientBuffComponent:OnInit()

end

function ClientBuffComponent:ActiveBuffState(state,flag)
    local funName = ClientBuffComponent.BuffStateMapping[state]
    if funName then
        self[funName](self,flag)
    end
end

function ClientBuffComponent:ActiveFrozen(flag)
    self.clientEntity.ClientAnimComponent:AddPauseLockNum(flag and 1 or -1)
    self.clientEntity.ShaderEffectComponent:ActiveEffect(BattleDefine.ShaderEffect.frozen,flag)
end

function ClientBuffComponent:ActivePetrifying(flag)
    self.clientEntity.ClientAnimComponent:AddPauseLockNum(flag and 1 or -1)
    self.clientEntity.ShaderEffectComponent:ActiveEffect(BattleDefine.ShaderEffect.petrifying,flag)
end