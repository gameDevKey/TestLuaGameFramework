CalcComponent = Class("CalcComponent",ECSLComponent)

function CalcComponent:OnInit()
    self.calc = Calculator.New()
    --注入属性获取函数
    for key, value in pairs(AttrConfig.Type) do
        self.calc:SetVarVal(value,self:ToFunc("onGetAttr"))
    end
end

function CalcComponent:OnDelete()
    self.calc:Delete()
end

function CalcComponent:Calc(pattern)
    if pattern then
        self.calc:SetPattern(pattern)
    end
    return self.calc:Calc()
end

function CalcComponent:IsTrue(pattern)
    if not string.valid(pattern) then
        return true
    end
    return self:Calc(pattern) == 1
end

function CalcComponent:onGetAttr(attr)
    return self.entity.AttrComponent:GetAttr(attr)
end

return CalcComponent