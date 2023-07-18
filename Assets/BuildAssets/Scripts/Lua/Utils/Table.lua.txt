function table.Count(tb)
    if not IsTable(tb) then
        PrintWarning("table.Count 只接受 table 类型的入参 : ", tb)
        return 0
    end
    local count = 0
    for _, v in pairs(tb) do
        count = count + 1
    end
    return count
end

function table.IsValid(tb)
    if not tb then
        return false
    end
    return table.Count(tb) > 0
end

function table.Contain(tb, obj)
    for k, item in pairs(tb or NIL_TABLE) do
        if item == obj then
            return true, k
        end
    end
    return false, nil
end

function table.ToString(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then tmp = tmp .. name .. " = " end

    if IsClass(val) then
        tmp = tmp .. tostring(val)
    elseif type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp = tmp .. table.ToString(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end

function table.ReadOnly(tb, name)
    local proxy = {}
    local mt = {
        __index = tb, --允许访问的关键
        __newindex = function(t, k, v)
            error(string.format("无法修改或新增%s字段[%s]", name or "Table", k), 2)
        end
    }
    setmetatable(proxy, mt)
    return proxy
end

function table.ReadUpdateOnly(tb, name)
    local proxy = {}
    local mt = {
        __index = tb, --允许访问的关键
        __newindex = function(t, k, v)
            if not t[k] then
                error(string.format("无法新增%s字段[%s]", name or "Table", k), 2)
            else
                rawset(t, k, v)
            end
        end
    }
    setmetatable(proxy, mt)
    return proxy
end

function table.New()
    local obj = CacheManager.Instance:Get(CacheDefine.PoolType.LuaTable)
    return obj.tb
end

function table.Recycle(tb)
    if IsFunction(tb.Recycle) then
        tb:Recycle()
    end
end

local _unpack = unpack or table.unpack
function table.SafeUpack(...)
    return _unpack(...)
end