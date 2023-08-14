ObjectPool = BaseClass("ObjectPool",BasePool)

function ObjectPool:__Init()

end

function ObjectPool:__Delete()

end

function ObjectPool:OnCheckNormal(poolKey,poolObj)
    return true
end

function ObjectPool:OnMoveParent(poolKey,poolObj,parentObj)
    poolObj.gameObject.name = poolKey
    poolObj.transform:SetParent(parentObj.transform)
    poolObj.transform:Reset()
end

function ObjectPool:OnRemove(poolKey,poolObj)
    poolObj:Destroy()
end

function ObjectPool:OnPush(poolKey,poolObj,parentObj)
    poolObj.gameObject:SetActive(true)
   -- poolObj:OnReset()
end

function ObjectPool:OnCheckClear()

end 