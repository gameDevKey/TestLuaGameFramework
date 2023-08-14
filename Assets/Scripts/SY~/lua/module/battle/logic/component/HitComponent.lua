HitComponent = BaseClass("HitComponent",SECBComponent)

function HitComponent:__Init()
    self.hitFuncs = {}
    --self.hitFuncs[BattleDefine.HitType.hp] = self:ToFunc("HitHp")
    --self.hitFuncs[BattleDefine.HitType.action] = self:ToFunc("HitAction")
end

function HitComponent:__Delete()

end

function HitComponent:OnInit()

end

function HitComponent:Hit(fromEntityUid,hitList,hitParam)
    -- for i,v in ipairs(hitList) do
    --     local func = self.hitFuncs[v.hit_type]
    --     assert(func, string.format("未知的受击类型[%s]",v.hit_type))
    --     func(v)
    --     self:ShowMaskFlyingText(v)
    -- end

    --TODO:正常扣血流程
    -- if attackEntityUid == 1 or attackEntityUid == 2 then
    --     self.entity.AttrComponent:AddValue(BattleDefine.Attr.hp,-math.random(1, 10))
    -- else
    --     self.entity.AttrComponent:AddValue(BattleDefine.Attr.hp,-math.random(300, 500))
    -- end

    
    if self.entity.TagComponent.mainTag == BattleDefine.EntityTag.home then
        self.entity.AttrComponent:AddValue(BattleDefine.Attr.hp,-math.random(100, 300))
    elseif self.entity.CampComponent:GetCamp() == 2 then
        self.entity.AttrComponent:AddValue(BattleDefine.Attr.hp,-math.random(10, 50))
    elseif self.entity.CampComponent:GetCamp() == 1 then
        self.entity.AttrComponent:AddValue(BattleDefine.Attr.hp,-math.random(10, 30))
    end

    --self.entity.StateComponent:SwitchHit(BattleDefine.EntityHitState.anim)

    if self.entity.TagComponent.mainTag == BattleDefine.EntityTag.home then
        self.world.EventTriggerSystem:Trigger(BattleEvent.be_home_hit,self.entity.uid)
    end

    local isDie = self.entity.AttrComponent:GetValue(BattleDefine.Attr.hp) <= 0

    if isDie then
        self.entity.StateComponent:SetState(BattleDefine.EntityState.die)
        self.world.EventTriggerSystem:Trigger(BattleEvent.unit_die,fromEntityUid,self.entity.uid)
    end
end

function HitComponent:HitDmgHp(val,isCrit)
    self.entity.AttrComponent:AddValue(BattleDefine.Attr.hp,-val)

    if self.entity.TagComponent.mainTag == BattleDefine.EntityTag.home then
        self.world.EventTriggerSystem:Trigger(BattleEvent.be_home_hit,self.entity.uid,self.entity.CampComponent.camp,val)
    end

    -- if isCrit or DEBUG_FLYHP then
    --     self.world.ClientIFacdeSystem:Call("SendEvent",FlyingTextView.Event.ShowFlyingText,BattleDefine.FlyingText.hp,
    --         {value = -val,isCrit = isCrit,uid = self.entity.uid})
    -- end
    
    -- if DEBUG_FLYHP then
    -- end
    --self:CheckDie()
end

function HitComponent:HitHealHp(val,isCrit)
    self.entity.AttrComponent:AddValue(BattleDefine.Attr.hp,val)

    -- if isCrit or DEBUG_FLYHP then
    --     self.world.ClientIFacdeSystem:Call("SendEvent",FlyingTextView.Event.ShowFlyingText,BattleDefine.FlyingText.hp,
    --         {value = val,isCrit = isCrit,uid = self.entity.uid})
    -- end

    -- self.world.ClientIFacdeSystem:Call("SendEvent",FlyingTextView.Event.ShowFlyingText,BattleDefine.FlyingText.hp,
    --     {value = val,isCrit = isCrit,uid = self.entity.uid})
end

function HitComponent:HitEnergy(val,isCrit)
    self.entity.AttrComponent:AddValue(BattleDefine.Attr.energy,val)
end