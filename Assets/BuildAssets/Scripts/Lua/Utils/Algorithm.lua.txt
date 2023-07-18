Algorithm = StaticClass("Algorithm")
local random = math.random

---权重随机
---@param weights table 输入一个整型权重数组，比如{10,50,20}，不要输入小数
---@return integer index 返回一个数组对应的索引，代表本次随机的结果
function Algorithm.GetRandomIndexByWeights(weights)
    local total = 0
    for _, weight in ipairs(weights) do
        total = total + weight
    end
    local result = random(0,total)
    local last = 0
    for i, weight in ipairs(weights) do
        if result >= last and result <= (last + weight) then
            return i
        end
        last = last + weight
    end
    return 0
end

---二分查找法
---@param list table 有序数组
---@param target any 目标值
---@return integer index 目标值的索引，-1表示找不到目标
function Algorithm.BinarySearch(list,target)
    local low = 1
    local high = #list
    local mid = nil
    while(low <= high) do
        if list[low] == target then
            return low
        end
        if list[high] == target then
            return high
        end
        mid = math.floor(low + (high - low) / 2)
        mid = MathUtil.Clamp(mid, 1, high)
        if list[mid] == target then
            return mid
        end
        if list[mid] < target then
            low = mid + 1
        else
            high = mid -1
        end
    end
    return -1
end

return Algorithm