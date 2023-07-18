TestItemPool = Class("TestItemPool",CachePoolBase)

function TestItemPool:OnBeforeGet(obj)
    -- PrintLog("TestItemPool:OnBeforeGet",obj)
end

function TestItemPool:OnAfterGet(obj)
    -- PrintLog("TestItemPool:OnAfterGet",obj)
    -- for key, value in pairs(obj) do
    --     PrintLog("使用后包含字段",key,value)
    -- end
end

function TestItemPool:OnBeforeRecycle(obj)
    -- PrintLog("TestItemPool:OnBeforeRecycle",obj)
end

function TestItemPool:OnAfterRecycle(obj)
    -- PrintLog("TestItemPool:OnAfterRecycle",obj)
    -- for key, value in pairs(obj) do
    --     PrintLog("回收后包含字段",key,value)
    -- end
end

return TestItemPool