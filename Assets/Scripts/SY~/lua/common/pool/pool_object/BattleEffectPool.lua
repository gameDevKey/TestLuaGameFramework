BattleEffectPool = BaseClass("BattleEffectPool",BasePool)

function BattleEffectPool:__Init()
end

function BattleEffectPool:OnCheckNormal(poolKey,poolObj)
    return true
end

function BattleEffectPool:OnMoveParent(poolKey,poolObj,parentObj)
    poolObj.transform:SetParent(parentObj.transform)
end

function BattleEffectPool:OnRemove(poolKey,poolObj)
    GameObject.Destroy(poolObj)
end

function BattleEffectPool:OnPop(poolKey,poolObj)
    poolObj.gameObject:SetActive(true)
end

function BattleEffectPool:OnPush(poolKey,poolObj,parentObj)
    poolObj.gameObject:SetActive(false)
end

function BattleEffectPool:OnCheckClear()
end