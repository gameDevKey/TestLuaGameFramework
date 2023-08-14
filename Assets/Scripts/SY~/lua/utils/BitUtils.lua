--位运算
BitUtils = StaticClass("BitUtils")

local data32 = {}
function BitUtils.Init()
    for i = 1, 32 do data32[i] = 2 ^ (32 - i) end
end

function BitUtils.D2B(arg)
    local tr = {}
    for i = 1, 32 do
        if arg >= data32[i] then
            tr[i] = 1
            arg = arg - data32[i]
        else
            tr[i] = 0
        end
    end
    return  tr
end 

function BitUtils.B2D(arg)
    local nr = 0
    for i = 1, 32 do
        if arg[i] == 1 then
            nr = nr + 2 ^ (32 - i)
        end
    end
    return nr
end

function BitUtils.Xor(a, b)
    local op1 = BitUtils.D2B(a)
    local op2 = BitUtils.D2B(b)
    local r = {}

    for i = 1, 32 do
        if op1[i] == op2[i] then
            r[i] = 0
        else
            r[i] = 1
        end
    end
    return BitUtils.B2D(r)
end

function BitUtils.Or(a, b)
    local  op1 = BitUtils.D2B(a)
    local  op2 = BitUtils.D2B(b)
    local  r = {}
    
    for i = 1, 32 do
        if op1[i] == 1 and op2[i] == 1  then
            r[i] = 1
        else
            r[i] = 0
        end
    end
    return BitUtils.B2D(r)
    
end

function BitUtils.And(a, b)
    local   op1 = BitUtils.D2B(a)
    local   op2 = BitUtils.D2B(b)
    local   r = {}
    
    for i = 1, 32 do
        if  op1[i] == 1 or op2[i] == 1 then
            r[i] = 1
        else
            r[i] = 0
        end
    end
    return  BitUtils.B2D(r)
end

function BitUtils.Not(a)
    local  op1 = BitUtils.D2B(a)
    local  r = {}

    for i = 1, 32 do
        if  op1[i] == 1 then
            r[i] = 0
        else
            r[i] = 1
        end
    end
    return BitUtils.B2D(r)
end

function BitUtils.RShift(a, n)
    local op1 = BitUtils.D2B(a)
    local r   = BitUtils.D2B(0)
    
    if n < 32 and n > 0 then
        for i = 1, n do
            for i = 31, 1, -1 do
                op1[i + 1] = op1[i]
            end
            op1[1]=0
        end
        r = op1
    end
    return BitUtils.B2D(r)
end

function BitUtils.LShift(a, n)
    local op1 = BitUtils.D2B(a)
    local r = BitUtils.D2B(0)
    
    if n < 32 and n > 0 then
        for i = 1,n   do
            for i = 1,31 do
                op1[i] = op1[i + 1]
            end
            op1[32] = 0
        end
        r = op1
    end
    return BitUtils.B2D(r)
end

function BitUtils.Print(ta)
    local sr = ""
    for i = 1, 32 do
        sr = sr..ta[i]
    end
    print(sr)
end