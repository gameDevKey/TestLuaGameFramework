KvDataComponent = BaseClass("KvDataComponent",SECBComponent)

function KvDataComponent:__Init()
    self.kvData = {}
end

function KvDataComponent:__Delete()
end

function KvDataComponent:SetData(key,val)
    self.kvData[key] = val
end

function KvDataComponent:GetData(key)
    return self.kvData[key]
end