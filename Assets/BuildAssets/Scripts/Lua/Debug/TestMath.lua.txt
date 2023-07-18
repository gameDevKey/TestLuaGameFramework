-- local list = {}
-- for i = 1, 500000 do
--     table.insert(list, i)
-- end

-- local start = os.time()
-- for i = 1, 500000, 1 do
--     local targetIndex = math.random(1, #list)
--     -- print("目标值",list[targetIndex])
--     local result = MathUtil.BinarySearch(list,list[targetIndex])
--     -- print('索引',result)
-- end
-- print("查询耗时",os.difftime(os.time(),start))

local result = {}
for i = 1, 100000 do
    local index = Algorithm.GetRandomIndexByWeights({1,2,3,4,5})
    if not result[index] then
        result[index] = 0
    end
    result[index] = result[index] + 1
end
for index, count in pairs(result) do
    print("权重随机分布",index,count)
end