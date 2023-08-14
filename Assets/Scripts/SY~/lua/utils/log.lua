Print = Print or {}

local color = "<color=#FF2F00FF>"

local unityLog = nil
local unityLogError = nil

if IS_CHECK then
    unityLog = print
    unityLogError = print
else
    unityLog = CS.UnityEngine.Debug.Log
    unityLogError = CS.UnityEngine.Debug.LogError
end

local uid = 0

function Log(...)
    if not IS_DEBUG then return end
    uid = uid + 1
    unityLog("[" .. uid .. "]" ..table.concat({...}, ",").."\r\n"..debug.traceback())
end

function Logf(log,...)
    if not IS_DEBUG then return end
    log = string.format(log,...)
    uid = uid + 1
    unityLog("[" .. uid .. "]" ..log.."\r\n"..debug.traceback())
end

function LogColor(...)
    --if not IS_DEBUG then return end
    uid = uid + 1
    unityLog("[" .. uid .. "]" ..color..table.concat({...}, ",").."</color>\r\n"..debug.traceback())
end

function LogColorf(log,...)
    --if not IS_DEBUG then return end
    --log = string.format(log,...)
    uid = uid + 1
    unityLog("[" .. uid .. "]" ..color..log.."</color>\r\n"..debug.traceback())
end

function LogError(...)
    uid = uid + 1
    unityLogError("[" .. uid .. "]" ..table.concat({...}, ",").."\r\n"..debug.traceback())
end

function LogErrorf(log,...)
    log = string.format(log,...)
    uid = uid + 1
    unityLogError("[" .. uid .. "]" .. log.."\r\n"..debug.traceback())
end

function LogInfo(...)
    uid = uid + 1
    unityLog("[" .. uid .. "]" .. table.concat({...}, ",").."\r\n"..debug.traceback())
end

function LogInfof(log,...)
    log = string.format(log,...)
    uid = uid + 1
    unityLog("[" .. uid .. "]" .. log.."\r\n"..debug.traceback())
end

function LogTableInfo(tableName,tableData)
    local str = Print.TableToString(tableData)
    LogInfo(tableName..":"..str)
end

function LogTable(tableName,tableData)
    if not IS_DEBUG then return end
    local str = Print.TableToString(tableData)
    Log(tableName..":"..str)
end

function LogErrorTable(tableName,tableData)
    local str = Print.TableToString(tableData)
    LogError(tableName..":"..str)
end

function Print.TableToString(...)
    local args = {...}
    for k,arg in ipairs(args) do
        if type(arg) == 'table'
            or type(arg) == 'boolean'
            or type(arg) == 'function'
            or type(arg) == 'userdata' then
            args[k] = Print.ToString(arg)
        end
    end
    args[#args+1] = "nil"
    args[#args+1] = "nil"
    args[#args+1] = "nil"
    return unpack and unpack(args) or table.unpack(args)
end

function Print.ToString(value, indent, vmap)
    local str = ''
    indent = indent or ''
    vmap = vmap or {}

    --µÝ¹é½áÊøÌõ¼þ
    if (type(value) ~= 'table') then
        if (type(value) == 'string') then
            --×Ö·û´®
            str = string.format('"%s"', value)
        else
            --ÕûÊý
            str = tostring(value)
        end
    else
        if type(vmap) == 'table' then
            if vmap[value] then return '('..tostring(value)..')' end
            vmap[value] = true
        end

        local auxTable = {}     --±£´æÔª±íKEY(·ÇÕûÊý)
        local iauxTable = {}    --±£´æÔª±ívalue
        local iiauxTable = {}   --±£´æÊý×é(keyÎª0)
		for k, v in pairs(value) do
			if type(k) == 'number' then
				if k == 0 then
					table.insert(iiauxTable, k)
				else
					table.insert(iauxTable, k)
				end
			elseif type(k) ~= 'table' then
				table.insert(auxTable, k)
			end
		end
        --table.sort(iauxTable)

        str = str..'{\n'
        local separator = ""
        local entry = "\n"
        local barray = true
        local kk,vv
		for k, v in pairs(iauxTable) do
			if k == v and barray then
				entry = Print.ToString(value[v], indent..'  \t', vmap)
				str = str..separator..indent..'  \t'..entry
				separator = ", \n"
			else
				barray = false
				table.insert(iiauxTable, v)
			end
		end
        table.sort(iiauxTable)
		
		for i, fieldName in pairs(iiauxTable) do
			kk = tostring(fieldName)
			if type(fieldName) == "number" then
				kk = '['..kk.."]"
			end
			entry = kk .. " = " .. Print.ToString(value[fieldName],indent..'  \t',vmap)

			str = str..separator..indent..'  \t'..entry
			separator = ", \n"
		end

        table.sort(auxTable)
		for i, fieldName in pairs(auxTable) do
			kk = tostring(fieldName)
			if type(fieldName) == "number" then
				kk = '['..kk.."]"
			end
			vv = value[fieldName]
			entry = kk .. " = " .. Print.ToString(value[fieldName],indent..'  \t',vmap)

			str = str..separator..indent..'  \t'..entry
			separator = ", \n"
		end


        str = str..'\n'..indent..'}'
    end

    return str
end

function LogAny(...)
    if not IS_DEBUG then return end
    uid = uid + 1
    local infos = {}
    for _, arg in pairs({...}) do
        local info
        if type(arg) == "table" then
            info = Print.TableToString(arg)
        else
            info = tostring(arg)
        end
        table.insert(infos,info)
    end
    unityLog(string.format("[%d]%s\r\n%s", uid, table.concat(infos, ", "),debug.traceback()))
end

function LogErrorAny(...)
    if not IS_DEBUG then return end
    uid = uid + 1
    local infos = {}
    for _, arg in pairs({...}) do
        local info
        if type(arg) == "table" then
            info = Print.TableToString(arg)
        else
            info = tostring(arg)
        end
        table.insert(infos,info)
    end
    unityLogError(string.format("[%d]%s\r\n%s", uid, table.concat(infos, ", "),debug.traceback()))
end

DEBUG_LOG_YQH = true
function LogYqh(...)
    if not DEBUG_LOG_YQH then
        return
    end
    LogAny("@yqh@",...)
end

DEBUG_LOG_GUIDE = true
function LogGuide(...)
    if not DEBUG_LOG_GUIDE then
        return
    end
    LogAny("[引导]",...)
end