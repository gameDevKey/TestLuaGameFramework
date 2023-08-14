function BaseEnum()
    local enum_type = {}
    enum_type.__index = enum_type

	enum_type.New = function(...)
        local obj = {}
        setmetatable(obj,enum_type)

        local enums = obj.__format and obj:__format(...) or {...}
        for i,v in ipairs(enums) do
            if not v.key or not v.value then
                LogErrorf("枚举key-value为空[key:%s][value:%s]",tostring(v.key),tostring(v.value))
                return
            end
            
            if obj[v.key] then
                LogErrorf("枚举重复定义[key:%s]",tostring(v.key))
                return
            end

            obj[v.key] = v.value
        end

		return TableUtils.ReadOnly (obj,"枚举")
    end
    
    return enum_type
end