ToIntValueAnim = BaseClass("ToIntValueAnim",AnimBaseTween)

function ToIntValueAnim:__Init(fromValue,toValue,time,valueCb)
    self.fromValue = fromValue
    self.toValue = toValue
    self.time = time
    self.valueCb = valueCb
end

function ToIntValueAnim:__Delete()
    
end

function ToIntValueAnim:OnTween()
    local tween = DOTweenEx.ToValueInt(self.fromValue,self.toValue,self.time,self.valueCb)
    return tween
end

function ToIntValueAnim:SetValueCb(valueCb)
    self.valueCb = valueCb
end

function ToIntValueAnim.Create(root,animData,nodes,animNodes)
    local anim = ToIntValueAnim.New(animData.fromValue,animData.toValue,animData.time)
    return anim
end