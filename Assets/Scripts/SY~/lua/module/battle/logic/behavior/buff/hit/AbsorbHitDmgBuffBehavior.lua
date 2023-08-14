AbsorbHitDmgBuffBehavior = BaseClass("AbsorbHitDmgBuffBehavior",BuffBehavior)

function AbsorbHitDmgBuffBehavior:__Init()
    self.absorbHp = 0
end

function AbsorbHitDmgBuffBehavior:__Delete()

end

function AbsorbHitDmgBuffBehavior:OnInit()
    local fromEntityUid = self.buff.fromEntityUid
    local attrType = BattleUtils.GetConfAttr(self.actionParam.attr)
    local mode = self.actionParam.mode
    self.absorbHp = self.world.PluginSystem.CalcAttr:CalcAttr(self.entity.uid,fromEntityUid,mode,attrType,self.actionParam)
    self.entity.AttrComponent:AddValue(BattleDefine.Attr.extra_hp,self.absorbHp)
    
    local eventParam = {}
    eventParam.entityUid = self.entity.uid
    self:AddEvent(BattleEvent.absorb_hit_dmg,self:ToFunc("OnEvent"),eventParam)
end

function AbsorbHitDmgBuffBehavior:OnEvent(args)
    if args.curCalcResultVal <= 0 or self.absorbHp <= 0  then
        return 0
    end

    local absorbVal = args.curCalcResultVal >= self.absorbHp and self.absorbHp or args.curCalcResultVal
    self.absorbHp = self.absorbHp - absorbVal
    self.entity.AttrComponent:AddValue(BattleDefine.Attr.extra_hp,-absorbVal)
    self.buff:AddExecNum()

    self:ShowFlyingText(absorbVal)

    return -absorbVal
end

function AbsorbHitDmgBuffBehavior:OnCheckRemove()
    return self.absorbHp <= 0
end

function AbsorbHitDmgBuffBehavior:OnDestroy()
    if self.absorbHp > 0 then
        self.entity.AttrComponent:AddValue(BattleDefine.Attr.extra_hp,-self.absorbHp)
    end
end

function AbsorbHitDmgBuffBehavior:ShowFlyingText(val)
    self.world.ClientIFacdeSystem:Call("SendEvent","FlyingTextView","ShowFlyingText",BattleDefine.FlyingText.shield,
            {value = val,uid = self.entity.uid})
end