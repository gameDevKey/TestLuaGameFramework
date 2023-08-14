BuffCountChangeAttrBuffBehavior = BaseClass("BuffCountChangeAttrBuffBehavior",BuffBehavior)

function BuffCountChangeAttrBuffBehavior:__Init()
    self.changeAttrs = {}

    self.countKey = nil
    self.maxEffectiveCount = nil
end

function BuffCountChangeAttrBuffBehavior:__Delete()

end

function BuffCountChangeAttrBuffBehavior:OnInit()
    self.countKey = self.actionParam.resultType == BuffDefine.ResultType.deBuffer and BattleDefine.CountKey.debuff_all_entity or nil
    if not self.countKey then
        assert(false,"未实现的计数方法[增益buff]")
        return
    end
    self.maxEffectiveCount = self.actionParam.maxEffectiveCount
    local eventParam = {}
    eventParam.countKey = self.countKey
    self:AddEvent(BattleEvent.key_data_count_change,self:ToFunc("OnEvent"),eventParam)

    self:OnEvent(nil)
end

function BuffCountChangeAttrBuffBehavior:OnEvent(args)
    local count = nil
    if args and args.count then
        count = args.count
    else
        count = self.world.PluginSystem.KeyDataCount:GetCountByCountKey(self.countKey)
    end

    count = count <= self.maxEffectiveCount and count or self.maxEffectiveCount

    self:ResetAttrValue()

    for i,v in ipairs(self.actionParam.attrs) do
        local attrType = BattleUtils.GetConfAttr(v.attr)
        local fromEntityUid = self.buff.fromEntityUid
        local value = self.world.PluginSystem.CalcAttr:CalcAttr(self.entity.uid,fromEntityUid,v.mode,attrType,v)
        value = value * count

        self.entity.AttrComponent:AddValue(attrType,value)

        if not self.changeAttrs[i] then
            self.changeAttrs[i] = {attrType = attrType,value = value}
        else
            self.changeAttrs[i].value = self.changeAttrs[i].value + value
        end
    end

    -- LogTable("count="..count,self.changeAttrs)
end

function BuffCountChangeAttrBuffBehavior:ResetAttrValue()
    for i,v in ipairs(self.changeAttrs) do
        self.entity.AttrComponent:AddValue(v.attrType,-v.value)
    end
    self.changeAttrs = {}
end

function BuffCountChangeAttrBuffBehavior:OnDestroy()
    self:ResetAttrValue()
end