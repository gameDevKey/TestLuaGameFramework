EffectComponent = BaseClass("EffectComponent",SECBClientComponent)

function EffectComponent:__Init()
    self.effects = {}
    self.onEffectHook = nil
end

function EffectComponent:__Delete()
    self:CleanEffect()
end

function EffectComponent:OnInit()
end

function EffectComponent:AddEffect(effect)
	self.effects[effect.uid] = true
	effect:SetComplete(self:ToFunc("EffectComplete"))
    if self.onEffectHook then
        self.onEffectHook(effect.uid)
    end
end

function EffectComponent:EffectComplete(uid)
    self:RemoveEffect(uid)
end

function EffectComponent:RemoveEffect(uid)
    if self.effects[uid] then
        self.world.BattleAssetsSystem:RemoveEffect(uid)
        self.effects[uid] = nil
    end
end

function EffectComponent:CleanEffect()
    for uid,_ in pairs(self.effects) do
        self.world.BattleAssetsSystem:RemoveEffect(uid)
	end
end

function EffectComponent:SetEffectHook(effectHook)
    self.onEffectHook = effectHook
end