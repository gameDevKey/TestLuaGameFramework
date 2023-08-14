EventEnum = EventEnum or BaseEnum()

function EventEnum:__format(...)
    local enums = {...}
    local formatEnums = {}
    local id = tostring(self)
    for _,v in ipairs(enums) do table.insert(formatEnums,{ key = v,value = {id = id,value = v,_enum = true} })  end
    return formatEnums
end