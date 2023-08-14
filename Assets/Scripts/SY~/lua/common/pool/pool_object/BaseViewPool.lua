BaseViewPool = BaseClass("BaseViewPool",BasePool)

function BaseViewPool:__Init()

end

function BaseViewPool:__Delete()

end

function BaseViewPool:OnMoveParent(poolKey,poolObj,parentObj)
    poolObj.gameObject.name = poolKey
    --TransformUtils.setAnchorMinAndMax(poolObj.transform,0.5,0.5,0.5,0.5)
    poolObj.transform:SetParent(parentObj.transform)
    poolObj.transform:Reset()
end

function BaseViewPool:OnRemove(poolKey,poolObj)
    poolObj:Destroy()
end

function BaseViewPool:OnPush(poolKey,poolObj,parentObj)
    poolObj:Hide()
    poolObj:OnReset()
end