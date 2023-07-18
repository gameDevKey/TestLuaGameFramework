--值监听器
--包含函数:SetCompareFunc(callback, caller, args)   @params callback(new,old):function
--包含函数:SetChangeFunc(callback, caller, args)   @params callback(new,old):function
DataWatcher = Class("DataWatcher",DataWatcherBase)

function DataWatcher:OnInit()
    self.data = nil
end

function DataWatcher:OnDelete()
end

function DataWatcher:SetVal(val,forceChange)
    local change = false
    if forceChange then
        change = true
    else
        if self.data ~= nil then
            if self.compareFunc then
                if not self.compareFunc:Invoke(val,self.data) then
                    change = true
                end
            else
                change = self.data ~= val
            end
        end
    end
    local old = self.data
    self.data = val
    if change then
        self.changeFunc:Invoke(self.data,old)
    end
end

function DataWatcher:GetVal()
    return self.data
end

return DataWatcher