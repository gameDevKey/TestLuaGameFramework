CacheItemBase = Class("CacheItemBase")

function CacheItemBase:OnInit()
end

function CacheItemBase:OnDelete()
    self:SetPool(nil)
    self:Recycle()
end

function CacheItemBase:SetPool(pool)
    self.pool = pool
end

function CacheItemBase:GetPool()
    return self.pool
end

--外界调用，创建或者复用都会被调用
function CacheItemBase:Use(data)
    self.isCache = false
    self.data = data
    self:CallFuncDeeply("OnUse",true)
end

--实例直接调用，通知对应的池回收自己，方便调用
function CacheItemBase:Recycle()
    if self.isCache then
        return
    end
    self.pool:Recycle(self)
end

--外界调用
function CacheItemBase:HandleRecycle()
    self.isCache = true
    self:CallFuncDeeply("OnRecycle",false)
end

function CacheItemBase:ResetField()
    for key, value in pairs(self._cache_defaults or NIL_TABLE) do
        self[key] = value
    end
    for key, value in pairs(self._cache_nils or NIL_TABLE) do
        self[key] = nil
    end
end

--#region 虚函数
function CacheItemBase:OnUse()

end
function CacheItemBase:OnRecycle()
    self:ResetField()
end
--#endregion

return CacheItemBase