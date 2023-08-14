Enum = Enum or BaseEnum()

function Enum:__format(...)
    local enums = {...}
    local formatEnums = {}
    for _,v in ipairs(enums) do table.insert(formatEnums,{ key = v,value = { value = v, _enum = true } })  end
    return formatEnums
end