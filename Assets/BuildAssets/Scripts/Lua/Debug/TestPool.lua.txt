-- local pool = CacheManager.Instance:GetPool(CacheDefine.PoolType.Test,true)

-- local obj = CacheManager.Instance:Get(CacheDefine.PoolType.Test)
-- pool:Log()
-- CacheManager.Instance:Recycle(obj)
-- pool:Log()
-- local obj = CacheManager.Instance:Get(CacheDefine.PoolType.Test)
-- pool:Log()
-- CacheManager.Instance:Recycle(obj)
-- pool:Log()
-- CacheManager.Instance:Get(CacheDefine.PoolType.Test)
-- pool:Log()
-- CacheManager.Instance:Get(CacheDefine.PoolType.Test)
-- pool:Log()
-- CacheManager.Instance:Get(CacheDefine.PoolType.Test)
-- pool:Log()

-- local tb = table.New()
-- LuaTablePool.LogTb()
-- tb.mark = "yqh"
-- for key, value in pairs(tb) do
--     PrintLog("回收前",key,value)
-- end
-- tb:Recycle()
-- LuaTablePool.LogTb()
-- for key, value in pairs(tb) do
--     PrintLog("回收后",key,value)
-- end

-- table.New()
-- table.New()
-- table.New()
-- LuaTablePool.LogTb()

print("当前内存",collectgarbage("count"))
local tbs = {}
for i = 1, 1000 do
    table.insert(tbs,table.New())
end
LuaTablePool.LogTb()

print("创建1000个tb，当前内存",collectgarbage("count"))

for _, tb in pairs(tbs) do
    tb:Recycle()
end
tbs = nil
LuaTablePool.LogTb()

collectgarbage("collect")
print("回收1000个tb，当前内存",collectgarbage("count"))

for i = 1, 1000 do
    table.New()
end
LuaTablePool.LogTb()

print("复用1000个tb，当前内存",collectgarbage("count"))