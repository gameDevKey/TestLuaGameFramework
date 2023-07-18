local tester = { tb = {}, calculator = Calculator.New() }
function tester:add(calc, result)
    table.insert(self.tb, { calc = calc, result = result })
end

function tester:start()
    for index, data in ipairs(self.tb) do
        self.calculator:SetPattern(data.calc)
        local result = self.calculator:Calc()

        if result ~= data.result then
            print(data.calc, "结果", result, "错误,应为", data.result)
        end
    end
    print("测试结束")
end

local TEST_ALL = false
local TEST_FU = false
local TEST_VAR = false


if TEST_ALL then
    -- 逻辑
    tester:add("not(3)+if(1,2,3)", 2)
    tester:add("if((9-6),2,3)", 2)
    tester:add("-if(1,2,3)", -2)
    tester:add("(1-if(if(1+1!=2,not(2),not(3)),2+3,4+5))*6+(1*-33/(4+8+(6*-8)/48)", -51)
    tester:add("if(if(1,2,3),2+3,4+5)", 5)
    tester:add("if(if(1+1!=2,not(2),not(3)),2+3,4+5)", 9)
    tester:add("not(0)", 1)
    tester:add("max(1,2)", 2)
    tester:add("min(3,4)", 3)

    -- 四则运算
    tester:add("1---if(1,2,3)+-not(3)", -1)
    tester:add("1--2+(--5/-+-5)", 4)
    tester:add("((9-3)*(8-5)-2+(4-5))*(2-3)/(5-2)", -5)
    -- tester:add("1*-1/(1+1.05+(1*-2))/2.5", -8) --这里的错误应该是除法有浮点数但是没有显示出来
    tester:add("-+1*-2+-24", -22)
    tester:add("--(--1+-2)", -1)
    tester:add("!--3", 0)
    tester:add("!!--3", 1)
    tester:add("+-3", -3)
    tester:add("--3", 3)
    tester:add("+-3-+4", -7)
    tester:add("-2*3", -6)
    tester:add("-2*-3", 6)
    tester:add("-2*-if(1,2,3)", 4)

    -- 比较
    tester:add("-1==-2", 0)
    tester:add("-1>=-2", 1)
    tester:add("-1>-2", 1)
    tester:add("-1<=-2", 0)
    tester:add("-1<-2", 0)
    tester:add("-1!=-2", 1)
    tester:add("---1!=++1-2", 0)
end

-- 错误输入
-- tester:add("1>>>2", 0)

tester:start()


if TEST_FU then
    --复用逻辑
    local calculator = Calculator.New()
    calculator:SetPattern("1+a-5")
    calculator:SetVarVal("a", 100)
    print("100 结果", calculator:Calc())
    calculator:SetVarVal("a", 200)
    print("200 结果", calculator:Calc())
    print("修改公式")
    calculator:SetPattern("1+a")
    calculator:SetVarVal("a", 300)
    print("300 结果", calculator:Calc())
    calculator:SetVarVal("a", 400)
    print("400 结果", calculator:Calc())
end

if TEST_VAR then
    local calculator = Calculator.New()
    calculator:SetPattern("1+a-5")
    calculator:SetVarVal("a", 100)
    print("1+a-5 结果", calculator:Calc())
    calculator:SetPattern("1+a.b-5")
    calculator:SetVarVal("a.b", 100)
    print("1+a.b-5 结果", calculator:Calc())
    calculator:SetPattern("1+abc.efg.hij-k89g")
    calculator:SetVarVal("abc.efg.hij", 100)
    calculator:SetVarVal("k89g", 2)
    print("1+abc.efg.hij-k89g 结果", calculator:Calc())
    --错误案例
    -- calculator:SetPattern("1+a.b.-5")
    -- calculator:SetVarVal("a.b.", 100)
    -- print("1+a.b.-5 结果", calculator:Calc())
end

-- local regex = "^[a-zA-Z][a-zA-Z0-9.]*[a-zA-Z0-9]?[^.]$"
-- -- local regex = "^[a-zA-Z][a-zA-Z0-9.]*[a-zA-Z0-9]?$"
-- local strs = { ".", ".ab", "a", "ab", "ab.", 'a.e', "ab.ef", 'ac.e.ff.', "a,c,b", "1+a+5" }
-- for _, str in ipairs(strs) do
--     local a, b = str:find(regex)
--     print(str, '匹配', a, b)
-- end
