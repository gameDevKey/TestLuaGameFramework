TableUtils = SingleClass("TableUtils")

function TableUtils.ReadOnly (t,name)
    local proxy = {}
    local mt = {
     __index = t,
     __newindex = function (t,k,v)
        error(string.format("无法(修改、新增)%s字段[%s]",name or "Table",k) ,2)
     end
    }
    setmetatable(proxy,mt)
    return proxy
end

function TableUtils.ReadUpdateOnly (t,name)
    local proxy = t or {}
    local mt = {
     __newindex = function (t,k,v)
        error(string.format("无法(新增)%s字段[%s]",name or "Table",k),2)
     end
    }
    setmetatable(proxy,mt)
    return proxy
end

function TableUtils.CopyTable(st)
    if st == nil then return nil end
    if type(st) ~= "table" then
        return st
    end
    local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = TableUtils.CopyTable(v)
        end
    end
    return tab
end

function TableUtils.DeepCopy(obj)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(obj)
end


function TableUtils.NewTable()
    return {}
end


local function toString(value)
    if type(value)=='table' then
       return TableUtils.TableToString(value)
    elseif type(value)=='string' then
        return "\'"..value.."\'"
    else
       return tostring(value)
    end
end
function TableUtils.TableToString(t)
    if t == nil then return "" end
    local retstr= "{"

    local i = 1
    for key,value in pairs(t) do
        local signal = ","
        if i==1 then
          signal = ""
        end

        if key == i then
            retstr = retstr..signal..toString(value)
        else
            if type(key)=='number' or type(key) == 'string' then
                retstr = retstr..signal..'['..toString(key).."]="..toString(value)
            else
                if type(key)=='userdata' then
                    retstr = retstr..signal.."*s"..TableToStr(getmetatable(key)).."*e".."="..toString(value)
                else
                    retstr = retstr..signal..key.."="..toString(value)
                end
            end
        end

        i = i+1
    end

    retstr = retstr.."}"
    return retstr
end

function TableUtils.StringToTable(str)
    if str == nil or type(str) ~= "string" then
        return str
    end
    if jit then
        return loadstring("return" .. str)()
    else
        return load("return " .. str)()
    end
end

function TableUtils.CompList(src,dest,name)
	if #src ~= #dest then
		assert(false,string.format("数据长度不一致[%s]",name))
	end

	for i,v in ipairs(src) do
		local typeName = type(v)
		if typeName ~= "table" and v ~= dest[i] then
			assert(false,string.format("数据不一致[%s:%s]",name,i))
		elseif typeName == "table" then
			if TableUtils.IsArrayTable(v) then
				TableUtils.CompList(v,dest[i],string.format("%s-%s",name,i))
			else
				TableUtils.CompDict(v,dest[i],string.format("%s-%s",name,i))
			end
		end
	end
end

function TableUtils.CompDict(src,dest,name)
	for k,v in pairs(src) do
		if not dest[k] then
			assert(false,string.format("数据丢失[%s]",k))
		end

		local typeName = type(v)
		if typeName ~= "table" and v ~= dest[k] then
			assert(false,string.format("数据不一致[%s]",k))
		elseif typeName == "table" then
			if TableUtils.IsArrayTable(v) then
				TableUtils.CompList(v,dest[k],k)
			else
				TableUtils.CompDict(v,dest[k],k)
			end
		end
	end
end

function TableUtils.IsArrayTable(data)
	local len = #data
	if len <= 0 then
		return false
	end

	local lastIndex = 0
	for i,v in pairs(data) do
		if type(i) ~= "number" then
			return false
		end

		if i > len then
			return false
		end

		if lastIndex + 1 ~= i then
			return false
		else
			lastIndex = i
		end
	end

	return true
end

function TableUtils.IsEmpty(tb)
    if not tb or type(tb) ~= "table" then
        return true
    end
    return next(tb) == nil
end

function TableUtils.IsValid(tb)
    return not TableUtils.IsEmpty(tb)
end

function TableUtils.GetTableLength(tb)
    local count = 0
    for key, value in pairs(tb or {}) do
        count = count + 1
    end
    return count
end

function TableUtils.ContainValue(tb,target)
    for key, value in pairs(tb or {}) do
        if value == target then
            return true, key
        end
    end
    return false
end

function TableUtils.ContainKey(tb,target)
    for key, value in pairs(tb or {}) do
        if key == target then
            return true, value
        end
    end
    return false
end