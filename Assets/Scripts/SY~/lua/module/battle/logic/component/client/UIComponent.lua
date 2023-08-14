UIComponent = BaseClass("UIComponent",SECBClientComponent)

function UIComponent:__Init()
    self.entityTop = nil
end

function UIComponent:__Delete()
    self:RemoveEntityTop()
end

function UIComponent:OnInit()
    self:InitEntityTop()

    if self.clientEntity.entity.AttrComponent then
        self.clientEntity.entity.AttrComponent:AddChangeListener(BattleDefine.Attr.hp,self:ToFunc("OnHpChange"))
        self.clientEntity.entity.AttrComponent:AddChangeListener(GDefine.Attr.max_energy,self:ToFunc("OnMaxEnergyChange"))
        self.clientEntity.entity.AttrComponent:AddChangeListener(GDefine.Attr.max_hp,self:ToFunc("OnMaxHpChange"))
        self.clientEntity.entity.AttrComponent:AddChangeListener(BattleDefine.Attr.extra_hp,self:ToFunc("OnExtraHpChange"))
        self.clientEntity.entity.AttrComponent:AddChangeListener(BattleDefine.Attr.energy,self:ToFunc("OnEnergyChange"))
    end
end

function UIComponent:InitEntityTop()
    local tag = self.clientEntity.entity.TagComponent.mainTag
    if tag == BattleDefine.EntityTag.hero then
        self.entityTop = HeroTopItem.Create(self.clientEntity)
    elseif tag == BattleDefine.EntityTag.home then
        self.entityTop = HomeTopItem.Create(self.clientEntity)
    elseif tag == BattleDefine.EntityTag.defender then
        self.entityTop = HeroTopItem.Create(self.clientEntity)
    elseif tag == BattleDefine.EntityTag.unit then
        self.entityTop = HeroTopItem.Create(self.clientEntity)
    end
end

function UIComponent:OnMaxEnergyChange()
    if self.entityTop and self.entityTop.CheckEnergyBarShow then
        self.entityTop:CheckEnergyBarShow()
    end
end

function UIComponent:OnHpChange()
    if self.entityTop and self.entityTop.RefreshHp then
        self.entityTop:RefreshHp()
    end
end

function UIComponent:OnExtraHpChange()
    if self.entityTop and self.entityTop.RefreshShield then
        self.entityTop:RefreshShield()
    end
end

function UIComponent:OnMaxHpChange()
    if self.entityTop and self.entityTop.RefreshMaxHp then
        self.entityTop:RefreshMaxHp()
    end
end

function UIComponent:OnEnergyChange()
    if self.entityTop and self.entityTop.RefreshEnergy then
        self.entityTop:RefreshEnergy()
    end
end

function UIComponent:OnUpdate()
end

function UIComponent:OnLateUpdate()
    if self.entityTop and not self.entityTop.NO_REFRESH_POS then
        self.entityTop:RefreshPos()
    end
end

function UIComponent:RemoveEntityTop()
    if self.entityTop then
		self.entityTop:Destroy()
		self.entityTop = nil
	end
end