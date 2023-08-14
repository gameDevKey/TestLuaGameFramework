ClassPool = BaseClass("ClassPool",BasePool)

function ClassPool:__Init()

end

function ClassPool:__Delete()

end

function ClassPool:OnPush(poolKey,poolObj,parentObj)
    if poolObj.OnReset then
        poolObj:OnReset()
    end
end