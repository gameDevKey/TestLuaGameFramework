--Table监听器
--包含函数:SetCompareFunc(callback, caller, args)   @params callback(key,new,old):function
--包含函数:SetChangeFunc(callback, caller, args)   @params callback(key,new,old):function
TableDataWatcher = Class("TableDataWatcher",DataWatcherBase)

function TableDataWatcher:OnInit()
    self.kvs = {}
end

function TableDataWatcher:OnDelete()
    for key, value in pairs(self.kvs) do
        value:Delete()
    end
end

function TableDataWatcher:SetVal(key,val,forceChange)
    if not self.kvs[key] then
        self.kvs[key] = DataWatcher.New()
        self.kvs[key]:SetChangeFunc(self:ToFunc("HandleChange"),nil,key)
        self.kvs[key]:SetCompareFunc(self:ToFunc("HandleCompare"),nil,key)
    end
    self.kvs[key]:SetVal(val,forceChange)
end

function TableDataWatcher:GetVal(key)
    return self.kvs[key] and self.kvs[key]:GetVal()
end

function TableDataWatcher:HandleChange(key,new,old)
    if self.changeFunc then
        self.changeFunc:Invoke(key,new,old)
    end
end

function TableDataWatcher:HandleCompare(key,new,old)
    if self.compareFunc then
        return self.compareFunc:Invoke(key,new,old)
    end
    return new == old
end

return TableDataWatcher