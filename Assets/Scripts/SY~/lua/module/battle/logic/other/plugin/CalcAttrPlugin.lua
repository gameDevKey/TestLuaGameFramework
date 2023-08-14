CalcAttrPlugin = BaseClass("CalcAttrPlugin",SECBPlugin)
CalcAttrPlugin.NAME = "CalcAttr"

function CalcAttrPlugin:__Init()

end

function CalcAttrPlugin:__Delete()
    
end


--fromEntityUid是肯定存在的
function CalcAttrPlugin:CalcAttr(fromEntityUid,targetEntityUid,calMode,attrType,args)
    --固定值直接返回
    if calMode == "固定值" then
        return args.val
    end

    local from = args.from or 1

    local calcEntityUid = from == 1 and fromEntityUid or targetEntityUid

    --如果targetEntityUid不存在直接取本体
    local attrValue = self:GetAttr(calcEntityUid or fromEntityUid,attrType,args.attrMode)

    if calMode == "比例" then
        return FPMath.Divide(attrValue * args.ratio,BattleDefine.AttrRatio)
    else
        --assert(false,string.format("未知的属性计算方式[计算方式:%s]",tostring(calMode)))
    end

    return nil
end

function CalcAttrPlugin:CalcCommanderAttr(fromEntityUid,targetEntityUid,calMode,attrType,args)
    --固定值直接返回
    if calMode == "固定值" then
        return args.val
    end

    local calcEntityUid = nil
    if args.from == 1 then                   -- 为 1 时取来源者
        calcEntityUid = fromEntityUid
    elseif args.from == -2 then              -- 为 -2 时取主堡对应的统帅
        local entity = self.world.EntitySystem:GetEntity(targetEntityUid)
        local camp = entity.CampComponent:GetCamp()
        local roleUid = self.world.BattleDataSystem:GetRoleUidByIndex(camp,1)
        local commanderEntity = self.world.EntitySystem:GetRoleCommander(roleUid)
        calcEntityUid = commanderEntity.uid
    else                                     -- 其余情况取主堡自身
        calcEntityUid = targetEntityUid
    end

    --如果targetEntityUid不存在直接取本体
    local attrValue = self:GetAttr(calcEntityUid or fromEntityUid,attrType,args.attrMode)

    if calMode == "比例" then
        return FPMath.Divide(attrValue * args.ratio,BattleDefine.AttrRatio)
    else
        --assert(false,string.format("未知的属性计算方式[计算方式:%s]",tostring(calMode)))
    end

    return nil
end

function CalcAttrPlugin:CalcVal(val,args,mode,factor,otherArgs)
    if not mode then mode = args.mode end
    if not factor then factor = 1 end
    if mode == "固定值" then
        return args.val * factor
    elseif mode == "比例" then
        return FPMath.Divide(val * (args.ratio * factor),BattleDefine.AttrRatio)
    elseif mode == "额外命中" then
        return FPMath.Divide(val * (args.ratio * factor),BattleDefine.AttrRatio) * (otherArgs.calcNum or 0)
    end
end

function CalcAttrPlugin:CalValByRatio(val,ratio)
    return FPMath.Divide(val * ratio,BattleDefine.AttrRatio)
end

function CalcAttrPlugin:GetAttr(entityUid,attrType,attrGetMode)
    local entity = self.world.EntitySystem:GetEntity(entityUid)
    if entity then
        if attrGetMode == BattleDefine.AttrGetMode.base then
            return entity.AttrComponent:GetBaseValue(attrType)
        elseif attrGetMode == BattleDefine.AttrGetMode.add then
            return entity.AttrComponent:GetAddValue(attrType)
        else
            return entity.AttrComponent:GetValue(attrType)
        end
    else
        local relAttr = self.world.EntitySystem:GetRefAttr(entityUid)
        if attrGetMode == BattleDefine.AttrGetMode.base then
            return AttrComponent.GetRefBaseValue(relAttr,attrType)
        elseif attrGetMode == BattleDefine.AttrGetMode.add then
            return AttrComponent.GetRefAddValue(relAttr,attrType)
        else
            return AttrComponent.GetRefValue(relAttr,attrType)
        end
    end
end