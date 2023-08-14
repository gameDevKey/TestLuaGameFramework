HeroTposePool = BaseClass("HeroTposePool",BasePool)

function HeroTposePool:__Init()
end

function HeroTposePool:OnCheckNormal(poolKey,poolObj)
    return true
end

function HeroTposePool:OnRemove(poolKey,poolObj)
    poolObj:Delete()
end

function HeroTposePool:OnPop(poolKey,poolObj)
    poolObj.gameObject:SetActive(true)
end

function HeroTposePool:OnPush(poolKey,poolObj,parentObj)
    poolObj:OnReset()
    poolObj.gameObject:SetActive(false)
end

function HeroTposePool:OnCheckClear()
    for key, val in pairs(self.poolDict) do
        local existNum = self:ExistNum(key)
        local maxExistNum = PoolDefine.poolMaxExistNum[PoolType.hero_tpose]
        local clearCount = existNum - maxExistNum
        self:ClearPoolByKey(key,clearCount)
    end
end