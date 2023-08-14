ToFloatValueAnim = BaseClass("ToFloatValueAnim",AnimBaseTween)

function ToFloatValueAnim:__Init(fromValue,toValue,time,valueCb)
    self.fromValue = fromValue
    self.toValue = toValue
    self.time = time
    self.valueCb = valueCb
end

function ToFloatValueAnim:__Delete()
    
end

function ToFloatValueAnim:OnTween()
    local tween = DOTweenEx.ToValueFloat(self.fromValue,self.toValue,self.time,self.valueCb)
    return tween
end

function ToFloatValueAnim:SetValueCb(valueCb)
    self.valueCb = valueCb
end

function ToFloatValueAnim.Create(root,animData,nodes,animNodes)
    local anim = ToFloatValueAnim.New(animData.fromValue,animData.toValue,animData.time)
    return anim
end