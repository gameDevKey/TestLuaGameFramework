--[[
    公式计算器
    用法:
    local str = "((a-3)*(8-5)-2+(4-5))*(2-3)/(5-2)"
    local calc = Calculator.New()
    calc:SetPattern(str)
    calc:SetVarVal("a",6)
    print("计算",str,"结果",calc:Calc())
--]]

Calculator = Class("Calculator")

Calculator.Log = false

function Calculator:OnInit()
    self.calPattern = nil --公式
    self.kvs = {}         --变量值
end

function Calculator:OnDelete()
    self.opStack = nil
    self.resultStack = nil
    self.calcStack = nil
    self.waitOps = nil
    self.kvs = nil
end

---设置公式
---需要重新解析并计算
---@param str string
function Calculator:SetPattern(str)
    local pattern = string.trim(str)
    if self.calPattern == pattern then
        return
    end
    self.calPattern = pattern
    self.doParse = true
    self.doCalc = true
end

---设置变量的值
---只需要重新计算，不需要重新解析
---@param k any
---@param v number|function
function Calculator:SetVarVal(k, v)
    self.kvs[k] = v
    self.doCalc = true
end

---计算并返回结果，相同的公式只会计算一次
function Calculator:Calc()
    if self.doParse == true then
        self:parse()
        self.doParse = false
    end
    if self.doCalc == true then
        self:calc()
        self.doCalc = false
    end
    return self.calcStack[1]
end

function Calculator:resetParse()
    self.opStack = {}     --运算符堆栈
    self.resultStack = {} --后缀表达式堆栈
    self.waitOps = {}     --前置运算符缓存，某些运算符有修饰后面的组的作用
end

function Calculator:resetCalc()
    self.calcStack = {} --求值堆栈
end

--中缀表达式转后缀表达式
function Calculator:parse()
    self:resetParse()
    local len = string.len(self.calPattern)
    local index = 1
    local lastElem = {}
    while index <= len do
        local cur = string.sub(self.calPattern, index, index)
        self:log("----当前字符 ", cur, ' ----   位置', index)
        if cur == CalcDefine.FuncArgSplit then
            --遇到逗号截断，上一组Op入栈，并且跳过
            self:popLastOp()
            index = index + CalcDefine.FuncArgSplitLength
            lastElem.data = cur
            lastElem.type = nil
        else
            local num, endIndex = self:findNumber(cur, index, len)
            if num then
                -- 数字
                self:log("数字", num)
                self:addResult(CalcDefine.Type.Num, num)
                index = endIndex + 1
                lastElem.data = num
                lastElem.type = CalcDefine.Type.Num
            else
                local fnType, endIndex = self:findFunc(cur, index, len)
                if fnType then
                    -- 函数
                    self:log("函数", CalcDefine.FuncSign[fnType])
                    self:addOp(CalcDefine.OpKind.Func, fnType)
                    index = endIndex + 1
                    lastElem.data = fnType
                    lastElem.type = CalcDefine.Type.Func
                else
                    local op, endIndex = self:findOp(cur, index, len)
                    if op then
                        -- 运算符
                        self:log("运算符", CalcDefine.OpSign[op])
                        if CalcDefine.PrefixOp2Func[op] and
                            (index == 1 or (lastElem.type == CalcDefine.Type.Op and lastElem.data ~= CalcDefine.OpType.RBracket)) then
                            self:pushWaitOp(op)
                        else
                            if op == CalcDefine.OpType.LBracket then
                                self:addOp(CalcDefine.OpKind.Op, op)
                            elseif op == CalcDefine.OpType.RBracket then
                                self:popToLB()
                            else
                                self:insertOp(op)
                            end
                        end
                        index = endIndex + 1
                        lastElem.data = op
                        lastElem.type = CalcDefine.Type.Op
                    else
                        -- 变量
                        local var, endIndex = self:findVar(cur, index, len)
                        if var then
                            self:log("变量", var)
                            self:addResult(CalcDefine.Type.Var, var)
                            index = endIndex + 1
                            lastElem.data = var
                            lastElem.type = CalcDefine.Type.Var
                        else
                            PrintError("出现未知字符", cur, "无法解析公式:", self.calPattern)
                            return
                        end
                    end
                end
            end
            self:logStacks()
        end
    end
    self:log("添加剩余运算符")
    for i = #self.opStack, 1, -1 do
        local op = table.remove(self.opStack, i)
        if op.type == CalcDefine.OpKind.Op then
            self:addResult(CalcDefine.Type.Op, op.op)
        else
            self:addResult(CalcDefine.Type.Func, op.op)
        end
    end
    self:popWaitOp()
    self:logStacks()
end

local function findWordsByMap(calPattern, maxLen, map, enum, startIndex)
    local result = ""
    local right = startIndex
    for i = 1, maxLen do
        local str = string.sub(calPattern, right, right)
        --不在字典中，直接跳出
        local temp = result .. str
        if not map[temp] then
            break
        end
        result = temp
        right = right + 1
    end
    return enum[result], right - 1
end

function Calculator:findOp(cur, startIndex, endIndex)
    return findWordsByMap(self.calPattern, CalcDefine.MAX_OP_LEN,
        CalcDefine.OpSignMap, CalcDefine.OpSign, startIndex)
end

function Calculator:findFunc(curChar, startIndex, endIndex)
    return findWordsByMap(self.calPattern, CalcDefine.MAX_FUNC_LEN,
        CalcDefine.FuncSignMap, CalcDefine.FuncSign, startIndex)
end

function Calculator:findNumber(curChar, startIndex, endIndex)
    if tonumber(curChar) == nil then
        return
    end
    local tb = {}
    local lastIndex = startIndex - 1
    local findPoint = false
    for i = startIndex, endIndex do
        local cur = string.sub(self.calPattern, i, i)
        if cur == CalcDefine.FuncArgSplit then
            break
        end
        if cur == "." then
            if findPoint then
                PrintError("公式错误，出现了连续的小数点", self.calPattern)
                break
            end
            findPoint = true
        else
            if not string.find(cur, "%d") then
                break
            end
        end
        table.insert(tb, cur)
        lastIndex = lastIndex + 1
    end
    return tonumber(table.concat(tb)), lastIndex
end

function Calculator:findVar(curChar, startIndex, endIndex)
    --变量:首位是字母，结尾只能是字母或者数字，中间允许有点号，但是点号后面紧跟着的必须是字母
    --比如 a, abc, abc.efg, abc.efg.hij, a12, a12.e34
    local tb = {}
    local right = startIndex - 1
    local findPoint = false
    for i = startIndex, endIndex do
        local cur = string.sub(self.calPattern, i, i)
        if cur == CalcDefine.FuncArgSplit then
            break
        end
        if i == startIndex and not string.find(cur, "%a") then
            break
        end
        if findPoint then
            if cur == "." then
                PrintError("公式错误，出现了连续的小数点", self.calPattern)
                return
            end
            if not string.find(cur, "%a") then
                break
            end
            findPoint = false
        end
        if cur == "." then
            findPoint = true
        else
            if not string.find(cur, "%w") then
                break
            end
        end
        table.insert(tb, cur)
        right = right + 1
    end
    if tb[#tb] == "." then
        PrintError("变量不能以小数点结尾", self.calPattern)
        return
    end
    if #tb == 0 then
        return
    end
    return table.concat(tb), right
end

function Calculator:popLastOp()
    local len = #self.opStack
    local topOp = self.opStack[len]
    if topOp then
        if topOp.type == CalcDefine.OpKind.Op and topOp.op == CalcDefine.OpType.LBracket then
            return
        end
        table.remove(self.opStack, len)
        if topOp.type == CalcDefine.OpKind.Op then
            self:addResult(CalcDefine.Type.Op, topOp.op)
        elseif topOp.type == CalcDefine.OpKind.Func then
            self:addResult(CalcDefine.Type.Func, topOp.op)
        end
    end
end

function Calculator:popToLB()
    for i = #self.opStack, 1, -1 do
        local op = table.remove(self.opStack, i)
        if op.type == CalcDefine.OpKind.Op then
            if op.op == CalcDefine.OpType.LBracket then
                --函数都是右侧调用的，括号闭合时直接让函数入栈
                local top = self.opStack[i - 1]
                if top and top.type == CalcDefine.OpKind.Func then
                    self:log("括号闭合时直接让函数入栈")
                    op = table.remove(self.opStack, i - 1)
                    self:addResult(CalcDefine.Type.Func, op.op)
                end
                self:popWaitOp()
                break
            end
            self:addResult(CalcDefine.Type.Op, op.op)
        elseif op.type == CalcDefine.OpKind.Func then
            self:addResult(CalcDefine.Type.Func, op.op)
        end
    end
end

function Calculator:addResult(type, data)
    local sc = { type = type, data = data }
    table.insert(self.resultStack, sc)
    if type == CalcDefine.Type.Num or type == CalcDefine.Type.Var then
        local valid = true
        for _, op in ipairs(self.opStack) do
            if op.type == CalcDefine.OpKind.Func then
                valid = false
            end
        end
        if valid then
            self:popWaitOp()
        end
    end
end

function Calculator:addOp(type, op)
    local sc = { type = type, op = op }
    table.insert(self.opStack, sc)
    if type == CalcDefine.OpKind.Op then
        self:pushWaitOp(CalcDefine.OpType.Nil)
    end
end

function Calculator:insertOp(op)
    for i = #self.opStack, 1, -1 do
        local data = self.opStack[i]
        local topType = data.type
        local topOp = data.op
        if topType == CalcDefine.OpKind.Op then
            if topOp == CalcDefine.OpType.LBracket then
                --左括号停止
                break
            elseif CalcDefine.OpPriority[op] > CalcDefine.OpPriority[topOp] then
                --当前符号优先级比栈顶符号高，停止
                break
            else
                --栈顶符号入result栈，保证优先运算
                table.remove(self.opStack, i)
                self:addResult(CalcDefine.Type.Op, topOp)
            end
        elseif topType == CalcDefine.OpKind.Func then
            --函数入result栈，保证优先运算
            table.remove(self.opStack, i)
            self:addResult(CalcDefine.Type.Func, topOp)
        else
            PrintError("未知OpKind", data)
            return
        end
    end
    self:addOp(CalcDefine.OpKind.Op, op)
end

--后缀表达式求值
function Calculator:calc()
    self:resetCalc()
    for _, data in ipairs(self.resultStack) do
        if data.type == CalcDefine.Type.Func then
            local result = self:callFunc(data.data)
            table.insert(self.calcStack, result)
        elseif data.type == CalcDefine.Type.Op then
            local result = self:callFuncByOp(data.data)
            table.insert(self.calcStack, result)
        elseif data.type == CalcDefine.Type.Var then
            if not self.kvs[data.data] then
                PrintError("未定义变量具体值", data.data)
                return
            end
            local val = self.kvs[data.data]
            if IsFunction(val) then
                val = val(data.data)
            end
            table.insert(self.calcStack, val)
        elseif data.type == CalcDefine.Type.Num then
            table.insert(self.calcStack, data.data)
        else
            PrintError("求值失败，未知类型", data)
            return
        end
    end
    if #self.calcStack ~= 1 then
        PrintError("计算出错，请检查逻辑")
        return
    end
    return self.calcStack[1]
end

function Calculator:callFunc(fnType)
    if not fnType then
        return
    end
    local fnData = CalcDefine.Func[fnType]
    if not fnData then
        PrintError("未配置求值函数 FuncType=", fnType)
        return
    end
    local fn = fnData.fn
    local args = {}
    local argsCount = 0
    for i = 1, fnData.argsNum do
        local index = fnData.argsNum - i + 1 --倒序
        local num = table.remove(self.calcStack)
        args[index] = num
        if args[index] ~= nil then
            argsCount = argsCount + 1
        end
    end
    if fnData.argsNum ~= argsCount then
        PrintError("函数", fnType, '需要', fnData.argsNum, '个参数，却输入了', argsCount, '个')
        return
    end
    local result = fn(table.SafeUpack(args))
    self:log("计算", fnType, args, "结果", result)
    return result
end

function Calculator:callFuncByOp(op)
    return self:callFunc(CalcDefine.Op2Func[op])
end

--入栈时机
--1.运算符粘连
--2.首字符为运算符
--3.括号入栈时
function Calculator:pushWaitOp(op)
    if op == CalcDefine.OpType.Nil and #self.waitOps == 0 then
        return
    end
    table.insert(self.waitOps, op)
end

--出栈时机
--1.右括号闭合
--2.在非函数体内时，数字或者变量加入了result栈
--3.一直出栈，直至遇到隔断符号
--4.至少出栈一个
function Calculator:popWaitOp()
    local hasPop = false
    while #self.waitOps > 0 do
        local op = table.remove(self.waitOps)
        if op then
            if hasPop and op == CalcDefine.OpType.Nil then
                break
            else
                local fnType = CalcDefine.PrefixOp2Func[op]
                if fnType then
                    hasPop = true
                    self:addResult(CalcDefine.Type.Func, fnType)
                end
            end
        end
    end
end

function Calculator:log(...)
    if not self.Log then
        return
    end
    PrintLog(...)
end

function Calculator:logStacks()
    if not self.Log then
        return
    end
    local ops = {}
    for _, cur in ipairs(self.opStack) do
        if cur.type == CalcDefine.OpKind.Op then
            table.insert(ops, CalcDefine.OpSign[cur.op] or 'nil')
        else
            table.insert(ops, CalcDefine.FuncSign[cur.op])
        end
    end
    PrintLog("opStack:", table.concat(ops, ' '))
    local res = {}
    for _, cur in ipairs(self.resultStack) do
        if cur.type == CalcDefine.Type.Op then
            table.insert(res, CalcDefine.OpSign[cur.data] or 'nil')
        elseif cur.type == CalcDefine.Type.Func then
            table.insert(res, cur.data)
        else
            table.insert(res, tostring(cur.data))
        end
    end
    PrintLog("resultStack:", table.concat(res, ' '))
    local wops = {}
    for _, op in ipairs(self.waitOps) do
        table.insert(wops, CalcDefine.OpSign[op] or 'nil')
    end
    PrintLog("waitOps:", table.concat(wops, " "))
end

return Calculator
