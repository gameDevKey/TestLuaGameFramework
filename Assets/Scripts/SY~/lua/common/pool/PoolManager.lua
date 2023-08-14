PoolManager = SingleClass("PoolManager")

function PoolManager:__Init()
    self.poolDict={}

    self.deltaTime = 0
    self.releaseTime = 5
    if GDefine.platform  == RuntimePlatform.IPhonePlayer then self.releaseTime = 2.5 end

    self.poolParent =  GameObject("Pool")
    UnityUtils.SetLocalPosition(self.poolParent.transform,-10000,0,0)
    GameObject.DontDestroyOnLoad(self.poolParent)
    self.poolParent.gameObject:SetActive(false)

    for k,v in pairs(PoolDefine.poolMappings) do self:CreatePool(k,v) end

    if GDefine.isDebug then self.debugObjects = {} end
end

function PoolManager:CreatePool(poolName,poolClass)
    local poolObj = GameObject(poolName)
    poolObj.transform:SetParent(self.poolParent.transform)
    UnityUtils.SetLocalPosition(poolObj.transform,0,0,0)
    self.poolDict[poolName] = poolClass.New()
    self.poolDict[poolName].transform = poolObj.transform
end

function PoolManager:Push(poolType,poolKey,poolObj)
    assert(self.poolDict[poolType] ~= nil, string.format("传入的对象池类型不存在[类型:%s]",tostring(poolType)))
    assert(poolKey and poolKey ~= "", string.format("传入的对象池Key值为空[Key:%s]",tostring(poolKey)))
    assert(poolObj ~= nil, string.format("对象池尝试放入空对象[类型:%s][Key:%s]",tostring(poolType),tostring(poolKey)))
    if self:CheckSameObject(poolType,poolKey,poolObj) then return end
    self.poolDict[poolType]:Push(poolKey,poolObj)
end

function PoolManager:CheckSameObject(poolType,poolKey,poolObj)
    if self.poolDict[poolType].notCheckSame then
        return false
    end

    if not GDefine.isDebug then 
        return false 
    end

    if self.debugObjects[poolObj] then 
        LogError(string.format("池对象被重复放入[类型:%s][Key:%s]上次放入堆栈:\n%s",poolType,poolKey,self.debugObjects[poolObj])) 
        return true
    end

    --self.debugObjects[poolObj] = debug.traceback()
    return false
end

function PoolManager:Pop(poolType,poolkey)
    if not self.poolDict[poolType] then return end
    local poolObject = self.poolDict[poolType]:Pop(poolkey)
    self:RemoveSameObject(poolType,poolkey,poolObject)
    return poolObject
end

function PoolManager:RemoveSameObject(poolType,poolKey,poolObj)
    if self.poolDict[poolType].notCheckSame then
        return
    end

    if not GDefine.isDebug or not self.debugObjects[poolObj] then
        return
    end

    self.debugObjects[poolObj] = nil
end

function PoolManager:Has(poolType,poolkey)
    if not self.poolDict[poolType] then return false end
    return self.poolDict[poolType]:Has(poolkey)
end

function PoolManager:Update()
    self.deltaTime = self.deltaTime + Time.deltaTime
    if self.deltaTime < self.releaseTime then return end
    for k,v in pairs(self.poolDict) do v:OnCheckClear() end
    self.deltaTime = 0
end

function PoolManager:CheckClearPool(poolType)
    if self.poolDict[poolType] == nil then return end
    self.poolDict[poolType]:OnCheckClear()
end

function PoolManager:CleanByType(poolType)
    if not self.poolDict[poolType] then return end
    self.poolDict[poolType]:Clean()
end

function PoolManager:ClearPoolByKey(poolType,poolkey)
    if not self.poolDict[poolType] then return end
    self.poolDict[poolType]:ClearPoolByKey(poolkey)
end

function PoolManager:Clean()
    for k,v in pairs(self.poolDict) do v:Clean() end
end