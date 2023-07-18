MathUtil = StaticClass("MathUtil")

local randomseed = math.randomseed
local sqrt = math.sqrt

function MathUtil.GetDistance2D(x1, y1, x2, y2)
    local x = x1 - x2
    local y = y1 - y2
    return sqrt(x * x + y * y)
end

function MathUtil.Clamp(value, min, max)
    if min and max and min > max then
        local temp = min
        min = max
        max = temp
    end
    if min and value < min then
        value = min
    end
    if max and value > max then
        value = max
    end
    return value
end

---十进制转二进制
---@param num integer           十进制数字
---@param maxBit integer|nil    位数, 默认32位
---@param tostring boolean|nil  是否转字符串
---@return table|string
function MathUtil.DecToBin(num, maxBit, tostring)
    maxBit = maxBit or 32
    local result = {}
    for i = maxBit - 1, 0, -1 do
        local j = 2 ^ i
        result[#result + 1] = math.floor(num / j)
        num = num % j
    end
    if tostring then
        return table.concat(result)
    end
    return result
end

---保留n位小数
---@param num number 任意数字
---@param n integer|nil 保留多少位小数，比如保留两位小数 0.918 => 0.92
---@return number
function MathUtil.GetPreciseDecimal(num, n)
    n = n or 0
    if n < 0 then n = 0 end
    local weight = 10 ^ n
    return math.ceil(num * weight) / weight
end

function MathUtil.RandomSeed(seed)
    randomseed(seed or tostring(os.time()):reverse():sub(1, 6))
end

return MathUtil