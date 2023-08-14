local fixpoint = require("fixpoint")

FPMath = {}

function FPMath.Atan2(y,x)
    if DEBUG_FP and fixpoint.FPMath_Atan2(y,x) ~= CS_FPMath.Atan2(y,x) then
        assert(false,string.format("FPMath.Atan2,计算结果不一致[y:%s][x:%s]",tostring(y),tostring(x)))
    end
    return fixpoint.FPMath_Atan2(y,x)
end

function FPMath.Acos(val)
    if DEBUG_FP and fixpoint.FPMath_Acos(val) ~= CS_FPMath.Acos(val) then
        assert(false,string.format("FPMath.Acos,计算结果不一致[val:%s]",tostring(val)))
    end
    return fixpoint.FPMath_Acos(val)
end

function FPMath.Asin(val)
    if DEBUG_FP and fixpoint.FPMath_Asin(val) ~= CS_FPMath.Asin(val) then
        assert(false,string.format("FPMath.Asin,计算结果不一致[val:%s]",tostring(val)))
    end
    return fixpoint.FPMath_Asin(val)
end

function FPMath.Sin(val)
    if DEBUG_FP and fixpoint.FPMath_Sin(val) ~= CS_FPMath.Sin(val) then
        assert(false,string.format("FPMath.Sin,计算结果不一致[val:%s]",tostring(val)))
    end
    return fixpoint.FPMath_Sin(val)
end

function FPMath.Cos(val)
    if DEBUG_FP and fixpoint.FPMath_Cos(val) ~= CS_FPMath.Cos(val) then
        assert(false,string.format("FPMath.Cos,计算结果不一致[val:%s]",tostring(val)))
    end
    return fixpoint.FPMath_Cos(val)
end

function FPMath.SinCos(val)
    local s,c = fixpoint.FPMath_SinCos(val)

    if DEBUG_FP then
        local cs_s,cs_c = CS_FPMath.SinCos(val)
        if s ~= cs_s or c ~= cs_c then
            assert(false,string.format("FPMath.SinCos,计算结果不一致[val:%s]",tostring(val)))
        end
    end
    return s,c
end


function FPMath.Sqrt32(a)
    if DEBUG_FP and fixpoint.FPMath_Sqrt32(a) ~= CS_FPMath.Sqrt32(a) then
        assert(false,string.format("FPMath.Sqrt32,计算结果不一致[a:%s]",tostring(a)))
    end
    return fixpoint.FPMath_Sqrt32(a)
end

function FPMath.Sqrt64(a)
    if DEBUG_FP and fixpoint.FPMath_Sqrt64(a) ~= CS_FPMath.Sqrt64(a) then
        assert(false,string.format("FPMath.Sqrt64,计算结果不一致[a:%s]",tostring(a)))
    end
    return fixpoint.FPMath_Sqrt64(a)
end


function FPMath.Sqrt_i(a)
    if DEBUG_FP and fixpoint.FPMath_Sqrt_i(a) ~= CS_FPMath.Sqrt(a) then
        assert(false,string.format("FPMath.Sqrt_i,计算结果不一致[a:%s]",tostring(a)))
    end
    return fixpoint.FPMath_Sqrt_i(a)
end

function FPMath.Sqrt(a)
    if DEBUG_FP and fixpoint.FPMath_Sqrt(a) ~= CS_FPMath.Sqrt(a) then
        assert(false,string.format("FPMath.Sqrt,计算结果不一致[a:%s]",tostring(a)))
    end
    return fixpoint.FPMath_Sqrt(a)
end

function FPMath.SqrtLong(a)
    if DEBUG_FP and fixpoint.FPMath_SqrtLong(a) ~= CS_FPMath.SqrtLong(a) then
        assert(false,string.format("FPMath.SqrtLong,计算结果不一致[a:%s]",tostring(a)))
    end
    return fixpoint.FPMath_SqrtLong(a)
end

function FPMath.Sqr(a)
    if DEBUG_FP and fixpoint.FPMath_Sqr(a) ~= CS_FPMath.Sqr(a) then
        assert(false,string.format("FPMath.Sqr,计算结果不一致[a:%s]",tostring(a)))
    end
    return fixpoint.FPMath_Sqr(a)
end

function FPMath.Clamp(val,min,max)
    if val < min then
        return min
    elseif val > max then
        return max
    else
        return val
    end
end

function FPMath.Clamp01(a)
    if DEBUG_FP and fixpoint.FPMath_Clamp01(a) ~= CS_FPMath.Clamp01(a) then
        assert(false,string.format("FPMath.Clamp01,计算结果不一致[a:%s]",tostring(a)))
    end
    return fixpoint.FPMath_Clamp01(a)
end

function FPMath.SameSign(a,b)
    return a * b > 0
end

function FPMath.Abs(val)
    if val < 0 then
        return -val
    else
        return val
    end
end


function FPMath.Round(val)
    if DEBUG_FP and fixpoint.FPMath_Round(val) ~= CS_FPMath.Round(val) then
        assert(false,string.format("FPMath.Round,计算结果不一致[val:%s]",tostring(val)))
    end
    return fixpoint.FPMath_Round(val)
end

function FPMath.Max(a,b)
    return a <= b and b or a
end

function FPMath.Min(a,b)
    return a > b and b or a
end

function FPMath.MaxByAry(values)
    local length = #values;
    if length == 0 then
        return 0;
    end

    local num = values[1];
    for i = 2,length do
        if values[i] > num then
            num = values[i]
        end
    end
    return num;
end

function FPMath.MinByAry(values)
    local length = #values;
    if length == 0 then
        return 0;
    end

    local num = values[1];
    for i = 2,length do
        if values[i] < num then
            num = values[i]
        end
    end
    return num;
end


function FPMath.Lerp(a,b,f)
    if DEBUG_FP and fixpoint.FPMath_Lerp(a,b,f) ~= CS_FPMath.Lerp(a,b,f) then
        assert(false,string.format("FPMath.Lerp,计算结果不一致[a:%s][b:%s][f:%s]",tostring(a),tostring(b),tostring(f)))
    end
    return fixpoint.FPMath_Lerp(a,b,f)
end

function FPMath.IsPowerOfTwo(a)
    -- if DEBUG_FP and ((a & a -1) == 0) ~= CS_FPMath.IsPowerOfTwo(a) then
    --     assert(false,string.format("FPMath.IsPowerOfTwo,计算结果不一致[a:%s]",tostring(a)))
    -- end
    -- return (a & a -1) == 0
end

function FPMath.CeilPowerOfTwo(a)
    if DEBUG_FP and fixpoint.FPMath_CeilPowerOfTwo(a) ~= CS_FPMath.CeilPowerOfTwo(a) then
        assert(false,string.format("FPMath.CeilPowerOfTwo,计算结果不一致[a:%s]",tostring(a)))
    end
    return fixpoint.FPMath_CeilPowerOfTwo(a)
end


--TODO:divide分开类型可能好点
function FPMath.Divide(a,b)
    if b == 0 then
        assert(false,"除以0了,赶紧看Log")
    end
    if DEBUG_FP and fixpoint.FPMath_Divide_ii(a,b) ~= CS_FPMath.Divide(a,b) then
        assert(false,string.format("FPMath.Divide,计算结果不一致[a:%s][b:%s]",tostring(a),tostring(b)))
    end
    return fixpoint.FPMath_Divide_ii(a,b)
end

function FPMath.Divide_ll(a,b)
    if b == 0 then
        assert(false,"除以0了,赶紧看Log")
    end
    if DEBUG_FP and fixpoint.FPMath_Divide_ll(a,b) ~= CS_FPMath.Divide_ll(a,b) then
        assert(false,string.format("FPMath.Divide_ll,计算结果不一致[a:%s][b:%s]",tostring(a),tostring(b)))
    end
    return fixpoint.FPMath_Divide_ll(a,b)
end

function FPMath.DivideByCeil(a,b)
    if b == 0 then
        assert(false,"除以0了,赶紧看Log")
    end
    if DEBUG_FP and fixpoint.FPMath_DivideByCeil_ii(a,b) ~= CS_FPMath.DivideByCeil(a,b) then
        assert(false,string.format("FPMath.DivideByCeil,计算结果不一致[a:%s][b:%s]",tostring(a),tostring(b)))
    end
    return fixpoint.FPMath_DivideByCeil_ii(a,b)
end

function FPMath.DivideByCeil_ll(a,b)
    if b == 0 then
        assert(false,"除以0了,赶紧看Log")
    end
    if DEBUG_FP and fixpoint.FPMath_DivideByCeil_ll(a,b) ~= CS_FPMath.DivideByCeil_ll(a,b) then
        assert(false,string.format("FPMath.DivideByCeil_ll,计算结果不一致[a:%s][b:%s]",tostring(a),tostring(b)))
    end
    return fixpoint.FPMath_DivideByCeil_ll(a,b)
end

function FPMath.DivideByRound(a,b)
    if b == 0 then
        assert(false,"除以0了,赶紧看Log")
    end
    if DEBUG_FP and fixpoint.FPMath_DivideByRound_ii(a,b) ~= CS_FPMath.DivideByRound(a,b) then
        assert(false,string.format("FPMath.DivideByRound,计算结果不一致[a:%s][b:%s]",tostring(a),tostring(b)))
    end
    return fixpoint.FPMath_DivideByRound_ii(a,b)
end

function FPMath.DivideByRound_ll(a,b)
    if b == 0 then
        assert(false,"除以0了,赶紧看Log")
    end
    if DEBUG_FP and fixpoint.FPMath_DivideByRound_ll(a,b) ~= CS_FPMath.DivideByRound_ll(a,b) then
        assert(false,string.format("FPMath.DivideByRound_ll,计算结果不一致[a:%s][b:%s]",tostring(a),tostring(b)))
    end
    return fixpoint.FPMath_DivideByRound_ll(a,b)
end

function FPMath.Transform(v1, v2, v3, v4, v5, v6)
	if v6 then
		local x,y,z = fixpoint.FPMath_Transform_6v(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z, v3.x, v3.y, v3.z, v4.x, v4.y, v4.z, v5.x, v5.y, v5.z, v6.x, v6.y, v6.z)
		if DEBUG_FP then
            local debugFPVector3 = CS_FPMath.Transform(CS_FPVector3(v1.x, v1.y, v1.z),CS_FPVector3(v2.x, v2.y, v2.z),
                CS_FPVector3(v3.x, v3.y, v3.z),CS_FPVector3(v4.x, v4.y, v4.z),
                CS_FPVector3(v5.x, v5.y, v5.z),CS_FPVector3(v6.x, v6.y, v6.z))
            if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
                assert(false,string.format("FPMath.Transform(6),计算结果不一致[v1_x:%s][v1_y:%s][v1_z:%s][v2_x:%s][v2_y:%s][v2_z:%s][v3_x:%s][v3_y:%s][v3_z:%s][v4_x:%s][v4_y:%s][v4_z:%s][v5_x:%s][v5_y:%s][v5_z:%s][v6_x:%s][v6_y:%s][v6_z:%s]",
                tostring(v1.x),tostring(v1.y),tostring(v1.z),
                tostring(v2.x),tostring(v2.y),tostring(v2.z),
                tostring(v3.x),tostring(v3.y),tostring(v3.z),
                tostring(v4.x),tostring(v4.y),tostring(v4.z),
                tostring(v5.x),tostring(v5.y),tostring(v5.z),
                tostring(v6.x),tostring(v6.y),tostring(v6.z)))
            end
        end
        return FPVector3(x, y, z)
	end

	if v5 then
		local x,y,z = fixpoint.FPMath_Transform_5v(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z, v3.x, v3.y, v3.z, v4.x, v4.y, v4.z, v5.x, v5.y, v5.z)
		if DEBUG_FP then
            local debugFPVector3 = CS_FPMath.Transform(CS_FPVector3(v1.x, v1.y, v1.z),CS_FPVector3(v2.x, v2.y, v2.z),
                CS_FPVector3(v3.x, v3.y, v3.z),CS_FPVector3(v4.x, v4.y, v4.z),
                CS_FPVector3(v5.x, v5.y, v5.z))
            if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
                assert(false,string.format("FPMath.Transform(5),计算结果不一致[v1_x:%s][v1_y:%s][v1_z:%s][v2_x:%s][v2_y:%s][v2_z:%s][v3_x:%s][v3_y:%s][v3_z:%s][v4_x:%s][v4_y:%s][v4_z:%s][v5_x:%s][v5_y:%s][v5_z:%s]",
                tostring(v1.x),tostring(v1.y),tostring(v1.z),
                tostring(v2.x),tostring(v2.y),tostring(v2.z),
                tostring(v3.x),tostring(v3.y),tostring(v3.z),
                tostring(v4.x),tostring(v4.y),tostring(v4.z),
                tostring(v5.x),tostring(v5.y),tostring(v5.z)))
            end
        end
        return FPVector3(x, y, z)
	end

	if v4 then
		local x,y,z = fixpoint.FPMath_Transform_4v(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z, v3.x, v3.y, v3.z, v4.x, v4.y, v4.z)
		if DEBUG_FP then
            local debugFPVector3 = CS_FPMath.Transform(CS_FPVector3(v1.x, v1.y, v1.z),CS_FPVector3(v2.x, v2.y, v2.z),
                CS_FPVector3(v3.x, v3.y, v3.z),CS_FPVector3(v4.x, v4.y, v4.z))
            if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
                assert(false,string.format("FPMath.Transform(5),计算结果不一致[v1_x:%s][v1_y:%s][v1_z:%s][v2_x:%s][v2_y:%s][v2_z:%s][v3_x:%s][v3_y:%s][v3_z:%s][v4_x:%s][v4_y:%s][v4_z:%s]",
                tostring(v1.x),tostring(v1.y),tostring(v1.z),
                tostring(v2.x),tostring(v2.y),tostring(v2.z),
                tostring(v3.x),tostring(v3.y),tostring(v3.z),
                tostring(v4.x),tostring(v4.y),tostring(v4.z)))
            end
        end
        return FPVector3(x, y, z)
	end

	if v3 then
		local x,y,z = fixpoint.FPMath_Transform_3v(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z, v3.x, v3.y, v3.z)
		if DEBUG_FP then
            local debugFPVector3 = CS_FPMath.Transform(CS_FPVector3(v1.x, v1.y, v1.z),CS_FPVector3(v2.x, v2.y, v2.z),CS_FPVector3(v3.x, v3.y, v3.z))
            if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
                assert(false,string.format("FPMath.Transform(5),计算结果不一致[v1_x:%s][v1_y:%s][v1_z:%s][v2_x:%s][v2_y:%s][v2_z:%s][v3_x:%s][v3_y:%s][v3_z:%s]",
                tostring(v1.x),tostring(v1.y),tostring(v1.z),
                tostring(v2.x),tostring(v2.y),tostring(v2.z),
                tostring(v3.x),tostring(v3.y),tostring(v3.z)))
            end
        end
        return FPVector3(x, y, z)
	end
end

--MoveTowards

function FPMath.MoveTowards(from,to,dt,out)
    local x,y,z = fixpoint.FPMath_MoveTowards(from.x,from.y,from.z,to.x,to.y,to.z,dt)
    if DEBUG_FP then
        local debugFPVector3 = CS_FPMath.MoveTowards(CS_FPVector3(from.x,from.y,from.z),CS_FPVector3(to.x,to.y,to.z),dt)
        if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
            assert(false,string.format("FPMath.MoveTowards,计算结果不一致[from_x:%s][from_y:%s][from_z:%s][to_x:%s][to_y:%s][to_z:%s][dt:%s]",
            tostring(from.x),tostring(from.y),tostring(from.z),
            tostring(to.x),tostring(to.y),tostring(to.z),dt))
        end
    end

    local v = out or FPVector3.New(0,0,0)
    v:Set(x,y,z)
    return v
end

function FPMath.AngleInt(lhs,rhs)
    if DEBUG_FP and FPMath.Acos(FPVector3.Dot(lhs, rhs)) ~= CS_FPMath.AngleInt(lhs, rhs) then
        assert(false,string.format("FPMath.AngleInt,计算结果不一致[lhs_x:%s][lhs_y:%s][lhs_z:%s][rhs_x:%s][rhs_y:%s][rhs_z:%s]",
            tostring(lhs.x),tostring(lhs.y),tostring(lhs.z),tostring(rhs.x),tostring(rhs.y),tostring(rhs.z)))
    end
    return FPMath.Acos(FPVector3.Dot(lhs, rhs));
end

function FPMath.ToFPVector3(v,to)
    local x,y,z = fixpoint.FPMath_ToFPVector3(v.x, v.y, v.z)
    to:Set(x,y,z)
end

function FPMath.XYZToFPVector3(x,y,z,to)
    local fpX,fpY,fpZ = fixpoint.FPMath_ToFPVector3(x,y,z)
    to:Set(fpX,fpY,fpZ)
end

function FPMath.ToFPQuaternion(q,to)
    --TODO:改为c
    local x,y,z,w = math.ceil(q.x * FPFloat.Precision),math.ceil(q.y * FPFloat.Precision),math.ceil(q.z * FPFloat.Precision),math.ceil(q.w * FPFloat.Precision)
    --fixpoint.FPMath_FPQuaternion(v.x, v.y, v.z)
    to:Set(x,y,z,w)
end