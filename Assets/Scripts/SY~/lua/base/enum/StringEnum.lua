StringEnum = StringEnum or BaseEnum()
StringEnum.OK = true

function StringEnum:__format(...)
    local enums = {...}
    local formatEnums = {}
    for _,v in ipairs(enums) do table.insert(formatEnums,{ key = v,value = v })  end
    return formatEnums
end