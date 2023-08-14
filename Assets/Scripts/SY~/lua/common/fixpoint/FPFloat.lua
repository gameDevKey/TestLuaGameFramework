local fixpoint = require("fixpoint")

FPFloat = {}

FPFloat.Precision = 1000
FPFloat.HalfPrecision = 500
FPFloat.PrecisionFactor = 0.001

FPFloat.zero = 0
FPFloat.one = FPFloat.Precision
FPFloat.half = 500
FPFloat.FLT_MAX = 2147483647
FPFloat.FLT_MIN = -2147483648
FPFloat.EPSILON = 1
FPFloat.INTERVAL_EPSI_LON = 1
FPFloat.MaxValue = 2147483647

FPFloat.Fix = 10

function FPFloat.Mul_ii(a,b)
    if DEBUG_FP and fixpoint.FPFloat_Mul_ii(a,b) ~= CS_FPFloat.Mul_ii(a,b) then
        assert(false,string.format("FPFloat.Mul_ii,计算结果不一致[a:%s][b:%s]",tostring(a),tostring(b)))
    end
    return fixpoint.FPFloat_Mul_ii(a,b)
end

function FPFloat.Div_ii(a,b)
    if b == 0 then
        assert(false,"除以0了,赶紧看Log")
    end
    if DEBUG_FP and fixpoint.FPFloat_Div_ii(a,b) ~= CS_FPFloat.Div_ii(a,b) then
        assert(false,string.format("FPFloat.Div_ii,计算结果不一致[a:%s][b:%s]",tostring(a),tostring(b)))
    end
    return fixpoint.FPFloat_Div_ii(a,b)
end

function FPFloat.ToInt(a)
	if DEBUG_FP and fixpoint.FPFloat_ToInt(a) ~= CS_FPFloat.ToInt(a) then
        assert(false,string.format("FPFloat.ToInt,计算结果不一致[a:%s]",tostring(a)))
    end
    return fixpoint.FPFloat_ToInt(a)
end

--TODO:CS_FPMath.FloorToInt移到CS_Float中
function FPFloat.FloorToInt(a)
	if DEBUG_FP and fixpoint.FPFloat_FloorToInt(a) ~= CS_FPMath.FloorToInt(a) then
        assert(false,string.format("FPFloat.FloorToInt,计算结果不一致[a:%s]",tostring(a)))
    end
    return fixpoint.FPFloat_FloorToInt(a)
end


function FPFloat.ToFPFloat(a)
    return a * FPFloat.Precision
end