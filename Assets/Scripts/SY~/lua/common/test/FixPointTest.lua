FixPointTest = StaticClass("FixPointTest")

function FixPointTest.Test()
    FixPointTest.Test1()
    FixPointTest.Test2()
    FixPointTest.Test3()
    FixPointTest.Test4()
end

function FixPointTest.Test1()
    local t = os.clock()
    for i=1,1000000 do
        FPMath.Lerp(i,1000000,1000)
        FPMath.Divide(i, 10000)
        FPMath.DivideByCeil(i, 10000)
        FPMath.Lerp(i,1000000,1000)
    end
    print("fixpoint c cost time: ", os.clock() - t)
end


function FixPointTest.Test2()
    -- local t = os.clock()
    -- for i=1,1000000 do
    --     FPMath.Lerp_Lua(i,1000000,1000)
    --     FPMath.Divide_Lua(i, 10000)
    --     FPMath.DivideByCeil_Lua(i, 10000)
    --     FPMath.Lerp_Lua(i,1000000,1000)
    -- end
    -- print("fixpoint lua cost time: ", os.clock() - t)
end

function FixPointTest.Test3()
    local t = os.clock()
    for i=1,1000000 do
        CS.FPMath.Lerp(i,1000000,1000)
        CS.FPMath.Divide(i, 10000)
        CS.FPMath.DivideByCeil(i, 10000)
        CS.FPMath.Lerp(i,1000000,1000)
    end
    print("fixpoint c# cost time: ", os.clock() - t)
end

function FixPointTest.Test4()
    local t = os.clock()
    for i=1,1000000 do
        local _ = FPVector3(i,i,i)
    end
    print("fixpoint FPVector3.New lua cost time: ", os.clock() - t)
end