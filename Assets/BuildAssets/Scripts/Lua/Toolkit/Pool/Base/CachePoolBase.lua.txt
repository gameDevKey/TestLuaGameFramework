CachePoolBase = Class("CachePoolBase",nil,{ICache})

function CachePoolBase:OnInit(poolType,poolData)
    self.activePool = {}
    self.recyclePool = {}

    self.poolType = poolType
    self.poolData = poolData
    self.config = CacheDefine.BindInfo[poolType]
    self.maxAmount = self.config.MaxAmount or 0
    self.preloadAmount = self.config.PreloadAmount or 0
    self.itemCls = _G[self.config.ItemClass]

    self:Preload()
end

function CachePoolBase:OnDelete()
    for _, pool in ipairs({self.activePool,self.recyclePool}) do
        for _, obj in ipairs(pool) do
            obj:Delete()
        end
        pool = {}
    end
    self.itemCls = nil
end

function CachePoolBase:Preload()
    if self.preloadAmount > 0 then
        for i = 1, self.preloadAmount do
            table.insert(self.recyclePool, self.itemCls.New())
        end
        self:CheckMaxLimit()
    end
end

function CachePoolBase:Get(data)
    local obj = nil
    if #self.recyclePool > 0 then
        obj = table.remove(self.recyclePool)
    else
        obj = self.itemCls.New()
    end
    if obj ~= nil then
        self:CallFuncDeeply("OnBeforeGet",true,obj)
        obj:SetPool(self)
        table.insert(self.activePool, obj)
        obj:Use(data)
        self:CallFuncDeeply("OnAfterGet",true,obj)
    end
    return obj
end

function CachePoolBase:Recycle(obj)
    local _,idx = table.Contain(self.activePool, obj)
    if idx then
        table.remove(self.activePool,idx)
    end
    if not table.Contain(self.recyclePool, obj) then
        self:CallFuncDeeply("OnBeforeRecycle",false,obj)
        table.insert(self.recyclePool, obj)
        obj:HandleRecycle()
        self:CallFuncDeeply("OnAfterRecycle",false,obj)
    end
    self:CheckMaxLimit()
end

function CachePoolBase:CheckMaxLimit()
    if self.maxAmount > 0 then
        for i = #self.recyclePool - self.maxAmount, 1, -1 do
            local item = table.remove(self.recyclePool)
            item:Delete()
        end
    end
end

function CachePoolBase:Log()
    PrintLog(self,string.format("激活池:%d 回收池:%d", #self.activePool ,#self.recyclePool))
end

--#region 虚函数
function CachePoolBase:OnBeforeGet(obj) end
function CachePoolBase:OnAfterGet(obj) end
function CachePoolBase:OnBeforeRecycle(obj) end
function CachePoolBase:OnAfterRecycle(obj) end
--#endregion

return CachePoolBase
