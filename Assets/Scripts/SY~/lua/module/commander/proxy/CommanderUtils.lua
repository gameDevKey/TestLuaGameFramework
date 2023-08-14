CommanderUtils = StaticClass("CommanderUtils")


function CommanderUtils.GetAttrVal(attrs,attrType)
    for i,v in ipairs(attrs) do
        if v.attr_id == attrType then
            return v.attr_val
        end
    end
    return 0
end

function CommanderUtils.GetEntryAttrs(attrs)
    local entryAttrs = {}
    for i,v in ipairs(attrs) do
        local conf = Config.AttrData.data_attr_info[v.attr_id]
        if conf.attr_tag == GDefine.AttrTag.entry then
            table.insert(entryAttrs,v)
        end
    end
    return entryAttrs
end

function CommanderUtils.GetEquipQualityInfo(quality)
    for i,v in ipairs(Config.ConstData.data_const_info["quality_info"].val) do
        if v[1] == quality then
            return v[2],v[3]
        end
    end
end

function CommanderUtils.FormatAttrShow(attrId,attrVal,unitId)
    local attrConf = Config.AttrData.data_attr_info[attrId]
    local showAttrVal = ""
    if attrId == GDefine.Attr.atk_speed then
        local conf = Config.CommanderData.data_const_info["atk_speed_show"]
        showAttrVal = string.format("%.2f秒",conf.val[1] / (attrVal * 0.0001))
    elseif attrId == GDefine.Attr.atk_distance then
        if unitId then
            local unitConf = Config.UnitData.data_unit_info[unitId]
            showAttrVal = unitConf.atk_radius_show
        else
            local conf = Config.CommanderData.data_const_info["atk_distance_show"]
            showAttrVal = string.format("%.2f",(conf.val[1] + attrVal - conf.val[2]) / conf.val[3] / conf.val[4] + conf.val[5])
        end
    elseif attrConf.attr_tag == GDefine.AttrTag.entry then
        showAttrVal = string.format("%.2f",attrVal * 0.0001 * 100) .. "%"
    else
        showAttrVal = attrVal
    end
    return showAttrVal
end