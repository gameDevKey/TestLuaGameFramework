CacheLuaTable = Class("CacheLuaTable",CacheItemBase)

function CacheLuaTable:OnInit()
    self.tb = {}
    self.tb.Recycle = self:ToFunc("Recycle")
end

function CacheLuaTable:OnDelete()
    self.tb = nil
end

function CacheLuaTable:OnUse()
end

function CacheLuaTable:OnRecycle()
    for key, value in pairs(self.tb) do
        if key ~= "Recycle" then
            self.tb[key] = nil
        end
    end
end

return CacheLuaTable