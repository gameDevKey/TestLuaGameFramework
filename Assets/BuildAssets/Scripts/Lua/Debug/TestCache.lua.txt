-- local tb = {}
-- tb.BOOL = true
-- tb.INT = 0

-- local obj = {}
-- obj.fields = {}
-- setmetatable(obj,{
--     __index = function (k,v)
--         obj.fields[k] = v
--         print('see obj:',k,v)
--     end
-- })
-- obj.INT = 10
-- print("range")
-- for key, value in pairs(obj) do
--     print(key,value)
-- end

collectgarbage("collect")
print("开始前的count",collectgarbage("count"))

local tb = {}

print("创建tb的count",collectgarbage("count"))

tb = nil

collectgarbage("collect")

print("gc后的count",collectgarbage("count"))