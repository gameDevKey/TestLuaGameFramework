StringUtils = SingleClass("StringUtils")

function StringUtils.Split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function StringUtils.GetStrLen(str)
	local len = 0
	local off = 0
	local charLen = string.len(str)
	local i, j = 1, 1
	while i <= charLen do
		local c = string.byte(str, i)
		if c > 0 and c <= 127 then  --英文数字字母
			j = 1
			off = 1
		elseif(c >= 192 and c <= 223) then
			j = 2
			off = 2
		elseif(c >= 224 and c <= 239) then --中文字
			j = 3
			off = 2
		elseif(c >= 240 and c <= 247) then
			j = 4
			off = 2
		end
		i = i + j
		len = len + off
	end
	return len
end

function StringUtils.Trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

--判断字符串是否为nil或者长度为0
function StringUtils.IsEmpty(str)
    return str == nil or string.len(str) == 0
end


--计算utf8字符串的长度
function StringUtils.UTF8len(str)
    local len  = string.len(str)
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(str, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

--判断字符串只有数字
function StringUtils.IsOnlyNumber(str)
	if str == nil or string.len(str) == 0 then
		return false
	end
	local charLen = string.len(str)
	local i = 1
	while i <= charLen do
		local c = string.byte(str, i)
		if c < 48 or c > 57 then
			return false
		end
		i = i + 1
	end
	return true
end

-- 将每个字符分离出来，放到table中，一个单元内一个字符
function StringUtils.SplitToTable(s)
    local tb = {}
    
    --[[
    UTF8的编码规则：
    1. 字符的第一个字节范围： 0x00—0x7F(0-127),或者 0xC2—0xF4(194-244); UTF8 是兼容 ascii 的，所以 0~127 就和 ascii 完全一致
    2. 0xC0, 0xC1,0xF5—0xFF(192, 193 和 245-255)不会出现在UTF8编码中 
    3. 0x80—0xBF(128-191)只会出现在第二个及随后的编码中(针对多字节编码，如汉字) 
    ]]
    for utfChar in string.gmatch(s, "[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(tb, utfChar)
    end
    
    return tb
end

--[[将字符串根据"#n#"占位标志切割，返回 arr 与 placeholder 两个列表。其中placeholder列表记录"#n#"占位标志的索引位置
    例:
    "赢#1#场"
    -> arr[1]="赢",arr[2]="#",arr[3]="场";
    -> placeholder[1]=2

    "至少使用#1#个#2#打pvp#3#场"
    -> arr[1]="至少使用",arr[2]="#",arr[3]="个",arr[4]="#",arr[5]="打pvp",arr[6]="#",arr[7]="场"
    -> placeholder[1]=2,placeholder[2]=4,placeholder[3]=6
--]]
function StringUtils.SplitBySharp(input)
    local arr = {}
    local placeholder = {}

    local tb = StringUtils.SplitToTable(input)
	local str = ""
    for pos, char in ipairs(tb) do
		if char ~= '#' then
			str = str..char
		else
			table.insert(arr,str)
			str = char
			table.insert(arr,str)
			str = ""
			table.insert(placeholder,#arr)

			local count = 1
			local index = pos
			repeat
				index = index+1
				count = count + 1
			until(tb[index]~='#')

			for i=1, count do
				table.remove(tb,pos)
			end
		end
    end
	table.insert(arr,str)

    return arr, placeholder
end