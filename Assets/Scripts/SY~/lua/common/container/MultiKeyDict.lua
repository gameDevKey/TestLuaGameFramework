local setmetatable = setmetatable

local MultiKeyDict = {}
MultiKeyDict.__index = MultiKeyDict

function MultiKeyDict.New(...)
    local dict = {}
    dict.index = 0
    dict.data = {}
    dict.keys = {}

    local keyTypes = {...}
    for i,v in ipairs(keyTypes) do dict.keys[v] = {} end

	return setmetatable(dict, MultiKeyDict)
end

function MultiKeyDict:Get(keyType,key)
    local index = self.keys[keyType][key]
    local data = self.data[index]
    return data,index
end

function MultiKeyDict:GetIndex(keyType,key)
    
end

function MultiKeyDict:AddKeyIndex(keyType,key,index)
    self.keys[keyType][key] = index
end

function MultiKeyDict:AddData(keyType,key,data)
    self.index = self.index + 1
    self.data[self.index] = data
    self.keys[keyType][key] = self.index
end