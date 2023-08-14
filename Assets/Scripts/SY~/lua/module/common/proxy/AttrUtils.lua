AttrUtils = StaticClass("AttrUtils")

function AttrUtils.SortAttr(attrs)
    table.sort(attrs,AttrUtils.SortAttrRule)
end

function AttrUtils.SortAttrRule(a,b)
    local aConf = Config.AttrData.data_attr_info[a.attr_id]
    local bConf = Config.AttrData.data_attr_info[b.attr_id]
    return aConf.priority > bConf.priority
end

function AttrUtils.GetAttrValue(unitId,attrId)
    local key = nil
    local nextKey = nil

    local unitData = mod.CollectionProxy:GetDataById(unitId)
    if unitData then
        key = unitId.."_"..unitData.level
        nextKey = unitId.."_"..unitData.level+1
    else
        key = unitId.."_"..1
    end
    local levConf = Config.UnitData.data_unit_lev_info[key]
    local nextLevConf = Config.UnitData.data_unit_lev_info[nextKey]

    local attrList = nil
    local nextLevAttrList = nil
    local isObtained = false
    if unitData then
        attrList = unitData.attr_list
        nextLevAttrList = nextLevConf and nextLevConf.attr_list
        isObtained = true
    else
        attrList = levConf.attr_list
    end

    local value = 0
    local addValue = 0
    for k, v in pairs(attrList) do
        local tempAttrId = 0
        local attrVal = 0
        if isObtained then
            tempAttrId = v.attr_id
            attrVal = v.attr_val
        else
            tempAttrId = GDefine.AttrNameToId[v[1]]
            attrVal = v[2]
        end
        if tempAttrId == attrId then
            value = attrVal
            break
        end
    end

    local nextVal = nil
    if nextLevAttrList then
        for k, v in pairs(nextLevAttrList) do
            if GDefine.AttrNameToId[v[1]] == attrId then
                nextVal = v[2]
                break
            end
        end
        if nextVal then
            addValue = nextVal - value
        end
    end

    return value,addValue
end