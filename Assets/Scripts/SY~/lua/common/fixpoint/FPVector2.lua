local fixpoint = require("fixpoint")

FPVector2 = {}

FPVector2.__index = function(t, k)
	if k == "vec2" then
        return Vector2(t.x * FPFloat.PrecisionFactor, t.y * FPFloat.PrecisionFactor)
    elseif k == "sqrMagnitude" then
        if DEBUG_FP and fixpoint.FPVector2_SqrMagnitude(t.x,t.y) ~= CS_FPVector2(t.x,t.y).sqrMagnitude then
            assert(false,string.format("FPVector2.sqrMagnitude,计算结果不一致[x:%s][y:%s]",tostring(t.x),tostring(t.y)))
        end
        return fixpoint.FPVector2_SqrMagnitude(t.x,t.y)
    elseif k == "sqrMagnitudeLong" then
        if DEBUG_FP and fixpoint.FPVector2_SqrMagnitudeLong(t.x,t.y) ~= CS_FPVector2(t.x,t.y).sqrMagnitudeLong then
            assert(false,string.format("FPVector2.sqrMagnitudeLong,计算结果不一致[x:%s][y:%s]",tostring(t.x),tostring(t.y)))
        end
        return fixpoint.FPVector2_SqrMagnitudeLong(t.x,t.y)
    elseif k == "rawSqrMagnitude" then
        if DEBUG_FP and fixpoint.FPVector2_RawSqrMagnitude(t.x,t.y) ~= CS_FPVector2(t.x,t.y).rawSqrMagnitude then
            assert(false,string.format("FPVector2.rawSqrMagnitude,计算结果不一致[x:%s][y:%s]",tostring(t.x),tostring(t.y)))
        end
        return fixpoint.FPVector2_RawSqrMagnitude(t.x,t.y)
    elseif k == "magnitude" then
        if DEBUG_FP and fixpoint.FPVector2_Magnitude(t.x,t.y) ~= CS_FPVector2(t.x,t.y).magnitude then
            assert(false,string.format("FPVector2.magnitude,计算结果不一致[x:%s][y:%s]",tostring(t.x),tostring(t.y)))
        end
        return fixpoint.FPVector2_Magnitude(t.x,t.y)
    elseif k == "normalized" then
        local ret, x, y = fixpoint.FPVector2_NormalizeTo(t.x,t.y,FPFloat.Precision)

        if DEBUG_FP and ret ~= 0 then
            local debugFPVector2 = CS_FPVector2(t.x,t.y).normalized
            if debugFPVector2.x ~= x or debugFPVector2.y ~= y then
                assert(false,string.format("FPVector2.normalized,计算结果不一致[x:%s][y:%s]",tostring(t.x),tostring(t.y)))
            end
        end
    
        if ret ~= 0 then
            return FPVector2.New(x)
        else
            return FPVector2.zero
        end
	else
		return rawget(FPVector2, k)
	end
end

FPVector2.__call = function(t,x,y)
	local t = {x = x or 0, y = y or 0}
	setmetatable(t, FPVector2)
	return t
end

function FPVector2.New(x,y)
    local t = {x = x or 0, y = y or 0}
    setmetatable(t, FPVector2)
    return t
end

function FPVector2:Set(x,y)
    self.x = x
    self.y = y
end

function FPVector2:SetByFPVector2(v)
    self.x = v.x
    self.y = v.y
end

function FPVector2:ToVector2(v)
    v:Set(self.x * FPFloat.PrecisionFactor,self.y * FPFloat.PrecisionFactor)
end

function FPVector2.Rotate(v,r)
    local x,y = fixpoint.FPVector2_Rotate(v.x,v.y,r)

    if DEBUG_FP then
        local debugFPVector2 = CS_FPVector2.Rotate(CS_FPVector2(v.x,v.y),r)
        if debugFPVector2.x ~= x or debugFPVector2.y ~= y then
            assert(false,string.format("FPVector2.Rotate,计算结果不一致[v_x:%s][v_y:%s][r:%s]",
                tostring(v.x),tostring(v.y),tostring(r)))
        end
    end

    return FPVector2(x,y)
end

function FPVector2.Min(a,b)
    return FPVector2(FPMath.Min(a.x, b.x), FPMath.Min(a.y, b.y))
end

function FPVector2.Max(a,b)
    return FPVector2(FPMath.Max(a.x, b.x), FPMath.Max(a.y, b.y))
end

function FPVector2:MinTo(v)
    self.x = FPMath.Min(self.x, v.x);
    self.y = FPMath.Min(self.y, v.y);
end

function FPVector2:MaxTo(v)
    self.x = FPMath.Max(self.x, v.x);
    self.y = FPMath.Max(self.y, v.y);
end

function FPVector2:ToFPVector3(v)
    return v:Set(self.x,0,self.y)
end

function FPVector2:Normalize()
    self:NormalizeTo(FPFloat.Precision)
end

function FPVector2:NormalizeTo(newMagn)
    local ret, x, y = fixpoint.FPVector2_NormalizeTo(self.x,self.y,newMagn)

    if DEBUG_FP and ret ~= 0 then
        local debugFPVector2 = CS_FPVector2(self.x,self.y)
        debugFPVector2:NormalizeTo(newMagn)
        if debugFPVector2.x ~= x or debugFPVector2.y ~= y then
            assert(false,string.format("FPVector2.NormalizeTo,计算结果不一致[x:%s][y:%s][newMagn:%s]",tostring(self.x),tostring(self.y),newMagn))
        end
    end

    if ret ~= 0 then
        self:Set(x,y)
    end
end

function FPVector2.Dot(v1,v2)
    if DEBUG_FP and fixpoint.FPVector2_Dot(v1.x,v1.y,v2.x,v2.y) ~= CS_FPVector2.Dot(CS_FPVector2(v1.x,v1.y),CS_FPVector2(v2.x,v2.y)) then
        assert(false,string.format("FPVector2.Dot,计算结果不一致[v1_x:%s][v1_y:%s][v2_x:%s][v2_y:%s]",
            tostring(v1.x),tostring(v1.y),tostring(v2.x),tostring(v2.y)))
    end
    return fixpoint.FPVector2_Dot(v1.x,v1.y,v2.x,v2.y)
end

function FPVector2.Cross(v1,v2)
    if DEBUG_FP and fixpoint.FPVector2_Cross(v1.x,v1.y,v2.x,v2.y) ~= CS_FPVector2.Cross(CS_FPVector2(v1.x,v1.y),CS_FPVector2(v2.x,v2.y)) then
        assert(false,string.format("FPVector2.Cross,计算结果不一致[v1_x:%s][v1_y:%s][v2_x:%s][v2_y:%s]",
            tostring(v1.x),tostring(v1.y),tostring(v2.x),tostring(v2.y)))
    end
    return fixpoint.FPVector2_Cross(v1.x,v1.y,v2.x,v2.y)
end

function FPVector2.Cross2D(v1,v2)
    if DEBUG_FP and fixpoint.FPVector2_Cross2D(v1.x,v1.y,v2.x,v2.y) ~= CS_FPVector2.Cross2D(CS_FPVector2(v1.x,v1.y),CS_FPVector2(v2.x,v2.y)) then
        assert(false,string.format("FPVector2.Cross2D,计算结果不一致[v1_x:%s][v1_y:%s][v2_x:%s][v2_y:%s]",
            tostring(v1.x),tostring(v1.y),tostring(v2.x),tostring(v2.y)))
    end
    return fixpoint.FPVector2_Cross2D(v1.x,v1.y,v2.x,v2.y)
end

function FPVector2.Lerp(v1,v2,f,toFPVector2)
    local x, y = fixpoint.FPVector2_Lerp(v1.x,v1.y,v2.x,v2.y,f)

    if DEBUG_FP then
        local debugFPVector2 = CS_FPVector2.Lerp(CS_FPVector2(v1.x,v1.y),CS_FPVector2(v2.x,v2.y),f)
        if debugFPVector2.x ~= x or debugFPVector2.y ~= y then
            assert(false,string.format("FPVector2.Lerp,计算结果不一致[v1_x:%s][v1_y:%s][v2_x:%s][v2_y:%s]",
                tostring(v1.x),tostring(v1.y),tostring(v2.x),tostring(v2.y)))
        end
    end

    local fpVector2 = toFPVector2 or FPVector2.New(0,0)
    fpVector2:Set(x,y)
    return fpVector2
end


FPVector2.__eq = function(v1, v2)
	return v1.x == v2.x and v1.y == v2.y
end

FPVector2.__unm = function(v)
	return FPVector2(v.x * -1, v.y * -1)
end

FPVector2.__add = function(v1, v2)
	return FPVector2(v1.x + v2.x,v1.y + v2.y)
end

FPVector2.__sub = function(v1, v2)
    return FPVector2(v1.x - v2.x,v1.y - v2.y)
end

FPVector2.__mul = function(v1, v2)
	local x,y
	if type(v2) == "number" then
		x,y = fixpoint.FPVector2_Mul_i(v1.x,v1.y,v2)
        if DEBUG_FP then
            local debugFPVector2 = CS_FPVector2(v1.x,v1.y) * v2
            if debugFPVector2.x ~= x or debugFPVector2.y ~= y then
                assert(false,string.format("FPVector2.__mul,计算结果不一致[v1_x:%s][v1_y:%s][v2:%s]",
                    tostring(v1.x),tostring(v1.y),tostring(v2)))
            end
        end
	else
		x,y = fixpoint.FPVector2_Mul(v1.x,v1.y,v2.x,v2.y)
        if DEBUG_FP then
            local debugFPVector2 = CS_FPVector2(v1.x,v1.y) * CS_FPVector2(v2.x,v2.y)
            if debugFPVector2.x ~= x or debugFPVector2.y ~= y then
                assert(false,string.format("FPVector2.__mul,计算结果不一致[v1_x:%s][v1_y:%s][v2_x:%s][v2_y:%s]",
                    tostring(v1.x),tostring(v1.y),tostring(v2.x),tostring(v2.y)))
            end
        end
	end
	return FPVector2(x,y)
end

FPVector2.__div = function(v1, v2)
    if v2 == 0 then
        assert(false,"除以0了,赶紧看Log")
    end
    
	local x, y = fixpoint.FPVector2_Div(v1.x,v1.y,v2)

    if DEBUG_FP then
        local debugFPVector2 = CS_FPVector2(v1.x,v1.y) / v2
        if debugFPVector2.x ~= x or debugFPVector2.y ~= y then
            assert(false,string.format("FPVector2.__div,计算结果不一致[v1_x:%s][v1_y:%s][v2:%s]",
                tostring(v1.x),tostring(v1.y),tostring(v2)))
        end
    end

    return FPVector2(x,y)
end

FPVector2.zero = FPVector2.New(0, 0)
FPVector2.one = FPVector2.New(FPFloat.Precision, FPFloat.Precision)
FPVector2.half = FPVector2.New(FPFloat.HalfPrecision, FPFloat.HalfPrecision)
FPVector2.up = FPVector2.New(0, FPFloat.Precision)
FPVector2.down = FPVector2.New(0, -FPFloat.Precision)
FPVector2.right = FPVector2.New(FPFloat.Precision, 0)
FPVector2.left = FPVector2.New(-FPFloat.Precision, 0)


setmetatable(FPVector2, FPVector2)