EquipUtils = StaticClass("EquipUtils")



function EquipUtils.GetAttrsByTag(attrs,attrTag)
    local outAttrs = {}
    for i,v in ipairs(attrs) do
        local conf = Config.AttrData.data_attr_info[v.attr_id]
        if conf.attr_tag == attrTag then
            table.insert(outAttrs,v)
        end
    end
    return outAttrs
end