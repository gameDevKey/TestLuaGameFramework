local fixpoint = require("fixpoint")

FPVector3 = {}

FPVector3.__index = function(t, k)
	if k == "vec3" then
        return Vector3(t.x * FPFloat.PrecisionFactor, t.y * FPFloat.PrecisionFactor, t.z * FPFloat.PrecisionFactor)
    elseif k == "magnitude" then
        if DEBUG_FP and fixpoint.FPVector3_Magnitude(t.x,t.y,t.z) ~= CS_FPVector3(t.x,t.y,t.z).magnitude then
            assert(false,string.format("FPVector3.magnitude,计算结果不一致[x:%s][y:%s][z:%s]",tostring(t.x),tostring(t.y),tostring(t.z)))
        end
        return fixpoint.FPVector3_Magnitude(t.x,t.y,t.z)
    elseif k == "magnitude2D" then
        if DEBUG_FP and fixpoint.FPVector3_Magnitude2D(t.x,t.z) ~= CS_FPVector3(t.x,t.y,t.z).magnitude2D then
            assert(false,string.format("FPVector3.magnitude2D,计算结果不一致[x:%s][y:%s][z:%s]",tostring(t.x),tostring(t.y),tostring(t.z)))
        end
        return fixpoint.FPVector3_Magnitude2D(t.x,t.z)
    elseif k == "sqrMagnitude" then
        if DEBUG_FP and fixpoint.FPVector3_SqrMagnitude(t.x,t.y,t.z) ~= CS_FPVector3(t.x,t.y,t.z).sqrMagnitude then
            assert(false,string.format("FPVector3.sqrMagnitude,计算结果不一致[x:%s][y:%s][z:%s]",tostring(t.x),tostring(t.y),tostring(t.z)))
        end
        return fixpoint.FPVector3_SqrMagnitude(t.x,t.y,t.z)
    elseif k == "abs" then
		return FPVector3(FPMath.Abs(t.x) * FPMath.Abs(t.y) * FPMath.Abs(t.z))
    elseif k == "normalized" then
        local ret, x, y, z = fixpoint.FPVector3_Normalize(t.x,t.y,t.z)

        if DEBUG_FP and ret ~= 0 then
            local debugFPVector3 = CS_FPVector3(t.x,t.y,t.z).normalized
            if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
                assert(false,string.format("FPVector3.normalized,计算结果不一致[x:%s][y:%s][z:%s]",tostring(t.x),tostring(t.y),tostring(t.z)))
            end
        end
    
        if ret ~= 0 then
            return FPVector3(x,y,z)
        else
            return FPVector3.zero
        end
	else
		return rawget(FPVector3, k)
	end
end

FPVector3.__call = function(t,x,y,z)
	local t = {x = x or 0, y = y or 0, z = z or 0}
	setmetatable(t, FPVector3)
	return t
end

function FPVector3.New(x,y,z)
    local t = {x = x or 0, y = y or 0, z = z or 0}
    setmetatable(t, FPVector3)
    return t
end

function FPVector3:Set(x,y,z)
    self.x = x
    self.y = y
    self.z = z
end

function FPVector3:SetByFPVector3(v)
    self.x = v.x
    self.y = v.y
    self.z = v.z
end

function FPVector3:ToVector3(v)
    v:Set(self.x * FPFloat.PrecisionFactor,self.y * FPFloat.PrecisionFactor,self.z * FPFloat.PrecisionFactor)
end

function FPVector3:ToFPVector2(v)
    v:Set(self.x,self.z)
end

function FPVector3:Normalize()
    return self:NormalizeTo(FPFloat.Precision)
end

function FPVector3:NormalizeTo(newMagn)
    local ret, x, y, z = fixpoint.FPVector3_NormalizeTo(self.x,self.y,self.z,newMagn)

    if DEBUG_FP and ret ~= 0 then
        local debugFPVector3 = CS_FPVector3(self.x,self.y,self.z)
        debugFPVector3:NormalizeTo(newMagn)
        if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
            assert(false,string.format("FPVector3.NormalizeTo,计算结果不一致[x:%s][y:%s][z:%s][newMagn:%s]",tostring(self.x),tostring(self.y),tostring(self.z),newMagn))
        end
    end

    if ret ~= 0 then
        self:Set(x,y,z)
    end

    return self
end

function FPVector3:RotateX(degree,toFPVector3)
    local x, y, z = fixpoint.FPVector3_RotateX(self.x,self.y,self.z,degree)

    if DEBUG_FP then
        local debugFPVector3 = CS_FPVector3(self.x,self.y,self.z):RotateX(degree)
        if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
            assert(false,string.format("FPVector3.RotateX,计算结果不一致[x:%s][y:%s][z:%s][degree:%s]",tostring(self.x),tostring(self.y),tostring(self.z),degree))
        end
    end

    local fpVector3 = toFPVector3 or FPVector3.New(0,0,0)
    fpVector3:Set(x,y,z)
    return fpVector3
end

function FPVector3:RotateY(degree,toFPVector3)
    local x, y, z = fixpoint.FPVector3_RotateY(self.x,self.y,self.z,degree)

    if DEBUG_FP then
        local debugFPVector3 = CS_FPVector3(self.x,self.y,self.z):RotateY(degree)
        if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
            assert(false,string.format("FPVector3.RotateY,计算结果不一致[x:%s][y:%s][z:%s][degree:%s]",tostring(self.x),tostring(self.y),tostring(self.z),degree))
        end
    end

    local fpVector3 = toFPVector3 or FPVector3.New(0,0,0)
    fpVector3:Set(x,y,z)
    return fpVector3
end

function FPVector3:RotateZ(degree,toFPVector3)
    local x, y, z = fixpoint.FPVector3_RotateZ(self.x,self.y,self.z,degree)

    if DEBUG_FP then
        local debugFPVector3 = CS_FPVector3(self.x,self.y,self.z):RotateZ(degree)
        if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
            assert(false,string.format("FPVector3.RotateZ,计算结果不一致[x:%s][y:%s][z:%s][degree:%s]",tostring(self.x),tostring(self.y),tostring(self.z),degree))
        end
    end

    local fpVector3 = toFPVector3 or FPVector3.New(0,0,0)
    fpVector3:Set(x,y,z)
    return fpVector3
end

function FPVector3.Dot(v1,v2)
    if DEBUG_FP and fixpoint.FPVector3_Dot(v1.x,v1.y,v1.z,v2.x,v2.y,v2.z) ~= CS_FPVector3.Dot(CS_FPVector3(v1.x,v1.y,v1.z),CS_FPVector3(v2.x,v2.y,v2.z)) then
        assert(false,string.format("FPVector3.Dot,计算结果不一致[v1_x:%s][v1_y:%s][v1_z:%s][v2_x:%s][v2_y:%s][v2_z:%s]",
            tostring(v1.x),tostring(v1.y),tostring(v1.z),tostring(v2.x),tostring(v2.y),tostring(v2.z)))
    end
    return fixpoint.FPVector3_Dot(v1.x,v1.y,v1.z,v2.x,v2.y,v2.z)
end

function FPVector3.Cross(v1,v2,toFPVector3)
    local x, y, z = fixpoint.FPVector3_Cross(v1.x,v1.y,v1.z,v2.x,v2.y,v2.z)

    if DEBUG_FP then
        local debugFPVector3 = CS_FPVector3.Cross(CS_FPVector3(v1.x,v1.y,v1.z),CS_FPVector3(v2.x,v2.y,v2.z))
        if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
            assert(false,string.format("FPVector3.Cross,计算结果不一致[v1_x:%s][v1_y:%s][v1_z:%s][v2_x:%s][v2_y:%s][v2_z:%s]",
                tostring(v1.x),tostring(v1.y),tostring(v1.z),tostring(v2.x),tostring(v2.y),tostring(v2.z)))
        end
    end

    local fpVector3 = toFPVector3 or FPVector3.New(0,0,0)
    fpVector3:Set(x,y,z)
    return fpVector3
end

function FPVector3.Lerp(v1,v2,f,toFPVector3)
    local x, y, z = fixpoint.FPVector3_Lerp(v1.x,v1.y,v1.z,v2.x,v2.y,v2.z,f)

    if DEBUG_FP then
        local debugFPVector3 = CS_FPVector3.Lerp(CS_FPVector3(v1.x,v1.y,v1.z),CS_FPVector3(v2.x,v2.y,v2.z),f)
        if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
            assert(false,string.format("FPVector3.Lerp,计算结果不一致[v1_x:%s][v1_y:%s][v1_z:%s][v2_x:%s][v2_y:%s][v2_z:%s]",
                tostring(v1.x),tostring(v1.y),tostring(v1.z),tostring(v2.x),tostring(v2.y),tostring(v2.z)))
        end
    end

    local fpVector3 = toFPVector3 or FPVector3.New(0,0,0)
    fpVector3:Set(x,y,z)
    return fpVector3
end


FPVector3.__eq = function(v1, v2)
	return v1.x == v2.x and v1.y == v2.y and v1.z == v2.z
end

FPVector3.__unm = function(v)
	return FPVector3(v.x * -1, v.y * -1, v.z * -1)
end

FPVector3.__add = function(v1, v2)
	return FPVector3(v1.x + v2.x,v1.y + v2.y,v1.z + v2.z)
end

FPVector3.__sub = function(v1, v2)
    return FPVector3(v1.x - v2.x,v1.y - v2.y,v1.z - v2.z)
end

FPVector3.__mul = function(v1, v2)
	local x,y,z
	if type(v2) == "number" then
		x,y,z = fixpoint.FPVector3_Mul_i(v1.x,v1.y,v1.z,v2)
        if DEBUG_FP then
            local debugFPVector3 = CS_FPVector3(v1.x,v1.y,v1.z) * v2
            if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
                assert(false,string.format("FPVector3.__mul,计算结果不一致[v1_x:%s][v1_y:%s][v1_z:%s][v2:%s]",
                tostring(v1.x),tostring(v1.y),tostring(v1.z),tostring(v2)))
            end
        end
	else
		x,y,z = fixpoint.FPVector3_Mul(v1.x,v1.y,v1.z,v2.x,v2.y,v2.z)
        if DEBUG_FP then
            local debugFPVector3 = CS_FPVector3(v1.x,v1.y,v1.z) * CS_FPVector3(v2.x,v2.y,v2.z)
            if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
                assert(false,string.format("FPVector3.__mul,计算结果不一致[v1_x:%s][v1_y:%s][v1_z:%s][v2_x:%s][v2_y:%s][v2_z:%s]",
                tostring(v1.x),tostring(v1.y),tostring(v1.z),tostring(v2.x),tostring(v2.y),tostring(v2.z)))
            end
        end
	end
	return FPVector3(x,y,z)
end

FPVector3.__div = function(v1, v2)
    if v2 == 0 then
        assert(false,"除以0了,赶紧看Log")
    end
    
	local x, y, z = fixpoint.FPVector3_Div(v1.x,v1.y,v1.z,v2)

    if DEBUG_FP then
        local debugFPVector3 = CS_FPVector3(v1.x,v1.y,v1.z) / v2
        if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
            assert(false,string.format("FPVector3.__div,计算结果不一致[v1_x:%s][v1_y:%s][v1_z:%s][v2:%s]",
            tostring(v1.x),tostring(v1.y),tostring(v1.z),tostring(v2)))
        end
    end

    return FPVector3(x,y,z)
end


FPVector3.zero = FPVector3.New(0, 0, 0)
FPVector3.one = FPVector3.New(FPFloat.Precision, FPFloat.Precision, FPFloat.Precision)
FPVector3.half = FPVector3.New(FPFloat.HalfPrecision, FPFloat.HalfPrecision, FPFloat.HalfPrecision)

FPVector3.forward = FPVector3.New(0, 0, FPFloat.Precision)
FPVector3.up = FPVector3.New(0, FPFloat.Precision, 0)
FPVector3.right = FPVector3.New(FPFloat.Precision, 0, 0)
FPVector3.back = FPVector3.New(0, 0, -FPFloat.Precision)
FPVector3.down = FPVector3.New(0, -FPFloat.Precision, 0)
FPVector3.left = FPVector3.New(-FPFloat.Precision, 0, 0)


setmetatable(FPVector3, FPVector3)