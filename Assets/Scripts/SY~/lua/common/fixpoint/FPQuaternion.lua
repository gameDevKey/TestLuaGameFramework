local fixpoint = require("fixpoint")

FPQuaternion = {}
FPQuaternion.key = "FPQuaternion"

FPQuaternion.__index = function(t, k)
    if k == "identity" then
        return FPQuaternion(0,0,0,FPFloat.Precision)
    elseif k == "eulerAngles" then
        local x,y,z = fixpoint.FPQuaternion_EulerAngles(t.x,t.y,t.z,t.w)
        if DEBUG_FP then
            local debugFPQuaternion = CS_FPQuaternion(t.x,t.y,t.z,t.w)
            local debugFPVector3 = debugFPQuaternion.eulerAngles
            if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
                assert(false,string.format("FPQuaternion.eulerAngles,计算结果不一致[x:%s][y:%s][z:%s][w:%s]",t.x,t.y,t.z,t.w))
            end
        end
        return FPVector3(x,y,z)
    else
        return rawget(FPQuaternion, k)
    end
end

FPQuaternion.__newindex = function(t,k,v)
    if k == "eulerAngles" then
        local x,y,z,w = fixpoint.FPQuaternion_Euler(v.x,v.y,v.z)
        if DEBUG_FP then
            local debugFPQuaternion = CS_FPQuaternion(t.x,t.y,t.z,t.w)
            debugFPQuaternion.eulerAngles = CS_FPVector3(v.x,v.y,v.z)
            if debugFPQuaternion.x ~= x or debugFPQuaternion.y ~= y or debugFPQuaternion.z ~= z or debugFPQuaternion.w ~= w then
                assert(false,string.format("FPQuaternion.eulerAngles,计算结果不一致[q_x:%s][q_y:%s][q_z:%s][q_w:%s][x:%s][y:%s][z:%s]"
                    ,t.x,t.y,t.z,t.w,v.x,v.y,v.z))
            end
        end
        t:Set(x,y,z,w)
    else
        rawset(t,k,v)
    end
end

FPQuaternion.__call = function(t,x,y,z,w)
	local t = {x = x or 0,y = y or 0,z = z or 0,w = w or 0}
	setmetatable(t, FPQuaternion)
	return t
end

function FPQuaternion.New(x,y,z,w)
    local t = {x = x or 0,y = y or 0,z = z or 0,w = w or 0}
    setmetatable(t, FPQuaternion)
    return t
end

function FPQuaternion:Set(x,y,z,w)
    self.x = x
    self.y = y
    self.z = z
    self.w = w
end

function FPQuaternion:SetByFPQuaternion(q)
    self.x = q.x
    self.y = q.y
    self.z = q.z
    self.w = q.w
end

function FPQuaternion:ToQuaternion(quat)
    local x,y,z,w = fixpoint.FPQuaternion_ToQuaternion(self.x,self.y,self.z,self.w)
    quat:Set(x,y,z,w)
end

function FPQuaternion.Angle(a,b)
    if DEBUG_FP and fixpoint.FPQuaternion_Angle(a.x,a.y,a.z,a.w,b.x,b.y,b.z,b.w) ~= CS_FPQuaternion.Angle(CS_FPQuaternion(a.x,a.y,a.z,a.w),CS_FPQuaternion(b.x,b.y,b.z,b.w)) then
        assert(false,string.format("FPQuaternion.Angle,计算结果不一致[a_x:%s][a_y:%s][a_z:%s][a_w:%s][b_x:%s][b_y:%s][b_z:%s][b_w:%s]",
            a.x,a.y,a.z,a.w,b.x,b.y,b.z,b.w))
    end
    return fixpoint.FPQuaternion_Angle(a.x,a.y,a.z,a.w,b.x,b.y,b.z,b.w)
end

function FPQuaternion.AngleAxis(angle,axis)
    local x,y,z,w = fixpoint.FPQuaternion_AngleAxis(angle,axis.x,axis.y,axis.z)
    if DEBUG_FP then
        local debugFPQuaternion = CS_FPQuaternion.AngleAxis(angle,CS_FPVector3(axis.x,axis.y,axis.z))
        if debugFPQuaternion.x ~= x or debugFPQuaternion.y ~= y or debugFPQuaternion.z ~= z or debugFPQuaternion.w ~= w then
            assert(false,string.format("FPQuaternion.AngleAxis,计算结果不一致[angle:%s][axis_x:%s][axis_y:%s][axis_z:%s]",
                angle,axis.x,axis.y,axis.z))
        end
    end
    return FPQuaternion(x,y,z,w)
end

function FPQuaternion.Euler(a,b,c)
    local x,y,z,w
    if c then
        x,y,z,w = fixpoint.FPQuaternion_Euler(a,b,c)
        if DEBUG_FP then
            local debugFPQuaternion = CS_FPQuaternion.Euler(a,b,c)
            if debugFPQuaternion.x ~= x or debugFPQuaternion.y ~= y or debugFPQuaternion.z ~= z or debugFPQuaternion.w ~= w then
                assert(false,string.format("FPQuaternion.Euler,计算结果不一致[x:%s][y:%s][z:%s]",
                    a,b,c))
            end
        end
    else
        x,y,z,w = fixpoint.FPQuaternion_Euler(a.x,a.y,a.z)
        if DEBUG_FP then
            local debugFPQuaternion = CS_FPQuaternion.Euler(a)
            if debugFPQuaternion.x ~= x or debugFPQuaternion.y ~= y or debugFPQuaternion.z ~= z or debugFPQuaternion.w ~= w then
                assert(false,string.format("FPQuaternion.Euler,计算结果不一致[x:%s][y:%s][z:%s]",
                    a.x,a.y,a.z))
            end
        end
    end

    return FPQuaternion(x,y,z,w)
end

--TODO:移植tolua Quaternion
function FPQuaternion.FromToRotation(from,to)
end

function FPQuaternion.Inverse(rotation,toQuat)
    local quat = toQuat or FPQuaternion(0,0,0,0)
    quat:Set(-rotation.x, -rotation.y, -rotation.z, rotation.w)
    return quat
end

function FPQuaternion.Lerp(a,b,t)
    local x,y,z,w = fixpoint.FPQuaternion_Lerp(a.x,a.y,a.z,a.w,b.x,b.y,b.z,b.w,t)
    if DEBUG_FP then
        local debugQuaternion = CS_FPQuaternion.Lerp(CS_FPQuaternion(a.x,a.y,a.z,a.w),CS_FPQuaternion(b.x,b.y,b.z,b.w),t)
        if debugQuaternion.x ~= x or debugQuaternion.y ~= y or debugQuaternion.z ~= z or debugQuaternion.w ~= w then
            assert(false,string.format("FPQuaternion.Lerp,计算结果不一致[a_x:%s][a_y:%s][a_z:%s][a_w:%s][b_x:%s][b_y:%s][b_z:%s][b_w:%s][t:%s]",
                a.x,a.y,a.z,a.w,b.x,b.y,b.z,b.w,t))
        end
    end
    return FPQuaternion(x,y,z,w)
end

function FPQuaternion.LerpUnclamped(a,b,t)
    local x,y,z,w = fixpoint.FPQuaternion_LerpUnclamped(a.x,a.y,a.z,a.w,b.x,b.y,b.z,b.w,t)
    if DEBUG_FP then
        local debugQuaternion = CS_FPQuaternion.LerpUnclamped(CS_FPQuaternion(a.x,a.y,a.z,a.w),CS_FPQuaternion(b.x,b.y,b.z,b.w),t)
        if debugQuaternion.x ~= x or debugQuaternion.y ~= y or debugQuaternion.z ~= z or debugQuaternion.w ~= w then
            assert(false,string.format("FPQuaternion.LerpUnclamped,计算结果不一致[a_x:%s][a_y:%s][a_z:%s][a_w:%s][b_x:%s][b_y:%s][b_z:%s][b_w:%s][t:%s]",
                a.x,a.y,a.z,a.w,b.x,b.y,b.z,b.w,t))
        end
    end
    return FPQuaternion(x,y,z,w)
end

function FPQuaternion.LookRotation(forward,upwards)
    local x,y,z,w
    if upwards then
        x,y,z,w = fixpoint.FPQuaternion_LookRotation(forward.x,forward.y,forward.z,upwards.x,upwards.y,upwards.z)
        if DEBUG_FP then
            local debugQuaternion = CS_FPQuaternion.LookRotation(CS_FPVector3(forward.x,forward.y,forward.z),CS_FPVector3(upwards.x,upwards.y,upwards.z))
            if debugQuaternion.x ~= x or debugQuaternion.y ~= y or debugQuaternion.z ~= z or debugQuaternion.w ~= w then
                assert(false,string.format("FPQuaternion.LookRotation,计算结果不一致[forward_x:%s]forward_y:%s][forward_z:%s][upwards_x:%s][upwards_y:%s][upwards_z:%s]",
                    forward.x,forward.y,forward.z,upwards.x,upwards.y,upwards.z))
            end
        end
    else
        x,y,z,w = fixpoint.FPQuaternion_LookRotation(forward.x,forward.y,forward.z,FPVector3.up.x,FPVector3.up.y,FPVector3.up.z)
        if DEBUG_FP then
            local debugQuaternion = CS_FPQuaternion.LookRotation(CS_FPVector3(forward.x,forward.y,forward.z),CS_FPVector3(FPVector3.up.x,FPVector3.up.y,FPVector3.up.z))
            if debugQuaternion.x ~= x or debugQuaternion.y ~= y or debugQuaternion.z ~= z or debugQuaternion.w ~= w then
                assert(false,string.format("FPQuaternion.LookRotation,计算结果不一致[forward_x:%s]forward_y:%s][forward_z:%s][upwards_x:%s][upwards_y:%s][upwards_z:%s]",
                    forward.x,forward.y,forward.z,FPVector3.up.x,FPVector3.up.y,FPVector3.up.z))
            end
        end
    end

    return FPQuaternion(x,y,z,w)
end

function FPQuaternion.RotateTowards(from,to,maxDegreesDelta)
    local x,y,z,w = fixpoint.FPQuaternion_RotateTowards(from.x,from.y,from.z,from.w,to.x,to.y,to.z,to.w,maxDegreesDelta)
    if DEBUG_FP then
        local debugQuaternion = CS_FPQuaternion.RotateTowards(CS_FPQuaternion(from.x,from.y,from.z,from.w),CS_FPQuaternion(to.x,to.y,to.z,to.w),maxDegreesDelta)
        if debugQuaternion.x ~= x or debugQuaternion.y ~= y or debugQuaternion.z ~= z or debugQuaternion.w ~= w then
            assert(false,string.format("FPQuaternion.RotateTowards,计算结果不一致[from_x:%s]from_y:%s][from_z:%s][from_w:%s][to_x:%s][to_y:%s][to_z:%s][to_w:%s][maxDegreesDelta:%s]",
            from.x,from.y,from.z,from.w,to.x,to.y,to.z,to.w,maxDegreesDelta))
        end
    end
    return FPQuaternion(x,y,z,w)
end

function FPQuaternion.Slerp(a,b,t)
    local x,y,z,w = fixpoint.FPQuaternion_Slerp(a.x,a.y,a.z,a.w,b.x,b.y,b.z,b.w,t)
    if DEBUG_FP then
        local debugQuaternion = CS_FPQuaternion.Slerp(CS_FPQuaternion(a.x,a.y,a.z,a.w),CS_FPQuaternion(b.x,b.y,b.z,b.w),t)
        if debugQuaternion.x ~= x or debugQuaternion.y ~= y or debugQuaternion.z ~= z or debugQuaternion.w ~= w then
            assert(false,string.format("FPQuaternion.Slerp,计算结果不一致[a_x:%s][a_y:%s][a_z:%s][a_w:%s][b_x:%s][b_y:%s][b_z:%s][b_w:%s][t:%s]",
                a.x,a.y,a.z,a.w,b.x,b.y,b.z,b.w,t))
        end
    end
    return FPQuaternion(x,y,z,w)
end

function FPQuaternion.SlerpUnclamped(a,b,t)
    local x,y,z,w = fixpoint.FPQuaternion_SlerpUnclamped(a.x,a.y,a.z,a.w,b.x,b.y,b.z,b.w,t)
    if DEBUG_FP then
        local debugQuaternion = CS_FPQuaternion.SlerpUnclamped(CS_FPQuaternion(a.x,a.y,a.z,a.w),CS_FPQuaternion(b.x,b.y,b.z,b.w),t)
        if debugQuaternion.x ~= x or debugQuaternion.y ~= y or debugQuaternion.z ~= z or debugQuaternion.w ~= w then
            assert(false,string.format("FPQuaternion.SlerpUnclamped,计算结果不一致[a_x:%s][a_y:%s][a_z:%s][a_w:%s][b_x:%s][b_y:%s][b_z:%s][b_w:%s][t:%s]",
                a.x,a.y,a.z,a.w,b.x,b.y,b.z,b.w,t))
        end
    end
    return FPQuaternion(x,y,z,w)
end

function FPQuaternion.Dot(a,b)
    if DEBUG_FP and fixpoint.FPQuaternion_Dot(a.x,a.y,a.z,a.w,b.x,b.y,b.z,b.w) ~= CS_FPQuaternion.Dot(CS_FPQuaternion(a.x,a.y,a.z,a.w),CS_FPQuaternion(b.x,b.y,b.z,b.w)) then
        assert(false,string.format("FPQuaternion.Dot,计算结果不一致[a_x:%s][a_y:%s][a_z:%s][a_w:%s][b_x:%s][b_y:%s][b_z:%s][b_w:%s]",
            a.x,a.y,a.z,a.w,b.x,b.y,b.z,b.w))
    end
    return fixpoint.FPQuaternion_Dot(a.x,a.y,a.z,a.w,b.x,b.y,b.z,b.w)
end

--TODO:等待实现
function FPQuaternion:SetFromToRotation(from,to)
    --this = FromToRotation(from, to);
end

function FPQuaternion:SetLookRotation(view,up)
    local x,y,z,w
    if up then
        x,y,z,w = fixpoint.FPQuaternion_LookRotation(view.x,view.y,view.z,up.x,up.y,up.z)
        if DEBUG_FP then
            local debugQuaternion = CS_FPQuaternion.LookRotation(CS_FPVector3(view.x,view.y,view.z),CS_FPVector3(up.x,up.y,up.z))
            if debugQuaternion.x ~= x or debugQuaternion.y ~= y or debugQuaternion.z ~= z or debugQuaternion.w ~= w then
                assert(false,string.format("FPQuaternion.SetLookRotation,计算结果不一致[view_x:%s][view_y:%s][view_z:%s][up_x:%s][up_y:%s][up_z:%s]",
                    view.x,view.y,view.z,up.x,up.y,up.z))
            end
        end
    else
        x,y,z,w = fixpoint.FPQuaternion_LookRotation(view.x,view.y,view.z,FPVector3.up.x,FPVector3.up.y,FPVector3.up.z)
        if DEBUG_FP then
            local debugQuaternion = CS_FPQuaternion.LookRotation(CS_FPVector3(view.x,view.y,view.z),CS_FPVector3(FPVector3.up.x,FPVector3.up.y,FPVector3.up.z))
            if debugQuaternion.x ~= x or debugQuaternion.y ~= y or debugQuaternion.z ~= z or debugQuaternion.w ~= w then
                assert(false,string.format("FPQuaternion.SetLookRotation,计算结果不一致[view_x:%s][view_y:%s][view_z:%s][up_x:%s][up_y:%s][up_z:%s]",
                    view.x,view.y,view.z,FPVector3.up.x,FPVector3.up.y,FPVector3.up.z))
            end
        end
    end

    self:Set(x,y,z,w)
end

function FPQuaternion:ToAngleAxis(axis)
    local angle,x,y,z = fixpoint.FPQuaternion_ToAngleAxis(self.x,self.y,self.z,self.w)
    if DEBUG_FP then
        local debugAngle = 0
        local debugFPVector3 = CS_FPVector3(0,0,0)
        local debugFPQuaternion = CS_FPQuaternion(self.x,self.y,self.z,self.w)
        debugAngle,debugFPVector3 = debugFPQuaternion:ToAngleAxis(debugAngle,debugFPVector3)
        if angle ~= debugAngle or x ~= debugFPVector3.x or y ~= debugFPVector3.y or z ~= debugFPVector3.z then
            assert(false,string.format("FPQuaternion.ToAngleAxis,计算结果不一致[q_x:%s][q_y:%s][q_z:%s][q_w:%s]",
                self.x,self.y,self.z,self.w))
        end
    end

    axis:Set(x,y,z)
    return angle
end


function FPQuaternion.MatrixToEuler(m)
    local x,y,z = fixpoint.FPQuaternion_MatrixToEuler(m.m00,m.m10,m.m20,m.m01,m.m11,m.m21,m.m02,m.m12,m.m22)
    if DEBUG_FP then
        local debugQuaternion = CS_FPQuaternion(0,0,0,0)
        local debugFPVector3 = debugQuaternion:MatrixToEuler(CS_FPMatrix33(CS_FPVector3(m.m00,m.m10,m.m20),CS_FPVector3(m.m01,m.m11,m.m21),CS_FPVector3(m.m02,m.m12,m.m22)))
        if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
            assert(false,string.format("FPQuaternion.MatrixToQuaternion,计算结果不一致[m00:%s][m10:%s][m20:%s][m01:%s][m11:%s][m21:%s][m02:%s][m12:%s][m22:%s]",
                m.m00,m.m10,m.m20,m.m01,m.m11,m.m21,m.m02,m.m12,m.m22))
        end
    end
    return FPVector3(x,y,z)
end


function FPQuaternion.QuaternionToMatrix(q)
    local m00,m10,m20,m01,m11,m21,m02,m12,m22 = fixpoint.FPQuaternion_QuaternionToMatrix(q.x,q.y,q.z,q.w)
    if DEBUG_FP then
        local debugMatrix33 = CS_FPQuaternion.QuaternionToMatrix(CS_FPQuaternion(q.x,q.y,q.z,q.w))
        if m00 ~= debugMatrix33.m00 or m10 ~= debugMatrix33.m10 or m20 ~= debugMatrix33.m20 
            or m01 ~= debugMatrix33.m01 or m11 ~= debugMatrix33.m11 or m21 ~= debugMatrix33.m21 
            or m02 ~= debugMatrix33.m02 or m12 ~= debugMatrix33.m12 or m22 ~= debugMatrix33.m22 then
            assert(false,string.format("FPQuaternion.QuaternionToMatrix,计算结果不一致[q_x:%s][q_y:%s][q_z:%s][q_w:%s]",
                q.x,q.y,q.z,q.w))
        end
    end
    return FPMatrix33(FPVector3(m00,m10,m20),FPVector3(m01,m11,m21),FPVector3(m02,m12,m22))
end

function FPQuaternion.MatrixToQuaternion(m)
    local ret,x,y,z,w = fixpoint.FPQuaternion_MatrixToQuaternion(m.m00,m.m10,m.m20,m.m01,m.m11,m.m21,m.m02,m.m12,m.m22)
    if ret == 0 then
        assert(false,"error!")
    end

    if DEBUG_FP then
        local debugQuaternion = CS_FPQuaternion.MatrixToQuaternion(CS_FPMatrix33(CS_FPVector3(m.m00,m.m10,m.m20),CS_FPVector3(m.m01,m.m11,m.m21),CS_FPVector3(m.m02,m.m12,m.m22)))
        if debugQuaternion.x ~= x or debugQuaternion.y ~= y or debugQuaternion.z ~= z or debugQuaternion.w ~= w then
            assert(false,string.format("FPQuaternion.MatrixToQuaternion,计算结果不一致[m00:%s][m10:%s][m20:%s][m01:%s][m11:%s][m21:%s][m02:%s][m12:%s][m22:%s]",
                m.m00,m.m10,m.m20,m.m01,m.m11,m.m21,m.m02,m.m12,m.m22))
        end
    end
    return FPQuaternion(x,y,z,w)
end


function FPQuaternion.LookRotationToMatrix(viewVec,upVec)
    local m00,m10,m20,m01,m11,m21,m02,m12,m22 = fixpoint.FPQuaternion_LookRotationToMatrix(viewVec.x,viewVec.y,viewVec.z,upVec.x,upVec.y,upVec.z)
    if DEBUG_FP then
        local debugMatrix33 = CS_FPQuaternion.LookRotationToMatrix(CS_FPVector3(viewVec.x,viewVec.y,viewVec.z),CS_FPVector3(upVec.x,upVec.y,upVec.z))
        if m00 ~= debugMatrix33.m00 or m10 ~= debugMatrix33.m10 or m20 ~= debugMatrix33.m20 
            or m01 ~= debugMatrix33.m01 or m11 ~= debugMatrix33.m11 or m21 ~= debugMatrix33.m21 
            or m02 ~= debugMatrix33.m02 or m12 ~= debugMatrix33.m12 or m22 ~= debugMatrix33.m22 then
            assert(false,string.format("FPQuaternion.LookRotationToMatrix,计算结果不一致[viewVec_x:%s][viewVec_y:%s][viewVec_z:%s][upVec_x:%s][upVec_y:%s][upVec_z:%s]",
                viewVec.x,viewVec.y,viewVec.z,upVec.x,upVec.y,upVec.z))
        end
    end
    return FPMatrix33(FPVector3(m00,m10,m20),FPVector3(m01,m11,m21),FPVector3(m02,m12,m22))
end


FPQuaternion.__eq = function(q1,q2)
	return q1.x == q2.x and q1.y == q2.y and q1.z == q2.z and q1.w == q2.w
end

FPQuaternion.__mul = function(a,b)
	if b.key == FPQuaternion.key then
		local x,y,z,w = fixpoint.FPQuaternion_Mul(a.x,a.y,a.z,a.w,b.x,b.y,b.z,b.w)
        if DEBUG_FP then
            local debugQuaternion = CS_FPQuaternion(a.x,a.y,a.z,a.w) * CS_FPQuaternion(b.x,b.y,b.z,b.w)
            if debugQuaternion.x ~= x or debugQuaternion.y ~= y or debugQuaternion.z ~= z or debugQuaternion.w ~= w then
                assert(false,string.format("FPQuaternion.__mul,计算结果不一致[a_x:%s][a_y:%s][a_z:%s][a_w:%s][b_x:%s][b_y:%s][b_z:%s][b_w:%s]",
                a.x,a.y,a.z,a.w,b.x,b.y,b.z,b.w))
            end
        end
        return FPQuaternion(x,y,z,w)
	else
		local x,y,z = fixpoint.FPQuaternion_Mul_v(a.x,a.y,a.z,a.w,b.x,b.y,b.z)
        if DEBUG_FP then
            local debugFPVector3 = CS_FPQuaternion(a.x,a.y,a.z,a.w) * CS_FPVector3(b.x,b.y,b.z)
            if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
                assert(false,string.format("FPQuaternion.__mul,计算结果不一致[a_x:%s][a_y:%s][a_z:%s][a_w:%s][b_x:%s][b_y:%s][b_z:%s]",
                a.x,a.y,a.z,a.w,b.x,b.y,b.z))
            end
        end
        return FPVector3(x,y,z)
	end
end


setmetatable(FPQuaternion, FPQuaternion)