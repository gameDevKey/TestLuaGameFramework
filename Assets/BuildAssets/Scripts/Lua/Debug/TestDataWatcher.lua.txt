local kv = TableDataWatcher.New()
kv:SetChangeFunc(function (key,new,old)
    PrintLog("kv变化 键",key,"值",old,'->',new)
end)
kv:SetCompareFunc(function (key,a,b)
    -- PrintLog("kv比较",key,a,b)
    return a == b
end)
kv:SetVal("Key",1)
kv:SetVal("A",2)
kv:SetVal("A",3)
kv:SetVal("A",4)

kv:Delete()