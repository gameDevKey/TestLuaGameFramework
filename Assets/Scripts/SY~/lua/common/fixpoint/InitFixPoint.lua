LUA_FP = true
LUA_CALC = true


if not LUA_FP then
    FPFloat = CS.FPFloat
    FPMath = CS.FPMath
    FPVector3 = CS.FPVector3
    FPVector2 = CS.FPVector2
    FPAxis2D = CS.FPAxis2D
    FPAxis3D = CS.FPAxis3D
    FPMatrix33 = CS.FPMatrix33
    FPQuaternion = CS.FPQuaternion
    FPRandom = CS.FPRandom
    FPCollision2D = CS.FPCollision2D
end

if not IS_CHECK then
    CS_FPFloat = CS.FPFloat
    CS_FPMath = CS.FPMath
    CS_FPVector3 = CS.FPVector3
    CS_FPVector2 = CS.FPVector2
    CS_FPAxis3D = CS.FPAxis3D
    CS_FPMatrix33 = CS.FPMatrix33
    CS_FPQuaternion = CS.FPQuaternion
    CS_FPRandom = CS.FPRandom
    CS_FPCollision2D = CS.FPCollision2D
end


DEBUG_FP = false

function test_fixedpoint()
    --FPFloat
    FPFloat.Mul_ii(1000,500)
    FPFloat.Div_ii(1000,500)
    FPFloat.ToInt(1000)
    FPFloat.ToFPFloat(1000)
    FPFloat.FloorToInt(1001)

    --FPMath
    FPMath.Atan2(1000,500)
    FPMath.Acos(1000)
    FPMath.Asin(1000)
    FPMath.Sin(1000)
    FPMath.Cos(1000)
    FPMath.SinCos(1000)
    FPMath.Sqrt32(1000)
    FPMath.Sqrt64(1000)
    FPMath.Sqrt_i(1000)
    FPMath.Sqrt(1000)
    FPMath.SqrtLong(1000)
    FPMath.Sqr(1000)
    FPMath.Clamp(1001,1,1000)
    FPMath.Clamp01(1001)
    FPMath.SameSign(100,200)
    FPMath.Abs(1000)
    FPMath.Round(-1000)
    FPMath.Round(1000)
    FPMath.MaxByAry({1,3,4})
    FPMath.MinByAry({1,3,4})
    FPMath.Lerp(1000,2000,600)
    FPMath.IsPowerOfTwo(1000)
    FPMath.CeilPowerOfTwo(1000)
    FPMath.Divide(10000,33)
    FPMath.Divide_ll(3147483648,33)
    FPMath.DivideByCeil(10000,33)
    FPMath.DivideByCeil_ll(3147483648,33)
    FPMath.DivideByRound(10000,33)
    FPMath.DivideByRound_ll(3147483648,33)

    FPMath.Transform(FPVector3(100,200,300),FPVector3(400,500,600),FPVector3(700,800,900),FPVector3(100,200,300),FPVector3(400,500,600),FPVector3(700,800,900))
    FPMath.Transform(FPVector3(100,200,300),FPVector3(400,500,600),FPVector3(700,800,900),FPVector3(100,200,300),FPVector3(400,500,600))
    FPMath.Transform(FPVector3(100,200,300),FPVector3(400,500,600),FPVector3(700,800,900),FPVector3(100,200,300))
    FPMath.Transform(FPVector3(100,200,300),FPVector3(400,500,600),FPVector3(700,800,900))

    FPMath.MoveTowards(FPVector3(0,0,1000),FPVector3(0,0,1200),1000)
    FPMath.MoveTowards(FPVector3(0,0,1000),FPVector3(0,0,3000),1000)
    FPMath.AngleInt(FPVector3(100,200,300),FPVector3(400,500,600))
    FPMath.ToFPVector3(Vector3(3.8,1.5,10.2),FPVector3(0,0,0))


    --FPVector3
    local v3_1 = FPVector3(500,600,300)
    local _ = v3_1.magnitude
    local _ = v3_1.magnitude2D
    local _ = v3_1.sqrMagnitude

    local v3_2 = FPVector3(500,600,300)
    v3_2:Normalize()
    v3_2:NormalizeTo(10086)

    local v3_3 = FPVector3(500,600,300)
    local _ = v3_3.normalized
    
    local v3_4 = FPVector3(0,0,1000)
    local _ = v3_4:RotateX(90000)

    local v3_5 = FPVector3(0,0,1000)
    local _ = v3_5:RotateY(90000)

    local v3_6 = FPVector3(0,1000,0)
    local _ = v3_6:RotateZ(-90000)

    local _ = v3_4 == v3_5

    local _ = FPVector3(1000,1000,1000) - FPVector3(500,0,300)
    local _ = -FPVector3(1000,1000,1000)
    local _ = FPVector3(1000,1000,1000) + FPVector3(500,0,300)
    local _ = FPVector3(1000,1000,1000) * 500
    local _ = FPVector3(1000,1000,1000) * FPVector3(500,0,300)
    local _ = FPVector3(1000,1000,1000) / 100

    FPVector3.Dot(FPVector3(1000,1000,1000) , FPVector3(500,0,300))
    FPVector3.Cross(FPVector3(1000,1000,1000) , FPVector3(500,0,300))
    FPVector3.Lerp(FPVector3(1000,1000,1000) , FPVector3(500,0,300),600)



    --FPVector2
    FPVector2.Rotate(FPVector2(0,1000),90000)
    FPVector2.Min(FPVector2(0,1000),FPVector2(0,1000))

    local v2_1 = FPVector2(400,450)
    v2_1:Normalize()

    local v2_2 = FPVector2(400,450)
    v2_2:NormalizeTo(2000)

    local _ = FPVector2(400,450).sqrMagnitude
    local _ = FPVector2(400,450).sqrMagnitudeLong
    local _ = FPVector2(400,450).rawSqrMagnitude
    local _ = FPVector2(400,450).magnitude
    local _ = FPVector2(400,450).normalized

    local _ = FPVector2(1000,1000) + FPVector2(500,0)
    local _ = FPVector2(1000,1000) - FPVector2(500,0)
    local _ = FPVector2(1000,1000) * 300
    local _ = FPVector2(1000,1000) * FPVector3(500,300)
    local _ = FPVector2(1000,1000) / 300

    FPVector2.Dot(FPVector2(1000,1000) , FPVector2(500,300))
    FPVector2.Cross(FPVector2(1000,1000) , FPVector2(500,300))
    FPVector2.Cross2D(FPVector2(1000,1000) , FPVector2(500,300))
    FPVector2.Lerp(FPVector2(1000,1000) , FPVector2(500,300),600)


    --FPAxis2D
    local _ = FPAxis2D.New()


    --FPAxis3D
    local axis3D_1 = FPAxis3D(FPVector3(100,200,300),FPVector3(400,500,600),FPVector3(700,800,900))
    local _ = axis3D_1:WorldToLocal(FPVector3(666,444,565))
    local _ = axis3D_1:LocalToWorld(FPVector3(666,444,565))


    --FPMatrix33
    local m33_1 = FPMatrix33(FPVector3(100,200,300),FPVector3(400,500,600),FPVector3(700,800,900))
    local m33_2 = FPMatrix33(FPVector3(100,200,300),FPVector3(400,500,600),FPVector3(700,800,900))
    local _ = m33_1 * m33_2
    local _ = m33_1 * FPVector3(100,200,300)


    --FPQuaternion
    local _ = FPQuaternion(1312,1231,500,1322).eulerAngles
    FPQuaternion(1312,1231,500,1322).eulerAngles = FPVector3(400,500,600)

    local _ = FPQuaternion(1312,1231,500,1322) * FPQuaternion(111,231,1131,800)
    local _ = FPQuaternion(1312,1231,500,1322) * FPVector3(400,500,600)

    FPQuaternion(1312,1231,500,1322):ToQuaternion(Quaternion(0,0,0,0))

    FPQuaternion.Angle(FPQuaternion(600,300,311,0),FPQuaternion(800,300,511,0))
    FPQuaternion.AngleAxis(18000,FPVector3(0,200,300))
    FPQuaternion.Euler(565,888,668)
    FPQuaternion.Euler(FPVector3(0,200,300))

    FPQuaternion.Lerp(FPQuaternion(1000,2000,3000,1000),FPQuaternion(3000,4000,4000,600),6000)
    FPQuaternion.LerpUnclamped(FPQuaternion(1000,2000,3000,1000),FPQuaternion(3000,4000,4000,600),600)

    FPQuaternion.LookRotation(FPVector3(100,200,300),FPVector3(400,500,600))
    FPQuaternion.LookRotation(FPVector3(100,200,300))

    FPQuaternion.RotateTowards(FPQuaternion.LookRotation(FPVector3(0,1000,0)),FPQuaternion(-100,032131,-1111,0),6000)

    FPQuaternion.Slerp(FPQuaternion(1000,2000,3000,1000),FPQuaternion(3000,4000,4000,600),600)
    FPQuaternion.SlerpUnclamped(FPQuaternion(1000,2000,3000,1000),FPQuaternion(3000,4000,4000,600),600)

    FPQuaternion.Dot(FPQuaternion(1312,1231,500,1322),FPQuaternion(111,231,1131,800))

    local q_3 = FPQuaternion(111,231,1131,800)
    q_3:SetLookRotation(FPVector3(0,2200,1300))

    local q_4 = FPQuaternion(111,231,1131,800)
    q_4:SetLookRotation(FPVector3(0,2200,1300),FPVector3(1000,2200,1300))

    local q_1 = FPQuaternion(111,231,1131,800)
    local _ = q_1:ToAngleAxis(FPVector3(0,0,0))

    FPQuaternion.MatrixToEuler(FPMatrix33(FPVector3(100,200,300),FPVector3(400,500,600),FPVector3(700,1200,900)))
    FPQuaternion.QuaternionToMatrix(FPQuaternion(1312,1231,500,1322))
    FPQuaternion.MatrixToQuaternion(FPMatrix33(FPVector3(0,200,300),FPVector3(400,0,600),FPVector3(700,800,0)))
    FPQuaternion.LookRotationToMatrix(FPVector3(100,200,300),FPVector3(400,500,600))

    

    --FPRandom
    local seed = math.randomseed(tostring(os.time()):reverse():sub(1, 7))

    local random1 = FPRandom(seed)
    local random2 = FPRandom(seed)

    for i=1,10000 do
        local val1 = random1:Next(13199933)
        local val2 = random2:Next(13199933)
        if val1 ~= val2 then
            assert(false,string.format("FPRandom.Next,随机结果不一致[index:%s][val1:%s][val2:%s]",i,val1,val2))
        end

        local val1 = random1:Next(13199933)
        local val2 = random2:Next(13199933)
        if val1 ~= val2 then
            assert(false,string.format("FPRandom.Next,随机结果不一致[index:%s][val1:%s][val2:%s]",i,val1,val2))
        end
    end

    for i=1,10000 do
        local val1 = random1:Range(-13031,13199931113)
        local val2 = random2:Range(-13031,13199931113)
        if val1 ~= val2 then
            assert(false,string.format("FPRandom.Range,随机结果不一致[index:%s][val1:%s][val2:%s]",i,val1,val2))
        end

        local val1 = random1:Range(13031,13199931113)
        local val2 = random2:Range(13031,13199931113)
        if val1 ~= val2 then
            assert(false,string.format("FPRandom.Range,随机结果不一致[index:%s][val1:%s][val2:%s]",i,val1,val2))
        end
    end

    --FPCollision2D
    FPCollision2D.PointInCircle(FPVector2(1000,1000),FPVector2(1200,1000),5000)
    FPCollision2D.CircleInCircle(FPVector2(1000,1000),500,FPVector2(1200,1000),500)
end

if DEBUG_FP then
    test_fixedpoint()
end

