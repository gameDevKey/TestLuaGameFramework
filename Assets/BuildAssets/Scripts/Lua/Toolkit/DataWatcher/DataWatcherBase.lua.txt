--值监听器基类
DataWatcherBase = Class("DataWatcherBase")

function DataWatcherBase:OnInit()
    self.data = nil
    self.changeFunc = nil
    self.compareFunc = nil
end

function DataWatcherBase:OnDelete()
    local _ = self.changeFunc and self.changeFunc:Delete()
    local _ = self.compareFunc and self.compareFunc:Delete()
end

---设置值变化回调(args拼接在回调的首位)
function DataWatcherBase:SetChangeFunc(callback, caller, args)
    self.changeFunc = CallObject.New(callback, caller, args)
end

function DataWatcherBase:SetChangeFuncByCallObject(callObject)
    self.changeFunc = callObject
end

---设置比较函数, 返回false表示有值发生变化(args拼接在回调的首位)
function DataWatcherBase:SetCompareFunc(callback, caller, args)
    self.compareFunc = CallObject.New(callback, caller, args)
end

function DataWatcherBase:SetCompareFuncByCallObject(callObject)
    self.compareFunc = callObject
end

function DataWatcherBase:SetVal(...)
end

function DataWatcherBase:GetVal(...)
    return nil
end

return DataWatcherBase