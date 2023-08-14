SimpleEffect = BaseClass("SimpleEffect",EffectBase)
SimpleEffect.poolKey = "battle_simple_effect"

function SimpleEffect:__Init()

end

function SimpleEffect:__Delete()

end

function SimpleEffect:OnInit()
    if self.setting.parent then
        self:SetParent(self.setting.parent)
    end
end