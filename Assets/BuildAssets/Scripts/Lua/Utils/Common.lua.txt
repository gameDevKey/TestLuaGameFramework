local unpack = unpack or table.unpack

function IsTable(input)
    return type(input) == "table"
end

function IsString(input)
    return type(input) == "string"
end

function IsNumber(input)
    return type(input) == "number"
end

function IsBoolean(input)
    return type(input) == "boolean"
end

function IsFunction(input)
    return type(input) == "function"
end

function IsUserdata(input)
    return type(input) == "userdata"
end

function IsClass(input)
    return IsTable(input) and input._isClass == true or false
end

function IsInterface(input)
    return IsTable(input) and input._isInterface == true or false
end

local function GetCurrentTimeString()
    return os.date("%H:%M:%S", os.time())
end

function PrintAny(...)
    if not PRINT_SWITCH then
        return
    end
    local time = nil
    if PRINT_LOG_WITH_TIME then
        time = GetCurrentTimeString()
    end
    local tb = {}
    for _, obj in ipairs({ ... }) do
        if IsClass(obj) then
            table.insert(tb, tostring(obj))
        elseif IsTable(obj) then
            table.insert(tb, table.ToString(obj))
        else
            table.insert(tb, tostring(obj))
        end
    end
    local str = table.concat(tb, ' ')
    if time then
        print(time, str)
    else
        print(str)
    end
end

function PrintLog(...)
    PrintAny("[LOG]", ...)
end

function PrintWarning(...)
    PrintAny("[WARNING]", ...)
end

function PrintError(...)
    if not PRINT_SWITCH then
        return
    end
    local tb = { ... }
    table.insert(tb, "\n" .. debug.traceback())
    PrintAny("[ERROR]", unpack(tb))
end

function PrintGuide(...)
    if not PRINT_GUIDE then
        return
    end
    PrintAny("[GUIDE]", ...)
end

local function _copy(lookup_table, object, copyMeta)
    if not IsTable(object) then
        return object
    end
    if lookup_table[object] then
        return lookup_table[object]
    end
    local newObject = {}
    lookup_table[object] = newObject
    for k, v in pairs(object) do
        newObject[_copy(lookup_table, k, copyMeta)] = _copy(lookup_table, v, copyMeta)
    end
    if copyMeta then
        return setmetatable(newObject, getmetatable(object))
    end
    return newObject
end

---深复制
---@param object ModuleBase 任意对象
---@param copyMeta boolean 是否需要复制metatable
---@return ModuleBase
function Copy(object, copyMeta)
    local lookup_table = {}
    return _copy(lookup_table, object, copyMeta)
end

---返回自增整数的闭包函数
---@return function 自增整数的闭包函数
function GetAutoIncreaseFunc()
    local count = 0
    return function()
        count = count + 1
        return count
    end
end

---同步调用异步函数
---@param asyncFunc function 异步函数
---@param callbackPos integer|nil 回调位置，默认在所有参数之后
---@return function syncFunc 同步函数
function AsyncToSync(asyncFunc, callbackPos)
    return function(...)
        local rets
        local waiting = false
        local co = coroutine.running() or error("this function must be run in coroutine")

        local callback = function(...)
            if waiting then
                assert(coroutine.resume(co, ...))
            else
                rets = { ... }
            end
        end

        local args = { ... }
        table.insert(args, callbackPos or (#args + 1), callback)

        asyncFunc(table.unpack(args))

        -- rets 为空，代表函数调用没有立即返回结果，此时挂起协程
        if rets == nil then
            waiting = true
            rets = { coroutine.yield() }
        end

        return table.unpack(rets)
    end
end
