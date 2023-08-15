--保证顺序的字典
ListMap = Class("ListMap")

function ListMap:OnInit()
    self.dict = {}
    self.list = {}
    self.size = 0
    self.index = 0
end

function ListMap:OnDelete()
    self.dict = nil
    self.list = nil
end

function ListMap:Add(key, data)
    if self.dict[key] then
        PrintError("[ListMap]键重复", key)
        return
    end
    self.index = self.index + 1
    self.size = self.size + 1
    self.dict[key] = { key = key, value = data, index = self.index }
    self.list[self.index] = self.dict[key]
    return self.index
end

function ListMap:Remove(key)
    if not self.dict[key] then
        return
    end
    local data = self.dict[key]
    self.size = self.size - 1
    self.dict[key] = nil
    self.list[data.index] = nil
end

function ListMap:RemoveByIndex(index)
    if not self.list[index] then
        return
    end
    local data = self.list[index]
    self:Remove(data.key)
end

function ListMap:Get(key)
    return self.dict[key]
end

function ListMap:GetVal(key)
    return self.dict[key] and self.dict[key].value
end

function ListMap:Range(func, caller)
    for key, value in pairs(self.list) do
        if caller then
            func(caller, value)
        else
            func(value)
        end
    end
end

function ListMap:RangeByCallObject(callObject)
    for key, value in pairs(self.list) do
        callObject:Invoke(value)
    end
end

function ListMap:Size()
    return self.size
end

return ListMap
