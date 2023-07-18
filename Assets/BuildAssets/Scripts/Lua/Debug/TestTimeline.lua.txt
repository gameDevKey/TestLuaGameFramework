local data = require("Data.Timeline.TimelineTemplate")

local handler = {}

handler.DoSomething1 = function ()
    print("DoSomething1")
end
handler.DoSomething2 = function ()
    print("DoSomething2")
end
handler.DoSomething3 = function ()
    print("DoSomething3")
end

local t = TimelineBase.New(data,{
    actionHandler = handler,
    finishFunc = function ()
        print("结束")
    end
})

print("模拟Update:1s")
t:Update(1)
print("模拟Update:2s")
t:Update(1)
print("模拟Update:3s")
t:Update(1)
print("模拟Update:4s")
t:Update(1)