local listmap = ListMap.New()
local removeIndex
for i = 1, 10 do
    removeIndex = listmap:Add("key_"..i, i)
end
print("添加数据",listmap:Size())

listmap:Remove("key_4")
listmap:RemoveByIndex(removeIndex)

-- local start = os.time()
listmap:Range(function (iter)
    print("iter:",iter.index,iter.key,iter.value)
end)
-- print("总值:",count)
-- print("遍历耗时:",os.difftime(os.time(),start))