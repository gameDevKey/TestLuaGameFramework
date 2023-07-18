ECSLUtil = StaticClass("ECSLUtil")

ECSLUtil.Uids = {}

function ECSLUtil.GetUid(type)
    if not ECSLUtil.Uids[type] then
        ECSLUtil.Uids[type] = 0
    end
    ECSLUtil.Uids[type] = ECSLUtil.Uids[type] + 1
    return ECSLUtil.Uids[type]
end

function ECSLUtil.GetEntityDis(entity1,entity2)
    local pos1 = entity1.TransformComponent:GetPosVec3()
    local pos2 = entity2.TransformComponent:GetPosVec3()
    return (pos1 - pos2).magnitude
end

return ECSLUtil