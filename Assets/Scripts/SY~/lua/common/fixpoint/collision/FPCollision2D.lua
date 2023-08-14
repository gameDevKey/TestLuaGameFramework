local fixpoint = require("fixpoint")

FPCollision2D = {}


function FPCollision2D.PointInCircle(pointPos,circlePos,circleRadius)
    local flag = fixpoint.FPCollision2D_PointInCircle(pointPos.x,pointPos.y,circlePos.x,circlePos.y,circleRadius)
    return flag
end

function FPCollision2D.CircleInCircle(posA,rA,posB,rB)
    local flag = fixpoint.FPCollision2D_CircleInCircle(posA.x,posA.y,rA,posB.x,posB.y,rB)
    return flag
end

function FPCollision2D.AABBInCircle(posA,rA,sizeA,posB,rB)
    local diff = posA - posB

    local allRadius = rA + rB

    if diff.sqrMagnitude > FPFloat.Mul_ii(allRadius, allRadius) then
        return false
    end

    local absX = FPMath.Abs(diff.x)
    local absY = FPMath.Abs(diff.y)

    local size = sizeA
    local radius = rB
    local x = FPMath.Max(absX - (FPMath.Divide(size.x,2)), FPFloat.zero)
    local y = FPMath.Max(absY - (FPMath.Divide(size.y,2)), FPFloat.zero)

    return x * x + y * y < radius * radius
end


function FPCollision2D.PointInOBB(pointPos,circlePos,circleRadius)
    local flag = fixpoint.FPCollision2D_PointInCircle(pointPos.x,pointPos.y,circlePos.x,circlePos.y,circleRadius)
    return flag
end

-- function FPCollision2D.CircleInOBB(posA,rA,posB,rB)
--     local flag = fixpoint.FPCollision2D_CircleInCircle(posA.x,posA.y,rA,posB.x,posB.y,rB)
--     return flag
-- end

local fpVec2_1 = FPVector2(0,0)
function FPCollision2D.CircleInOBB(posA,rA,posB,rB,sizeB,up)
    local diff = posA - posB
    local allRadius = rA + rB
    if diff.sqrMagnitude > FPFloat.Mul_ii(allRadius,allRadius) then
        return false
    end

    --空间转换
    fpVec2_1:Set(up.y,-up.x)
    local absX = FPMath.Abs(FPVector2.Dot(diff,fpVec2_1))
    local absY = FPMath.Abs(FPVector2.Dot(diff,up))
    local size = sizeB
    local radius = rA
    local x = FPMath.Max(absX - size.x, FPFloat.zero)
    local y = FPMath.Max(absY - size.y, FPFloat.zero)

    return FPFloat.Mul_ii(x,x) + FPFloat.Mul_ii(y,y) < FPFloat.Mul_ii(radius,radius)
end


--点->圆环
function FPCollision2D.PointInAnnulus(pointPos,circlePos,circleRadius,inRadius)
    --int distance = FPVector2.Magnitude(pointPos_x - circlePos_x,pointPos_y - circlePos_y)
    --return distance <= circleRadius;
end

--
function FPCollision2D.CircleInAnnulus(posA,rA,posB,rB,inRadius)
    local diff_x =  posA.x - posB.x
    local diff_y =  posA.y - posB.y
    local allRadius = rA + rB
    local inAllRadius = rA + inRadius

    local a = FPVector2(diff_x,diff_y).sqrMagnitude

    local b = FPFloat.Mul_ii(allRadius, allRadius)

    local c = FPFloat.Mul_ii(inAllRadius, inAllRadius)

    return a <= b and a >= c
end

