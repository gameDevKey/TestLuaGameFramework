CacheManager = SingletonClass("CacheManager",nil,{ICache})

function CacheManager:OnInit()
    self.pools = {}
end

function CacheManager:OnDelete()
    for _, pool in ipairs(self.pools or NIL_TABLE) do
        pool:Delete()
    end
    self.pools = nil
end

function CacheManager:Get(poolType)
    return self:GetPool(poolType,true):Get()
end

function CacheManager:Recycle(item)
    local pool = item:GetPool()
    if not pool then
        PrintError("找不到回收池:",item)
        return
    end
    pool:Recycle(item)
end

function CacheManager:GetPool(poolType,force)
    if not self.pools[poolType] and force then
        local config = CacheDefine.BindInfo[poolType]
        if not config then
            PrintError("找不到回收池绑定数据",CacheDefine.PoolType[poolType])
            return
        end
        self.pools[poolType] = _G[config.PoolClass].New(poolType)
    end
    return self.pools[poolType]
end

return CacheManager