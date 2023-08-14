BasePool = BaseClass("BasePool")

local objectName = "%s(%s)"

function BasePool:__Init()
    self.transform = nil
    self.poolDict = {}
    self.latelyUseList = List.New()
    self.latelyUseIterDict = {}
    self.count = 0
    self.parentObjectDict = {}
end

function BasePool:__Delete()

end

function BasePool:Push(poolKey,poolObj)
    if not self:OnCheckNormal(poolKey,poolObj) then return end
   
    self:CreatePool(poolKey)
    self:CreateParentObject(poolKey)

    local isHas = self:Has(poolKey)
    if not isHas then self.count = self.count + 1 end

    local parentObj = self.parentObjectDict[poolKey]

    self:OnPush(poolKey,poolObj,parentObj)
    self:OnMoveParent(poolKey,poolObj,parentObj)

    self.poolDict[poolKey]:Push(poolObj)
    parentObj.name = string.format(objectName,poolKey,self.poolDict[poolKey].length)
    self.latelyUseList:MoveLast(self.latelyUseIterDict[poolKey])
end

function BasePool:CreatePool(poolKey)
    if self.poolDict[poolKey] ~= nil then return end
    self.poolDict[poolKey] = List:New()
    local iter = self.latelyUseList:Push(poolKey)
    self.latelyUseIterDict[poolKey] = iter
end

function BasePool:CreateParentObject(poolKey)
    if self.parentObjectDict[poolKey] then return end
    local parentObj = PoolManager.Instance:Pop(PoolType.object,PoolDefine.PoolKey.empty_object) or GameObject()
    parentObj.name = poolKey
    parentObj.transform:SetParent(self.transform)
    parentObj.transform:Reset()
    self.parentObjectDict[poolKey] = parentObj
end

function BasePool:Pop(poolKey)
    if not self.poolDict[poolKey] or self.poolDict[poolKey].length <=0 then return nil end
    local iter = self.poolDict[poolKey]:Pop()
    self:OnPop(poolKey,iter)

    self:UpdatePool(poolKey)
    
    return iter
end

function BasePool:Has(poolKey)
    if not self.poolDict[poolKey] then return false end
    return self.poolDict[poolKey].length > 0
end

function BasePool:ExistNum(poolKey)
    if not self.poolDict[poolKey] then return 0 end
    return self.poolDict[poolKey].length
end

function BasePool:ClearPool(clearCount)
    if not clearCount or clearCount <=0 then return end

    local curClearCount = 0
    local poolKey = nil
    while (curClearCount < clearCount) do
        poolKey = self.latelyUseList:PopHead()
        if not poolKey or not self:Has(poolKey) then break end
        self:ClearPoolByKey(poolKey)
        curClearCount = curClearCount + 1
    end
end

function BasePool:ClearPoolByKey(poolKey,clearCount)
    local pool = self.poolDict[poolKey]
    if not pool or pool.length <= 0 then return end

    if not clearCount then clearCount = pool.length end
    if clearCount <= 0 then return end

    local curClearCount = 0
    local poolObj = nil
    while (curClearCount < clearCount) do
        poolObj = pool:PopHead()
        if not poolObj then break end
        self:OnRemove(poolKey,poolObj)
        curClearCount = curClearCount + 1
    end

    self:UpdatePool(poolKey)
end

function BasePool:UpdatePool(poolKey)
    local pool = self.poolDict[poolKey]
    if pool.length > 0 then
        self.parentObjectDict[poolKey].name = string.format(objectName,poolKey,pool.length)
    else
        self.count = self.count - 1
        self.latelyUseList:MoveLast(self.latelyUseIterDict[poolKey])
        if poolKey ~= PoolDefine.PoolKey.empty_object then
            PoolManager.Instance:Push(PoolType.object,PoolDefine.PoolKey.empty_object,self.parentObjectDict[poolKey])
            self.parentObjectDict[poolKey] = nil
        end
    end
end

--全部清理
function BasePool:Clean()
    for k,_ in pairs(self.poolDict) do self:ClearPoolByKey(k) end
end

--移动到父节点，可重写
function BasePool:OnMoveParent(poolKey,poolObj,parentObj)
    if not poolObj.transform then return end
    poolObj.transform:SetParent(parentObj.transform)
    poolObj.transform:Reset()
end

--虚函数
function BasePool:OnCheckNormal(poolKey,poolObj) return true end
function BasePool:OnPush(poolKey,poolObj,parentObj) end
function BasePool:OnPop(poolKey,poolObj) end
function BasePool:OnRemove(poolKey,poolObj) end
function BasePool:OnCheckClear() end
